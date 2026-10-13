<#
.SYNOPSIS
  FILM: avvia Claude Code lavorando solo sugli archivi COPIATI, non sulla directory originale di AC II.
.DESCRIPTION
  Opzione 2 approvata dall'utente: il gioco Ubisoft Connect NON e' aperto dal launcher.
  Un diverso account Windows standard legge D:\FILM_ARCHIVI_RO (ACL SOLA LETTURA) e
  scrive solo i propri risultati in D:\FILM_PRIVATO. La copia e' preparata PRIMA,
  da un altro account, con prepara_copia_privata_acii.ps1. Questo launcher NON
  modifica le ACL: se la copia e' ancora modificabile dall'account Claude, STOP.
  Valida il manifest SHA256 e controlla i diritti effettivi sulla copia via
  Windows AccessCheck, i reparse point e le configurazioni preesistenti.
  Non garantisce isolamento completo del sistema operativo su Windows nativo:
  l'account Claude va dedicato, senza privilegi sulla copia e, preferibilmente,
  senza alcun accesso alla cartella originale. Non pubblicare asset/audio.
  Script NON TESTATO su Windows nella presente sessione.
.EXAMPLE
  .\avvia_claude_locale.ps1 -ArchiveDir "D:\FILM_ARCHIVI_RO" -WorkDir "D:\FILM_PRIVATO" -ExpectedCommit <SHA40>
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ArchiveDir,
    [Parameter(Mandatory = $true)][string]$WorkDir,
    [Parameter(Mandatory = $true)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$ExpectedCommit
)
$ErrorActionPreference = 'Stop'

Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

public static class FilmAccess {
    [StructLayout(LayoutKind.Sequential)]
    public struct GENERIC_MAPPING { public uint GenericRead, GenericWrite, GenericExecute, GenericAll; }

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern bool GetFileSecurity(string lpFileName, uint requested, IntPtr pSD, uint nLength, out uint needed);
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool OpenProcessToken(IntPtr process, uint access, out IntPtr token);
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool DuplicateToken(IntPtr existing, int level, out IntPtr duplicate);
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool AccessCheck(IntPtr pSD, IntPtr token, uint desired, ref GENERIC_MAPPING mapping,
        IntPtr privilegeSet, ref uint privilegeSetLength, out uint granted, out bool status);
    [DllImport("kernel32.dll")]
    static extern IntPtr GetCurrentProcess();
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool CloseHandle(IntPtr handle);

    // Diritti EFFETTIVI concessi al token del processo corrente (valutazione di Windows:
    // ordine degli ACE, ereditarieta', gruppi abilitati/deny-only, proprietario, livello di integrita').
    public static uint MaximumAllowed(string path) {
        const uint INFO = 0x1 | 0x2 | 0x4; // OWNER | GROUP | DACL
        uint needed;
        GetFileSecurity(path, INFO, IntPtr.Zero, 0, out needed);
        if (needed == 0) throw new Win32Exception(Marshal.GetLastWin32Error(), "GetFileSecurity: " + path);
        IntPtr sd = Marshal.AllocHGlobal((int)needed);
        IntPtr token = IntPtr.Zero, imp = IntPtr.Zero, ps = IntPtr.Zero;
        try {
            if (!GetFileSecurity(path, INFO, sd, needed, out needed))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "GetFileSecurity: " + path);
            if (!OpenProcessToken(GetCurrentProcess(), 0x0002 | 0x0008, out token)) // DUPLICATE | QUERY
                throw new Win32Exception(Marshal.GetLastWin32Error(), "OpenProcessToken");
            if (!DuplicateToken(token, 2, out imp)) // SecurityImpersonation
                throw new Win32Exception(Marshal.GetLastWin32Error(), "DuplicateToken");
            GENERIC_MAPPING map = new GENERIC_MAPPING {
                GenericRead = 0x120089, GenericWrite = 0x120116, GenericExecute = 0x1200A0, GenericAll = 0x1F01FF };
            uint psLen = 1024;
            ps = Marshal.AllocHGlobal((int)psLen);
            uint granted; bool status;
            if (!AccessCheck(sd, imp, 0x02000000, ref map, ps, ref psLen, out granted, out status)) // MAXIMUM_ALLOWED
                throw new Win32Exception(Marshal.GetLastWin32Error(), "AccessCheck: " + path);
            if (!status) throw new InvalidOperationException("AccessCheck non ha concesso alcun accesso verificabile: " + path);
            return granted;
        } finally {
            if (ps != IntPtr.Zero) Marshal.FreeHGlobal(ps);
            Marshal.FreeHGlobal(sd);
            if (imp != IntPtr.Zero) CloseHandle(imp);
            if (token != IntPtr.Zero) CloseHandle(token);
        }
    }
}
'@

