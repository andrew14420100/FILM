<#
.SYNOPSIS
  FILM - Opzione 2: copia privata degli archivi AC II e protezione NTFS automatica della SOLA copia.

.DESCRIPTION
  Eseguire PRIMA di Claude, dall'account Windows dell'utente che legge l'installazione Ubisoft Connect
  (account "preparatore"), in PowerShell NON elevato. Claude NON viene avviato da questo script.

  Garanzie di progetto (da confermare con i test reali su Windows: vedi TEST_WINDOWS_OPZIONE2.md):
    - L'installazione originale (-GameDir) viene SOLO letta: nessuna scrittura, nessuna modifica
      di file, cartelle, attributi o permessi. Lo script rifiuta qualsiasi destinazione dentro il gioco.
    - -DryRun non crea, copia, scrive o modifica NULLA: mostra soltanto il piano e i controlli.
    - Le ACL vengono modificate SOLO su -ArchiveDir (cartella nuova, creata da questo script) e sui
      file che contiene. Mai sulla cartella genitore, mai su altre cartelle.
    - Prima di modificare i permessi viene mostrato un riepilogo e serve una conferma esplicita.
    - In caso di errore dopo la modifica dei permessi: ripristino AUTOMATICO del descrittore salvato
      della sola copia. Ripristino manuale successivo: -RipristinaAcl.

  Fasi:
    1. Controlli in sola lettura: sessione non elevata; account Claude esistente, locale, abilitato,
       standard (non Administrators), diverso dal preparatore; percorsi locali, separati, senza
       junction/symlink; file sorgente presenti; spazio; diritti dell'account Claude sulla cartella
       genitore (nessun DELETE_CHILD / WRITE_DAC / WRITE_OWNER / DELETE), calcolati con AuthZ.
    2. Riepilogo (file, byte, account con SID, ACL che verranno applicate) e conferma: digitare PROTEGGI.
    3. Crea ArchiveDir, salva il suo descrittore iniziale in %LOCALAPPDATA%\FILM\acl_backup (fuori dalla
       portata dell'account Claude), applica la DACL protetta (senza ereditarieta'):
         SYSTEM, Administrators, preparatore = Controllo completo; account Claude = Lettura ed esecuzione.
    4. Copia i file (che ereditano la DACL protetta), verifica SHA256 e byte sorgente = copia,
       scrive MANIFEST_ARCHIVI.json (formato V2, con SID dell'account Claude).
    5. Verifica finale con AuthZ dell'accesso EFFETTIVO dell'account Claude su ArchiveDir, ogni file
       e la cartella genitore. Qualsiasi diritto di modifica -> ripristino ACL e STOP.
  La verifica definitiva con il token reale dell'account Claude la ripete avvia_claude_locale.ps1.

  Limite dichiarato: AuthZ da SID non include i gruppi legati alla sessione di logon (es. INTERACTIVE);
  per questo la DACL della copia contiene SOLO voci esplicite e il launcher ripete il controllo con il
  token reale. Script NON eseguito ne' testato su Windows.

.EXAMPLE
  .\prepara_copia_privata_acii.ps1 -GameDir "D:\Games\Assassin's Creed II" -ArchiveDir "D:\FILM_ARCHIVI_RO" -ClaudeAccount "film_claude" -DryRun
  .\prepara_copia_privata_acii.ps1 -GameDir "D:\Games\Assassin's Creed II" -ArchiveDir "D:\FILM_ARCHIVI_RO" -ClaudeAccount "film_claude"
  .\prepara_copia_privata_acii.ps1 -ArchiveDir "D:\FILM_ARCHIVI_RO" -RipristinaAcl
#>
[CmdletBinding(DefaultParameterSetName = 'Prepara')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Prepara')][string]$GameDir,
    [Parameter(Mandatory = $true)][string]$ArchiveDir,
    [Parameter(Mandatory = $true, ParameterSetName = 'Prepara')][string]$ClaudeAccount,
    [Parameter(ParameterSetName = 'Prepara')][string]$WorkDir = 'D:\FILM_PRIVATO',
    [Parameter(ParameterSetName = 'Prepara')][switch]$IncludeHideout,
    [Parameter(ParameterSetName = 'Prepara')][switch]$IncludeItalianVoices,
    [Parameter(ParameterSetName = 'Prepara')][switch]$DryRun,
    [Parameter(Mandatory = $true, ParameterSetName = 'Ripristina')][switch]$RipristinaAcl
)
$ErrorActionPreference = 'Stop'

Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

public static class FilmAuthz {
    [StructLayout(LayoutKind.Sequential)]
    struct LUID { public uint LowPart; public int HighPart; }
    [StructLayout(LayoutKind.Sequential)]
    struct AUTHZ_ACCESS_REQUEST {
        public uint DesiredAccess; public IntPtr PrincipalSelfSid; public IntPtr ObjectTypeList;
        public uint ObjectTypeListLength; public IntPtr OptionalArguments;
    }
    [StructLayout(LayoutKind.Sequential)]
    struct AUTHZ_ACCESS_REPLY {
        public uint ResultListLength; public IntPtr GrantedAccessMask; public IntPtr SaclEvaluationResults; public IntPtr Error;
    }
    [DllImport("authz.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern bool AuthzInitializeResourceManager(uint flags, IntPtr pfnAccessCheck, IntPtr pfnComputeDynamicGroups,
        IntPtr pfnFreeDynamicGroups, string name, out IntPtr rm);
    [DllImport("authz.dll", SetLastError = true)]
    static extern bool AuthzInitializeContextFromSid(uint flags, byte[] sid, IntPtr rm, IntPtr expiration, LUID id,
        IntPtr dynamicGroupArgs, out IntPtr ctx);
    [DllImport("authz.dll", SetLastError = true)]
    static extern bool AuthzAccessCheck(uint flags, IntPtr ctx, ref AUTHZ_ACCESS_REQUEST request, IntPtr auditEvent,
        IntPtr sd, IntPtr[] optionalSds, uint optionalSdCount, ref AUTHZ_ACCESS_REPLY reply, IntPtr results);
    [DllImport("authz.dll")] static extern bool AuthzFreeContext(IntPtr ctx);
    [DllImport("authz.dll")] static extern bool AuthzFreeResourceManager(IntPtr rm);
    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern bool GetFileSecurity(string path, uint requested, IntPtr sd, uint length, out uint needed);

    // Diritti EFFETTIVI che Windows concederebbe all'account indicato dal SID (come "Accesso effettivo"
    // di Esplora risorse), senza accedere con quell'account.
    public static uint MaximumAllowedForSid(string path, byte[] sid) {
        const uint INFO = 0x1 | 0x2 | 0x4; // OWNER | GROUP | DACL
        uint needed;
        GetFileSecurity(path, INFO, IntPtr.Zero, 0, out needed);
        if (needed == 0) throw new Win32Exception(Marshal.GetLastWin32Error(), "GetFileSecurity: " + path);
        IntPtr sd = Marshal.AllocHGlobal((int)needed);
        IntPtr rm = IntPtr.Zero, ctx = IntPtr.Zero, granted = IntPtr.Zero, error = IntPtr.Zero;
        try {
            if (!GetFileSecurity(path, INFO, sd, needed, out needed))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "GetFileSecurity: " + path);
            if (!AuthzInitializeResourceManager(0x1, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, null, out rm)) // NO_AUDIT
                throw new Win32Exception(Marshal.GetLastWin32Error(), "AuthzInitializeResourceManager");
            if (!AuthzInitializeContextFromSid(0, sid, rm, IntPtr.Zero, new LUID(), IntPtr.Zero, out ctx))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "AuthzInitializeContextFromSid");
            granted = Marshal.AllocHGlobal(4); error = Marshal.AllocHGlobal(4);
            Marshal.WriteInt32(granted, 0); Marshal.WriteInt32(error, 0);
            AUTHZ_ACCESS_REQUEST req = new AUTHZ_ACCESS_REQUEST { DesiredAccess = 0x02000000 }; // MAXIMUM_ALLOWED
            AUTHZ_ACCESS_REPLY rep = new AUTHZ_ACCESS_REPLY { ResultListLength = 1, GrantedAccessMask = granted, Error = error };
            if (!AuthzAccessCheck(0, ctx, ref req, IntPtr.Zero, sd, null, 0, ref rep, IntPtr.Zero))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "AuthzAccessCheck: " + path);
            return (uint)Marshal.ReadInt32(granted);
        } finally {
            if (granted != IntPtr.Zero) Marshal.FreeHGlobal(granted);
            if (error != IntPtr.Zero) Marshal.FreeHGlobal(error);
            if (ctx != IntPtr.Zero) AuthzFreeContext(ctx);
            if (rm != IntPtr.Zero) AuthzFreeResourceManager(rm);
            Marshal.FreeHGlobal(sd);
        }
    }
}
'@