# FILE_WRITE_DATA/ADD_FILE 0x2, FILE_APPEND_DATA/ADD_SUBDIRECTORY 0x4, FILE_WRITE_EA 0x10,
# FILE_DELETE_CHILD 0x40, FILE_WRITE_ATTRIBUTES 0x100, DELETE 0x10000, WRITE_DAC 0x40000, WRITE_OWNER 0x80000
$WriteMask = [uint32]0xD0156

function Get-AbsolutePath([string]$p) {
    $full = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
    return [System.IO.Path]::GetFullPath($full).TrimEnd('\')
}
function Test-IsReparse([string]$p) {
    $item = Get-Item -LiteralPath $p -Force
    return [bool]($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}
function Assert-NoReparsePoint([string]$path, [string]$label) {
    $cur = $path
    while ($cur) {
        if ((Test-Path -LiteralPath $cur) -and (Test-IsReparse $cur)) {
            throw "$label contiene una junction/symlink ($cur). Usare un percorso reale senza collegamenti."
        }
        $parent = Split-Path -Path $cur -Parent
        if (-not $parent -or $parent -eq $cur) { break }
        $cur = $parent
    }
}
function Assert-Separated([string]$game, [string]$work) {
    $cmp = [System.StringComparison]::OrdinalIgnoreCase
    if ($work.Equals($game, $cmp) -or ($work + '\').StartsWith($game + '\', $cmp) -or ($game + '\').StartsWith($work + '\', $cmp)) {
        throw "WorkDir non deve coincidere con la cartella del gioco, ne' contenerla o esserne contenuta."
    }
}
function Confirm-Step([string]$question) {
    $answer = Read-Host "$question  Digitare SI per procedere"
    return ($answer -ceq 'SI')
}

$archive = Get-AbsolutePath $ArchiveDir
$work = Get-AbsolutePath $WorkDir
if ($archive -notmatch '^[A-Za-z]:\\' -or $work -notmatch '^[A-Za-z]:\\') {
    throw "Usare solo percorsi locali con lettera disco, non UNC/network path."
}
Write-Host "== 1a: archivi COPIATI e cartelle separate =="
if (-not (Test-Path -LiteralPath $archive -PathType Container)) {
    throw "Archivio privato assente: $archive. Prima eseguire lo staging fuori da Claude."
}
if ((Test-Path -LiteralPath $work) -and -not (Test-Path -LiteralPath $work -PathType Container)) {
    throw "WorkDir esiste ma non e' una cartella: $work"
}
Assert-NoReparsePoint $archive 'ArchiveDir'
Assert-NoReparsePoint $work 'WorkDir'
Assert-Separated $archive $work
Write-Host "Copia privata AC II: $archive"
Write-Host "Cartella lavoro:      $work"
Write-Host "Il launcher NON apre ne' verifica la cartella del gioco originale."

Write-Host "== 1b: account Windows dedicato =="
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Token elevato: Claude va avviato da account STANDARD dedicato."
}
$groupsCsv = & "$env:SystemRoot\System32\whoami.exe" /groups /fo csv /nh
if ($LASTEXITCODE -ne 0 -or -not $groupsCsv) { throw "Impossibile verificare i gruppi dell'account." }
$groups = $groupsCsv | ConvertFrom-Csv -Header 'Name', 'Type', 'SID', 'Attributes'
if ($groups | Where-Object { $_.SID -eq 'S-1-5-32-544' }) {
    throw "Account membro di Administrators: usare un account standard separato per Claude."
}
# Altri gruppi privilegiati (Backup/Server/Account/Print Operators, Power Users, Hyper-V Administrators): STOP.
$privGroups = @('S-1-5-32-551', 'S-1-5-32-549', 'S-1-5-32-548', 'S-1-5-32-550', 'S-1-5-32-547', 'S-1-5-32-578')
$badGroup = $groups | Where-Object { $privGroups -contains $_.SID } | Select-Object -First 1
if ($badGroup) { throw "Account membro del gruppo privilegiato $($badGroup.Name) ($($badGroup.SID)): non sicuro per Claude." }
# Privilegi del token che aggirano le ACL (anche se disabilitati): STOP.
$privCsv = & "$env:SystemRoot\System32\whoami.exe" /priv /fo csv /nh
if ($LASTEXITCODE -ne 0 -or -not $privCsv) { throw "Impossibile verificare i privilegi dell'account." }
$privs = $privCsv | ConvertFrom-Csv -Header 'Name', 'Description', 'State'
$dangerous = @('SeBackupPrivilege', 'SeRestorePrivilege', 'SeTakeOwnershipPrivilege', 'SeDebugPrivilege',
    'SeSecurityPrivilege', 'SeTcbPrivilege', 'SeLoadDriverPrivilege', 'SeManageVolumePrivilege', 'SeImpersonatePrivilege',
    'SeAssignPrimaryTokenPrivilege', 'SeCreateTokenPrivilege', 'SeRelabelPrivilege')
$badPriv = @($privs | Where-Object { $dangerous -contains $_.Name } | ForEach-Object { $_.Name })
if ($badPriv.Count -gt 0) { throw "Il token dell'account ha privilegi che possono aggirare le ACL: $($badPriv -join ', '). Usare un account standard." }
Write-Host "Token standard. Verificare a cura dell'utente che l'account sia dedicato."

Write-Host "== 1c: integrita' e permessi EFFETTIVI della copia =="
$manifestFile = Join-Path $archive 'MANIFEST_ARCHIVI.json'
Assert-NoReparsePoint $manifestFile 'Manifest'
if (-not (Test-Path -LiteralPath $manifestFile -PathType Leaf)) { throw "Manifest copia mancante: $manifestFile" }
try { $m = Get-Content -LiteralPath $manifestFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop }
catch { throw "Manifest illeggibile/non valido: $($_.Exception.Message)" }
if ($m.Format -ne 'FILM_PRIVATE_ACII_COPY_V2') { throw "Formato manifest sconosciuto o precedente (serve V2 da prepara_copia_privata_acii.ps1 con permessi automatici)." }
$meSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
if ([string]$m.ClaudeAccountSid -ne $meSid) {
    throw "Questo account ($meSid) non e' l'account Claude per cui e' stata protetta la copia ($($m.ClaudeAccountSid)). STOP."
}
if ([string]$m.PreparerSid -eq $meSid) { throw "L'account Claude coincide con il preparatore della copia: STOP." }
# La DACL della cartella copia deve essere protetta (nessuna ereditarieta') e l'account Claude non proprietario.
$rootAcl = Get-Acl -LiteralPath $archive
if (-not $rootAcl.AreAccessRulesProtected) { throw "La DACL di $archive eredita dal genitore: protezione non conforme. Rieseguire la preparazione." }
$entries = @($m.Copies)
if ($entries.Count -lt 1) { throw "Manifest vuoto." }
$allowedNames = @('DataPC_Abstergo.forge', 'DataPC_Hideout.forge', 'SoundData\pc\sounds_ita.pck')
$seen = @{}
foreach ($entry in $entries) {
    $name = [string]$entry.RelativePath
    if ($allowedNames -cnotcontains $name -or $seen.ContainsKey($name)) {
        throw "Elemento non previsto/ripetuto nel manifest: $name"
    }
    $seen[$name] = $true
}
if (-not $seen.ContainsKey('DataPC_Abstergo.forge')) { throw "L'archivio Abstergo non e' tra le copie." }
$readErrors = @()
$items = @(Get-Item -LiteralPath $archive -Force)
$items += Get-ChildItem -LiteralPath $archive -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable readErrors
if ($readErrors.Count -gt 0) { throw "Lettura incompleta della copia: stop." }
$fileCount = 0
foreach ($item in $items) {
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw "Link/junction all'interno della copia: $($item.FullName)"
    }
    $ownerSid = (New-Object Security.Principal.NTAccount((Get-Acl -LiteralPath $item.FullName).Owner)).Translate([Security.Principal.SecurityIdentifier]).Value
    if ($ownerSid -eq $meSid) { throw "L'account Claude e' proprietario di $($item.FullName): potrebbe cambiarne i permessi. STOP." }
    $granted = [FilmAccess]::MaximumAllowed($item.FullName)
    if (($granted -band 0x1) -eq 0) { throw "L'account Claude non puo' leggere $($item.FullName)." }
    $w = $granted -band $WriteMask
    if ($w -ne 0) {
        throw ("L'account di Claude ha diritti di scrittura/eliminazione sulla COPIA: {0} (0x{1:X}). Bloccare con ACL di Windows, senza cambiare il gioco." -f $item.FullName, $w)
    }
    if (-not $item.PSIsContainer) { $fileCount++ }
}
# Sul genitore: DELETE_CHILD (cancellare/rinominare la copia), DELETE, WRITE_DAC, WRITE_OWNER -> STOP.
$parent = Split-Path -Path $archive -Parent
if (-not $parent) { throw "Cartella genitore della copia non determinabile." }
$rightsParent = [FilmAccess]::MaximumAllowed($parent)
$parentIssue = $rightsParent -band [uint32]0xD0040
if ($parentIssue -ne 0) {
    throw ("L'account Claude ha 0x{0:X} sulla cartella genitore {1} (puo' cancellare/rinominare la copia o cambiarne i permessi). STOP." -f $parentIssue, $parent)
}
if ($fileCount -ne ($entries.Count + 1)) {
    throw "Nella copia esistono file inattesi o ne mancano ($fileCount vs $($entries.Count + 1))."
}
foreach ($entry in $entries) {
    $pathToCheck = Join-Path $archive ([string]$entry.RelativePath)
    Assert-NoReparsePoint $pathToCheck 'Archivio'
    if (-not (Test-Path -LiteralPath $pathToCheck -PathType Leaf)) { throw "Archivio assente: $pathToCheck" }
    $it = Get-Item -LiteralPath $pathToCheck -Force
    if ([long]$it.Length -ne [long]$entry.Bytes) { throw "Dimensione diversa nel file $($entry.RelativePath)" }
    $hash = (Get-FileHash -LiteralPath $pathToCheck -Algorithm SHA256).Hash
    if ($hash -ne [string]$entry.SHA256) { throw "SHA256 difforme: $($entry.RelativePath)" }
    Write-Host "Archivio copiato verificato: $($entry.RelativePath)"
}
Write-Host "Copia protetta per l'account corrente e manifest SHA256 validato."
Write-Host "ATTENZIONE: il controllo della copia non certifica da solo l'inaccessibilita' del gioco originale da Windows."

Write-Host "== 1d: configurazioni Claude preesistenti =="
foreach ($n2 in @('.claude', 'CLAUDE.md', 'CLAUDE.local.md', '.mcp.json', 'capitolato')) {
    $p = Join-Path $work $n2
    if (Test-Path -LiteralPath $p) {
        throw "Configurazione preesistente non verificata: $p. Usare cartella privata nuova/vuota."
    }
}
$anc = Split-Path -Path $work -Parent
while ($anc) {
    foreach ($n2 in @('CLAUDE.md', 'CLAUDE.local.md', '.claude')) {
        if (Test-Path -LiteralPath (Join-Path $anc $n2)) {
            throw "Istruzioni Claude potenzialmente ereditate dalla cartella parent: $(Join-Path $anc $n2)"
        }
    }
    $next = Split-Path -Path $anc -Parent
    if (-not $next -or $next -eq $anc) { break }
    $anc = $next
}
$userSettings = Join-Path $env:USERPROFILE '.claude\settings.json'
if (Test-Path -LiteralPath $userSettings) {
    try { $us = Get-Content -LiteralPath $userSettings -Raw | ConvertFrom-Json }
    catch { throw "Impossibile verificare le configurazioni utente Claude." }
    $problems = @()
    if ($us.permissions -and $us.permissions.allow -and @($us.permissions.allow).Count -gt 0) { $problems += 'regole allow' }
    if ($us.permissions -and $us.permissions.defaultMode -and @('default','plan') -notcontains $us.permissions.defaultMode) { $problems += 'modalita permissiva' }
    if ($us.hooks) { $problems += 'hooks' }
    if ($us.mcpServers) { $problems += 'mcpServers' }
    if ($problems.Count -gt 0) { throw "Configurazione utente permissiva: $($problems -join ', ')" }
}

Write-Host "== 1e: revisione esatta delle istruzioni FILM =="
$docsDir = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $docsDir)
$required = @('README.md','CLAUDE.md','docs','docs\ricerca_massiva\CLAUDE_CODE_LOCALE_DELEGA.md')
foreach ($r in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $r))) { throw "Capitolato incompleto: $r" }
}
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) { throw "Git non disponibile per verificare la revisione." }
$head = (& $git.Source -C $repoRoot rev-parse HEAD 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $head) { throw "Repository FILM non valido." }
$head = $head.Trim().ToLowerInvariant()
if ($head -ne $ExpectedCommit.ToLowerInvariant()) { throw "Commit FILM inatteso: $head (atteso $ExpectedCommit)" }
$dirty = & $git.Source -C $repoRoot status --porcelain --untracked-files=all
if ($LASTEXITCODE -ne 0 -or $dirty) { throw "Clone FILM non pulito o git status fallito." }
Write-Host "FILM commit verificato: $head"

Write-Host "== 1f: tool disponibili (solo informazione) =="
$smi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if ($smi) { & $smi.Source --query-gpu=name,memory.total,driver_version --format=csv,noheader }
else { Write-Warning "NVIDIA non rilevabile." }
$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) { Write-Host "Claude CLI: $($claude.Source)"; & $claude.Source --version }
else { Write-Warning "CLI claude assente." }

Write-Host "== 2: copia SOLO delle istruzioni nel WorkDir =="
if (-not (Confirm-Step "Creare $work, copiare il capitolato e predisporre Claude in plan mode?")) {
    Write-Host "Annullato prima della scrittura."; return
}
New-Item -ItemType Directory -Path $work -Force | Out-Null
Assert-NoReparsePoint $work 'WorkDir'
Assert-Separated $archive ((Get-Item -LiteralPath $work -Force).FullName.TrimEnd('\'))
$cap = Join-Path $work 'capitolato'
$claudeDir = Join-Path $work '.claude'
foreach ($d in @($cap,$claudeDir)) {
    New-Item -ItemType Directory -Path $d -ErrorAction Stop | Out-Null
    Assert-NoReparsePoint $d 'Nuova directory privata'
}
Copy-Item -LiteralPath (Join-Path $repoRoot 'docs') -Destination (Join-Path $cap 'docs') -Recurse -ErrorAction Stop
Copy-Item -LiteralPath (Join-Path $repoRoot 'README.md') -Destination (Join-Path $cap 'README.md') -ErrorAction Stop
Copy-Item -LiteralPath (Join-Path $repoRoot 'CLAUDE.md') -Destination (Join-Path $cap 'CLAUDE_REPOSITORY_FILM.md') -ErrorAction Stop
$docHashes = Get-ChildItem -LiteralPath $cap -Recurse -File -Force | ForEach-Object {
    '{0}  {1}' -f (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash,$_.FullName.Substring($cap.Length+1)
}
@("Revisione Git FILM: $head (clean)","Copia istruzioni: $(Get-Date -Format s)",'') + $docHashes |
    Set-Content -LiteralPath (Join-Path $cap 'MANIFEST_SHA256.txt') -Encoding UTF8
$posix = ($archive.Substring(0,1).ToLowerInvariant() + $archive.Substring(2)).Replace('\','/')
$settings = [ordered]@{
    permissions = [ordered]@{
        defaultMode                  = 'plan'
        disableBypassPermissionsMode = 'disable'
        disableAutoMode              = 'disable'
        deny = @(
            "Edit(//$posix/**)",
            'Bash(git push *)', 'Bash(curl *)', 'Bash(wget *)',
            'PowerShell(git push *)', 'PowerShell(Invoke-WebRequest *)',
            'PowerShell(Invoke-RestMethod *)', 'PowerShell(Start-BitsTransfer *)',
            'PowerShell(Remove-Item *)', 'WebFetch'
        )
        ask = @('Bash','PowerShell','Edit')
    }
}
$settings | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $claudeDir 'settings.json') -Encoding UTF8

@"
# FILM - CLAUDE locale, SOLTANTO DA COPIA PRIVATA
Leggi integralmente capitolato\CLAUDE_REPOSITORY_FILM.md, capitolato\README.md,
capitolato\docs\05_DECISIONI.md, capitolato\docs\ricerca_massiva\CLAUDE_CODE_LOCALE_DELEGA.md,
capitolato\docs\ricerca_massiva\PIPELINE_E_STATO_ANTEPRIMA.md e gli altri file in capitolato\docs.
Prima di L0 dichiara il commit $head presente in capitolato\MANIFEST_SHA256.txt; attendi conferma.
ARCHIVI COPIATI: $archive (SOLO LETTURA; mai scrivere, spostare, cancellare, rinominare o patchare).
LAVORO PRIVATO: $work (qui soltanto nuovi file, mesh lavorate e documentazione).
**Non aprire mai la cartella originale del videogioco, anche se e' accessibile sul PC.**
Nessuna rete, nessun download, nessuna pubblicazione di file Ubisoft su GitHub.
Modalita' PLAN all'avvio; ogni fase L0-L6 richiede consenso e stop.
Solo una immagine finale fotorealistica con Desmond e Lucy; nessun video di 15 minuti.
Voci esclusivamente originali italiane, senza TTS, clonazione o alterazioni.
"@ | Set-Content -LiteralPath (Join-Path $work 'CLAUDE.md') -Encoding UTF8
Write-Host "Preparazione eseguita senza aprire il gioco originale."

Write-Host "== 3: Claude PLAN (solo su richiesta) =="
if (-not $claude) { Write-Host "CLI Claude mancante: non viene avviata."; return }
if (Confirm-Step "Avviare Claude in $work, modalita' PLAN, usando SOLO gli archivi copiati?") {
    Push-Location -LiteralPath $work
    try { & $claude.Source --permission-mode plan } finally { Pop-Location }
} else { Write-Host "Avvio annullato." }