# Diritti che l'account Claude NON deve avere sulla copia (cartella e file):
# WRITE_DATA/ADD_FILE 0x2, APPEND/ADD_SUBDIR 0x4, WRITE_EA 0x10, DELETE_CHILD 0x40, WRITE_ATTRIBUTES 0x100,
# DELETE 0x10000, WRITE_DAC 0x40000, WRITE_OWNER 0x80000
$ModifyMask = [uint32]0xD0156
# Sulla cartella genitore: DELETE_CHILD (cancellare/rinominare la copia), DELETE, WRITE_DAC, WRITE_OWNER.
$ParentMask = [uint32]0xD0040
$ManifestName = 'MANIFEST_ARCHIVI.json'

function Get-AbsolutePath([string]$p) {
    $full = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
    return [System.IO.Path]::GetFullPath($full).TrimEnd('\')
}
function Assert-LocalPath([string]$p, [string]$label) {
    if ($p -notmatch '^[A-Za-z]:\\.+') { throw "$label deve essere un percorso locale con lettera di unita' (no UNC, no radice): $p" }
}
function Test-IsReparse([string]$p) {
    return [bool]((Get-Item -LiteralPath $p -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}
function Assert-NoReparsePoint([string]$path, [string]$label) {
    $cur = $path
    while ($cur) {
        if ((Test-Path -LiteralPath $cur) -and (Test-IsReparse $cur)) { throw "$label contiene una junction/symlink: $cur" }
        $up = Split-Path -Path $cur -Parent
        if (-not $up -or $up -eq $cur) { break }
        $cur = $up
    }
}
function Assert-Separated([string]$a, [string]$b, [string]$label) {
    $cmp = [System.StringComparison]::OrdinalIgnoreCase
    if ($a.Equals($b, $cmp) -or ($a + '\').StartsWith($b + '\', $cmp) -or ($b + '\').StartsWith($a + '\', $cmp)) {
        throw "Percorsi non separati ($label): '$a' / '$b'."
    }
}
function Get-SidBytes([Security.Principal.SecurityIdentifier]$sid) {
    $b = New-Object byte[] ($sid.BinaryLength); $sid.GetBinaryForm($b, 0); return , $b
}
function Get-BackupDir([string]$archive) {
    if (-not $env:LOCALAPPDATA) { throw "LOCALAPPDATA non definita: impossibile salvare il backup delle ACL." }
    $leaf = ($archive -replace '[:\\]', '_')
    return (Join-Path $env:LOCALAPPDATA "FILM\acl_backup\$leaf")
}
function Save-AclBackup([string]$archive) {
    # Salva il descrittore (DACL) della SOLA copia e dei suoi elementi, con percorsi relativi.
    $dir = Get-BackupDir $archive
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $entries = @()
    $items = @(Get-Item -LiteralPath $archive -Force) + @(Get-ChildItem -LiteralPath $archive -Recurse -Force)
    foreach ($it in $items) {
        $rel = ''
        if ($it.FullName.Length -gt $archive.Length) { $rel = $it.FullName.Substring($archive.Length + 1) }
        $sddl = (Get-Acl -LiteralPath $it.FullName).GetSecurityDescriptorSddlForm([System.Security.AccessControl.AccessControlSections]::Access)
        $entries += [pscustomobject]@{ RelativePath = $rel; IsDirectory = [bool]$it.PSIsContainer; DaclSddl = $sddl }
    }
    $file = Join-Path $dir ("acl_{0}.json" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
    [ordered]@{ Format = 'FILM_ACL_BACKUP_V1'; ArchiveDir = $archive; Saved = (Get-Date -Format s); Entries = $entries } |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $file -Encoding UTF8
    return $file
}
function Restore-AclBackup([string]$archive, [string]$file) {
    # Ripristina SOLO elementi che risolvono dentro ArchiveDir, senza reparse point. Mai la cartella genitore.
    $b = Get-Content -LiteralPath $file -Raw | ConvertFrom-Json
    if ($b.Format -ne 'FILM_ACL_BACKUP_V1') { throw "Backup ACL non riconosciuto: $file" }
    if (-not ([string]$b.ArchiveDir).Equals($archive, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Il backup appartiene a un'altra cartella ($($b.ArchiveDir)): rifiutato."
    }
    $cmp = [System.StringComparison]::OrdinalIgnoreCase
    # Prima i file, poi le cartelle dalla piu' profonda alla radice (la radice per ultima).
    $ordered = @($b.Entries | Sort-Object @{ Expression = { [bool]$_.IsDirectory } }, @{ Expression = { ([string]$_.RelativePath).Length }; Descending = $true })
    foreach ($e in $ordered) {
        $rel = [string]$e.RelativePath
        if ($rel -match '(^|\\)\.\.(\\|$)' -or $rel -match '^[A-Za-z]:' -or $rel.StartsWith('\')) { throw "Percorso non ammesso nel backup: $rel" }
        $target = $archive
        if ($rel) { $target = [System.IO.Path]::GetFullPath((Join-Path $archive $rel)).TrimEnd('\') }
        if (-not ($target.Equals($archive, $cmp) -or $target.StartsWith($archive + '\', $cmp))) { throw "Elemento fuori dalla copia: $target" }
        if (-not (Test-Path -LiteralPath $target)) { Write-Warning "Non presente, saltato: $target"; continue }
        Assert-NoReparsePoint $target 'Ripristino'
        $acl = Get-Acl -LiteralPath $target
        $acl.SetSecurityDescriptorSddlForm([string]$e.DaclSddl, [System.Security.AccessControl.AccessControlSections]::Access)
        Set-Acl -LiteralPath $target -AclObject $acl
        Write-Host "ACL ripristinata: $target"
    }
}
function Set-ProtectedAcl([string]$archive, [Security.Principal.SecurityIdentifier]$meSid, [Security.Principal.SecurityIdentifier]$claudeSid) {
    $inherit = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'
    $prop = [System.Security.AccessControl.PropagationFlags]::None
    $allow = [System.Security.AccessControl.AccessControlType]::Allow
    $full = [System.Security.AccessControl.FileSystemRights]::FullControl
    $rx = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
    $acl = Get-Acl -LiteralPath $archive
    $acl.SetAccessRuleProtection($true, $false)     # niente ereditarieta' dal genitore, nessuna copia delle voci ereditate
    foreach ($r in @($acl.Access)) { [void]$acl.RemoveAccessRuleSpecific($r) }
    $sys = New-Object Security.Principal.SecurityIdentifier('S-1-5-18')
    $adm = New-Object Security.Principal.SecurityIdentifier('S-1-5-32-544')
    foreach ($s in @($sys, $adm, $meSid)) {
        $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($s, $full, $inherit, $prop, $allow)))
    }
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($claudeSid, $rx, $inherit, $prop, $allow)))
    Set-Acl -LiteralPath $archive -AclObject $acl
}
function Get-ClaudeViolations([string]$archive, [byte[]]$claudeSidBytes) {
    $out = @()
    $items = @(Get-Item -LiteralPath $archive -Force) + @(Get-ChildItem -LiteralPath $archive -Recurse -Force)
    foreach ($it in $items) {
        if ($it.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { $out += "Reparse point nella copia: $($it.FullName)"; continue }
        $g = [FilmAuthz]::MaximumAllowedForSid($it.FullName, $claudeSidBytes)
        if (($g -band 0x1) -eq 0) { $out += "L'account Claude NON puo' leggere: $($it.FullName)" }
        $w = $g -band $ModifyMask
        if ($w -ne 0) { $out += ('{0} : diritti di modifica 0x{1:X}' -f $it.FullName, $w) }
        $acl = Get-Acl -LiteralPath $it.FullName
        $ownerSid = (New-Object Security.Principal.NTAccount($acl.Owner)).Translate([Security.Principal.SecurityIdentifier])
        if ($ownerSid.Value -eq (New-Object Security.Principal.SecurityIdentifier($claudeSidBytes, 0)).Value) {
            $out += "L'account Claude e' PROPRIETARIO di $($it.FullName)"
        }
    }
    $parent = Split-Path -Path $archive -Parent
    $gp = [FilmAuthz]::MaximumAllowedForSid($parent, $claudeSidBytes)
    $wp = $gp -band $ParentMask
    if ($wp -ne 0) { $out += ('Cartella genitore {0}: l''account Claude ha 0x{1:X} (cancellazione/rinomina della copia o cambio permessi)' -f $parent, $wp) }
    return , $out
}

$archive = Get-AbsolutePath $ArchiveDir
Assert-LocalPath $archive 'ArchiveDir'

# ---------------- Modalita' ripristino manuale ----------------
if ($PSCmdlet.ParameterSetName -eq 'Ripristina') {
    if (-not (Test-Path -LiteralPath $archive -PathType Container)) { throw "ArchiveDir non trovata: $archive" }
    Assert-NoReparsePoint $archive 'ArchiveDir'
    $bdir = Get-BackupDir $archive
    $last = Get-ChildItem -LiteralPath $bdir -Filter 'acl_*.json' -File -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1
    if (-not $last) { throw "Nessun backup ACL trovato in $bdir." }
    Write-Host "Backup da ripristinare: $($last.FullName)"
    Write-Host "Saranno ripristinate SOLO le ACL di $archive e del suo contenuto (non la cartella genitore, non il gioco)."
    Write-Warning "Dopo il ripristino la copia torna ai permessi iniziali: il launcher rifiutera' l'avvio finche' non la si protegge di nuovo."
    if ((Read-Host "Digitare RIPRISTINA per procedere") -cne 'RIPRISTINA') { Write-Host "Annullato. Nessuna modifica."; return }
    Restore-AclBackup $archive $last.FullName
    Write-Host "Ripristino completato."
    return
}

# ---------------- Fase 1: controlli in sola lettura ----------------
Write-Host "== Fase 1: controlli in sola lettura =="
$game = Get-AbsolutePath $GameDir
$work = Get-AbsolutePath $WorkDir
Assert-LocalPath $game 'GameDir'
Assert-LocalPath $work 'WorkDir'

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Sessione elevata: eseguire da PowerShell NON elevato con l'account preparatore."
}
$meSid = [Security.Principal.WindowsIdentity]::GetCurrent().User

if (-not (Test-Path -LiteralPath $game -PathType Container)) { throw "GameDir non trovato: $game" }
if (Test-Path -LiteralPath $archive) { throw "Destinazione gia' esistente: $archive. Lo script non riusa ne' sovrascrive copie o permessi precedenti." }
Assert-NoReparsePoint $game 'GameDir'
Assert-NoReparsePoint $archive 'ArchiveDir'
Assert-NoReparsePoint $work 'WorkDir'
Assert-Separated $game $archive 'gioco/copia'
Assert-Separated $game $work 'gioco/area Claude'
Assert-Separated $archive $work 'copia/area Claude'
$parent = Split-Path -Path $archive -Parent
if (-not (Test-Path -LiteralPath $parent -PathType Container)) { throw "La cartella genitore della copia non esiste: $parent" }

# Account Claude: identificazione precisa.
try { $claudeSid = (New-Object Security.Principal.NTAccount($ClaudeAccount)).Translate([Security.Principal.SecurityIdentifier]) }
catch { throw "Account '$ClaudeAccount' non trovato. Creare prima un account Windows STANDARD dedicato a Claude." }
$claudeName = $claudeSid.Translate([Security.Principal.NTAccount]).Value
if ($claudeSid.Value -eq $meSid.Value) { throw "L'account Claude deve essere DIVERSO dall'account preparatore ($claudeName)." }
if ($null -eq $claudeSid.AccountDomainSid -or $claudeSid.Value -match '^S-1-5-(18|19|20)$' -or $claudeSid.Value -match '^S-1-5-32-') {
    throw "'$claudeName' non e' un account utente valido (SID $($claudeSid.Value))."
}
$localUser = $null
if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) {
    $localUser = Get-LocalUser -SID $claudeSid -ErrorAction SilentlyContinue
}
if (-not $localUser) { throw "'$claudeName' non e' un account LOCALE di questo PC (account di dominio/Microsoft non supportati da questa procedura)." }
if (-not $localUser.Enabled) { throw "L'account '$claudeName' e' disabilitato." }
$admins = @(Get-LocalGroupMember -SID 'S-1-5-32-544' -ErrorAction Stop)
if ($admins | Where-Object { $_.SID -and $_.SID.Value -eq $claudeSid.Value }) {
    throw "L'account '$claudeName' appartiene ad Administrators: deve essere STANDARD."
}

# File sorgente (solo lettura).
$relative = @('DataPC_Abstergo.forge')
if ($IncludeHideout) { $relative += 'DataPC_Hideout.forge' }
if ($IncludeItalianVoices) { $relative += 'SoundData\pc\sounds_ita.pck' }
$files = @()
foreach ($name in $relative) {
    $from = Join-Path $game $name
    Assert-NoReparsePoint $from 'Sorgente'
    if (-not (Test-Path -LiteralPath $from -PathType Leaf)) { throw "File assente nell'installazione originale: $from" }
    $files += [pscustomobject]@{ Name = $name; Path = $from; Bytes = [long](Get-Item -LiteralPath $from -Force).Length }
}
$needed = [long](($files | Measure-Object -Property Bytes -Sum).Sum)
$drive = New-Object System.IO.DriveInfo([System.IO.Path]::GetPathRoot($archive))
if (-not $drive.IsReady -or $drive.AvailableFreeSpace -lt ($needed + 100MB)) { throw "Spazio insufficiente su $($drive.Name)." }

# Diritti dell'account Claude sulla cartella genitore (non modificabili da questo script).
$claudeSidBytes = Get-SidBytes $claudeSid
$gp = [FilmAuthz]::MaximumAllowedForSid($parent, $claudeSidBytes)
$parentIssue = $gp -band $ParentMask

# ---------------- Fase 2: riepilogo e conferma ----------------
Write-Host ""
Write-Host "== Fase 2: RIEPILOGO =="
Write-Host "Installazione originale (SOLO LETTURA, nessuna modifica): $game"
Write-Host "Copia privata da creare:                                  $archive"
Write-Host "Area di lavoro di Claude (non toccata qui):               $work"
Write-Host "Preparatore (questo account):  $([Security.Principal.WindowsIdentity]::GetCurrent().Name)  SID $($meSid.Value)"
Write-Host "Account Claude (standard):     $claudeName  SID $($claudeSid.Value)"
foreach ($f in $files) { Write-Host ("Copia prevista: {0}  ({1:N0} byte)" -f $f.Name, $f.Bytes) }
Write-Host "Permessi che verranno applicati SOLO a $archive e al suo contenuto:"
Write-Host "  - ereditarieta' dal genitore DISATTIVATA (nessuna voce ereditata)"
Write-Host "  - SYSTEM, Administrators, $([Security.Principal.WindowsIdentity]::GetCurrent().Name): Controllo completo"
Write-Host "  - $claudeName : Lettura ed esecuzione (nessuna scrittura, cancellazione, rinomina o modifica permessi)"
Write-Host "Backup del descrittore della copia in: $(Get-BackupDir $archive)"
if ($parentIssue -ne 0) {
    Write-Warning ("La cartella genitore {0} concede all'account Claude 0x{1:X} (puo' cancellare/rinominare la copia o cambiarne i permessi)." -f $parent, $parentIssue)
    Write-Warning "Lo script NON modifica la cartella genitore. Scegliere un'altra posizione per -ArchiveDir. STOP."
    throw "Cartella genitore non sicura per l'account Claude."
}
Write-Host "Cartella genitore ${parent}: nessun diritto critico per l'account Claude (AuthZ)."
if ($DryRun) { Write-Host ""; Write-Host "DRY RUN: nessuna cartella creata, nessun file copiato, nessun permesso modificato."; return }

if ((Read-Host "Digitare PROTEGGI per creare la copia e applicare i permessi descritti") -cne 'PROTEGGI') {
    Write-Host "Annullato. Nessuna modifica."; return
}

# ---------------- Fasi 3-5: creazione, protezione, copia, verifica ----------------
if (Test-Path -LiteralPath $archive) { throw "Destinazione creata da un altro processo: STOP." }
New-Item -ItemType Directory -Path $archive -ErrorAction Stop | Out-Null
Assert-NoReparsePoint $archive 'ArchiveDir'
$backupFile = Save-AclBackup $archive
Write-Host "Backup ACL iniziale della copia: $backupFile"
$aclApplied = $false
try {
    Set-ProtectedAcl $archive $meSid $claudeSid
    $aclApplied = $true
    Write-Host "Permessi protetti applicati a $archive."

    $manifestFiles = @()
    foreach ($f in $files) {
        Assert-NoReparsePoint $f.Path 'Sorgente'
        $target = Join-Path $archive $f.Name
        $tparent = Split-Path -Path $target -Parent
        if (-not (Test-Path -LiteralPath $tparent)) { New-Item -ItemType Directory -Path $tparent -Force -ErrorAction Stop | Out-Null }
        Assert-NoReparsePoint $tparent 'Destinazione'
        if (Test-Path -LiteralPath $target) { throw "File gia' presente: $target" }
        $before = (Get-FileHash -LiteralPath $f.Path -Algorithm SHA256).Hash
        Copy-Item -LiteralPath $f.Path -Destination $target -ErrorAction Stop
        $copy = Get-Item -LiteralPath $target -Force
        $after = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
        if ($before -ne $after -or $copy.Length -ne $f.Bytes) { throw "HASH/DIMENSIONE NON CORRISPONDENTE: $($f.Name)." }
        $manifestFiles += [pscustomobject]@{ RelativePath = $f.Name; Bytes = [long]$f.Bytes; SHA256 = $after }
        Write-Host "Copiato e verificato SHA256: $($f.Name)"
    }
    # Le copie devono ereditare SOLO la DACL protetta: rimuove eventuali voci esplicite portate dalla copia.
    foreach ($it in @(Get-ChildItem -LiteralPath $archive -Recurse -Force)) {
        $a = Get-Acl -LiteralPath $it.FullName
        $a.SetAccessRuleProtection($false, $false)
        foreach ($r in @($a.Access | Where-Object { -not $_.IsInherited })) { [void]$a.RemoveAccessRuleSpecific($r) }
        Set-Acl -LiteralPath $it.FullName -AclObject $a
    }
    $manifest = [ordered]@{
        Format              = 'FILM_PRIVATE_ACII_COPY_V2'
        GameEdition         = 'Assassins Creed II PC Ubisoft Connect (dichiarazione utente)'
        Copies              = @($manifestFiles)
        ClaudeAccount       = $claudeName
        ClaudeAccountSid    = $claudeSid.Value
        PreparerSid         = $meSid.Value
        AclProfile          = 'PROTECTED: SYSTEM/Administrators/Preparer FullControl; ClaudeAccount ReadAndExecute; no inheritance'
        AclBackup           = $backupFile
        OriginalChanged     = "Nessuna operazione di scrittura o modifica permessi su GameDir"
        Prepared            = (Get-Date -Format s)
    }
    $manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $archive $ManifestName) -Encoding UTF8
    foreach ($it in @(Get-ChildItem -LiteralPath $archive -Recurse -File -Force)) { $it.IsReadOnly = $true }

    Write-Host "== Fase 5: verifica dell'accesso EFFETTIVO dell'account Claude (AuthZ) =="
    $viol = Get-ClaudeViolations $archive $claudeSidBytes
    if ($viol.Count -gt 0) {
        $viol | ForEach-Object { Write-Warning $_ }
        throw "Verifica dei permessi NON superata ($($viol.Count) problemi)."
    }
    Write-Host "OK: l'account $claudeName puo' solo leggere la copia; nessun diritto critico sulla cartella genitore."
} catch {
    Write-Warning "ERRORE: $($_.Exception.Message)"
    if ($aclApplied) {
        Write-Warning "Ripristino automatico delle ACL iniziali della SOLA copia ($archive)..."
        try { Restore-AclBackup $archive $backupFile; Write-Warning "ACL della copia ripristinate. La copia NON e' protetta: non avviare Claude." }
        catch { Write-Warning "Ripristino non riuscito: $($_.Exception.Message). Usare -RipristinaAcl oppure eliminare manualmente $archive." }
    }
    Write-Warning "La cartella del gioco non e' stata modificata. Controllare ed eventualmente eliminare $archive prima di riprovare."
    throw
}

Write-Host ""
Write-Host "PREPARAZIONE COMPLETATA (Claude NON e' stato avviato)."
Write-Host "Prossimi passi: verifica manuale facoltativa Proprieta' -> Sicurezza -> Avanzate -> Accesso effettivo -> $claudeName;"
Write-Host "poi accedere a Windows come $claudeName ed eseguire avvia_claude_locale.ps1, che ripete tutti i controlli con il token reale."
