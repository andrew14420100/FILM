<#
.SYNOPSIS
  Controlli STATICI degli script dell'opzione 2 (FILM, PR #14). Compatibile con Windows PowerShell 5.1
  e PowerShell 7. Non esegue gli script, non tocca file, ACL o il gioco: analizza solo il codice (AST)
  e verifica la risoluzione dei parametri con uno stub che contiene SOLO il blocco param().

.DESCRIPTION
  T01 Sintassi dei tre script (parser PowerShell).
  T02 Solo caratteri ASCII (lettura corretta anche in Windows PowerShell 5.1).
  T03 Risoluzione dei parameter set di prepara_copia_privata_acii.ps1 (Prepara / Proteggi / Ripristina),
      inclusi i casi che devono FALLIRE.
  T04 -DryRun: nessun comando che modifica file/ACL prima del ritorno anticipato (Prepara e Proteggi).
  T05 Il gioco originale non e' mai destinazione di comandi che modificano (scrittura, ACL, attributi).
  T06 Le ACL vengono cambiate solo su elementi della copia ($archive, suoi elementi, ripristino validato).
  T07 Il launcher contiene i rifiuti per account/permessi non sicuri.
  Questi controlli NON sostituiscono i test reali TW-xx su Windows (TEST_WINDOWS_OPZIONE2.md).

.EXAMPLE
  powershell.exe -NoProfile -NonInteractive -File .\docs\ricerca_massiva\scripts\test\Test-StaticoOpzione2.ps1
  pwsh -NoProfile -NonInteractive -File ./docs/ricerca_massiva/scripts/test/Test-StaticoOpzione2.ps1
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$scriptsDir = Split-Path -Parent $PSScriptRoot
$prepara = Join-Path $scriptsDir 'prepara_copia_privata_acii.ps1'
$launcher = Join-Path $scriptsDir 'avvia_claude_locale.ps1'
$inventario = Join-Path $scriptsDir 'inventario_acii_readonly.ps1'
$results = New-Object System.Collections.ArrayList

function Add-Result([string]$id, [string]$name, [bool]$ok, [string]$detail) {
    [void]$results.Add([pscustomobject]@{ Test = $id; Descrizione = $name; Esito = $(if ($ok) { 'PASS' } else { 'FAIL' }); Dettaglio = $detail })
}
function Get-Ast([string]$path) {
    $t = $null; $e = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$t, [ref]$e)
    return [pscustomobject]@{ Ast = $ast; Errors = $e }
}

# Comandi che modificano file system o ACL (cmdlet e funzioni interne degli script).
$Mutating = @('New-Item', 'Copy-Item', 'Move-Item', 'Remove-Item', 'Rename-Item', 'Set-Content', 'Add-Content', 'Out-File',
    'Set-Acl', 'Set-ItemProperty', 'Clear-Content', 'Export-Csv',
    'Save-AclBackup', 'Restore-AclBackup', 'Set-ProtectedAcl', 'Write-Manifest', 'icacls', 'icacls.exe', 'takeown', 'takeown.exe')

function Get-MutatingCalls($node) {
    $node.FindAll({ param($n)
            ($n -is [System.Management.Automation.Language.CommandAst] -and $Mutating -contains $n.GetCommandName()) -or
            ($n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -match '\.IsReadOnly$')
        }, $true)
}
function Get-NamedArgText($cmd, [string]$name) {
    $els = $cmd.CommandElements
    for ($i = 0; $i -lt $els.Count; $i++) {
        $el = $els[$i]
        if ($el -is [System.Management.Automation.Language.CommandParameterAst] -and $el.ParameterName -eq $name) {
            if ($el.Argument) { return $el.Argument.Extent.Text }
            if ($i + 1 -lt $els.Count) { return $els[$i + 1].Extent.Text }
        }
    }
    return $null
}

# ---------------- T01 / T02 ----------------
$parsed = @{}
foreach ($p in @($prepara, $launcher, $inventario)) {
    $r = Get-Ast $p
    $parsed[$p] = $r
    Add-Result 'T01' "Sintassi $(Split-Path -Leaf $p)" ($r.Errors.Count -eq 0) ("errori: {0}" -f $r.Errors.Count)
    $bytes = [System.IO.File]::ReadAllBytes($p)
    $nonAscii = @($bytes | Where-Object { $_ -gt 127 }).Count
    Add-Result 'T02' "Solo ASCII $(Split-Path -Leaf $p)" ($nonAscii -eq 0) ("byte non ASCII: {0}" -f $nonAscii)
}
$pAst = $parsed[$prepara].Ast
$lAst = $parsed[$launcher].Ast

# ---------------- T03 parameter set ----------------
$pbText = $pAst.ParamBlock.Extent.Text
if ($pbText -notmatch 'CmdletBinding') { $pbText = (($pAst.ParamBlock.Attributes | ForEach-Object { $_.Extent.Text }) -join "`n") + "`n" + $pbText }
$stub = [scriptblock]::Create($pbText + "`n" + '$PSCmdlet.ParameterSetName')
$cases = @(
    @{ Args = @{ GameDir = 'g'; ArchiveDir = 'a' }; Expect = 'Prepara' },
    @{ Args = @{ GameDir = 'g'; ArchiveDir = 'a'; ProtectCopyForUser = 'u'; DryRun = $true }; Expect = 'Prepara' },
    @{ Args = @{ ProtectExistingCopy = $true; ArchiveDir = 'a'; ProtectCopyForUser = 'u' }; Expect = 'Proteggi' },
    @{ Args = @{ ProtectExistingCopy = $true; ArchiveDir = 'a'; ProtectCopyForUser = 'u'; DryRun = $true }; Expect = 'Proteggi' },
    @{ Args = @{ ProtectExistingCopy = $true; ArchiveDir = 'a'; ClaudeAccount = 'u' }; Expect = 'Proteggi' },
    @{ Args = @{ ArchiveDir = 'a'; RipristinaAcl = $true }; Expect = 'Ripristina' },
    # Senza -GameDir e senza switch di modalita': il binding sceglie Prepara, e il corpo dello script si ferma (vedi T03b).
    @{ Args = @{ ArchiveDir = 'a'; ProtectCopyForUser = 'u' }; Expect = 'Prepara' },
    @{ Args = @{ ProtectExistingCopy = $true; GameDir = 'g'; ArchiveDir = 'a'; ProtectCopyForUser = 'u' }; Expect = 'ERRORE' },
    @{ Args = @{ ProtectExistingCopy = $true; ArchiveDir = 'a'; RipristinaAcl = $true }; Expect = 'ERRORE' },
    @{ Args = @{ GameDir = 'g'; ArchiveDir = 'a'; RipristinaAcl = $true }; Expect = 'ERRORE' },
    @{ Args = @{ ArchiveDir = 'a'; RipristinaAcl = $true; DryRun = $true }; Expect = 'ERRORE' },
    @{ Args = @{ ProtectExistingCopy = $true; ArchiveDir = 'a'; ProtectCopyForUser = 'u'; IncludeHideout = $true }; Expect = 'ERRORE' }
)
foreach ($c in $cases) {
    $a = $c.Args
    $label = ($a.Keys | Sort-Object | ForEach-Object { '-' + $_ }) -join ' '
    try { $got = & $stub @a } catch { $got = 'ERRORE' }
    Add-Result 'T03' "Parametri: $label" ($got -eq $c.Expect) ("atteso {0}, ottenuto {1}" -f $c.Expect, $got)
}
# T03b: in modalita' Prepara senza -GameDir il corpo si ferma PRIMA di qualsiasi modifica.
$top = @($pAst.EndBlock.Statements)
$idxGameCheck = -1; $idxFirstMut = -1
for ($i = 0; $i -lt $top.Count; $i++) {
    $st = $top[$i]
    if ($st -is [System.Management.Automation.Language.FunctionDefinitionAst]) { continue }
    if ($idxGameCheck -lt 0 -and $st -is [System.Management.Automation.Language.IfStatementAst] -and $st.Clauses[0].Item1.Extent.Text -match '^\(?\s*-not\s+\$GameDir') { $idxGameCheck = $i }
    $isModeBranch = ($st -is [System.Management.Automation.Language.IfStatementAst] -and $st.Clauses[0].Item1.Extent.Text -match 'ParameterSetName')
    if (-not $isModeBranch -and $idxFirstMut -lt 0 -and @(Get-MutatingCalls $st).Count -gt 0) { $idxFirstMut = $i }
}
Add-Result 'T03b' 'Prepara senza -GameDir si ferma prima di ogni modifica' ($idxGameCheck -ge 0 -and $idxGameCheck -lt $idxFirstMut) ("controllo GameDir @{0}, prima modifica @{1}" -f $idxGameCheck, $idxFirstMut)

# ---------------- T04 DryRun ----------------
$idxDry = -1
for ($i = 0; $i -lt $top.Count; $i++) {
    $st = $top[$i]
    if ($st -is [System.Management.Automation.Language.IfStatementAst] -and $st.Clauses[0].Item1.Extent.Text -eq '$DryRun' -and $st.Clauses[0].Item2.Extent.Text -match '\breturn\b') { $idxDry = $i; break }
}
$mutBefore = @()
for ($i = 0; $i -lt $idxDry; $i++) {
    $st = $top[$i]
    if ($st -is [System.Management.Automation.Language.FunctionDefinitionAst]) { continue }
    $isModeBranch = ($st -is [System.Management.Automation.Language.IfStatementAst] -and $st.Clauses[0].Item1.Extent.Text -match 'ParameterSetName')
    if ($isModeBranch) { continue }   # Ripristina (senza DryRun) e Proteggi (verificato sotto) terminano con return
    $mutBefore += @(Get-MutatingCalls $st | ForEach-Object { $_.Extent.Text })
}
Add-Result 'T04' 'Prepara -DryRun: nessuna modifica prima del ritorno' ($idxDry -ge 0 -and $mutBefore.Count -eq 0) ("return DryRun @{0}; modifiche prima: {1}" -f $idxDry, ($mutBefore -join ' | '))

$fnProtect = $pAst.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Invoke-ProtectCopy' }, $true)
$pst = @($fnProtect.Body.EndBlock.Statements)
$idxPrev = -1
for ($i = 0; $i -lt $pst.Count; $i++) {
    if ($pst[$i] -is [System.Management.Automation.Language.IfStatementAst] -and $pst[$i].Clauses[0].Item1.Extent.Text -eq '$Preview' -and $pst[$i].Clauses[0].Item2.Extent.Text -match '\breturn\b') { $idxPrev = $i; break }
}
$mutBeforeP = @()
for ($i = 0; $i -lt $idxPrev; $i++) { $mutBeforeP += @(Get-MutatingCalls $pst[$i] | ForEach-Object { $_.Extent.Text }) }
Add-Result 'T04' 'Proteggi -DryRun (Preview): nessuna modifica prima del ritorno' ($idxPrev -ge 0 -and $mutBeforeP.Count -eq 0) ("return Preview @{0}; modifiche prima: {1}" -f $idxPrev, ($mutBeforeP -join ' | '))
$protBranch = $top | Where-Object { $_ -is [System.Management.Automation.Language.IfStatementAst] -and $_.Clauses[0].Item1.Extent.Text -match "'Proteggi'" } | Select-Object -First 1
$passesPreview = ($protBranch -and $protBranch.Extent.Text -match 'Invoke-ProtectCopy[^\r\n]*-Preview:\$DryRun')
$otherMutInProt = @(Get-MutatingCalls $protBranch | ForEach-Object { $_.Extent.Text })
Add-Result 'T04' 'Proteggi passa -DryRun a Invoke-ProtectCopy e non modifica altro' ($passesPreview -and $otherMutInProt.Count -eq 0) ("-Preview:`$DryRun={0}; altre modifiche: {1}" -f $passesPreview, ($otherMutInProt -join ' | '))

# ---------------- T05 gioco originale mai modificato ----------------
$gamePattern = '\$game\b|\$GameDir\b|\$f\.Path\b|\$from\b'
$bad = @()
foreach ($cmd in @(Get-MutatingCalls $pAst)) {
    if ($cmd -is [System.Management.Automation.Language.AssignmentStatementAst]) {
        if ($cmd.Left.Extent.Text -match $gamePattern) { $bad += $cmd.Extent.Text }; continue
    }
    $name = $cmd.GetCommandName()
    $targets = @()
    if ($name -eq 'Copy-Item' -or $name -eq 'Move-Item') { $targets += Get-NamedArgText $cmd 'Destination' }
    else {
        foreach ($pn in @('LiteralPath', 'Path')) { $targets += Get-NamedArgText $cmd $pn }
        $pos = @($cmd.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] })
        if ($pos.Count -gt 0) { $targets += $pos[0].Extent.Text }
    }
    foreach ($t in $targets) { if ($t -and $t -match $gamePattern) { $bad += $cmd.Extent.Text } }
}
Add-Result 'T05' 'Nessun comando di modifica ha come destinazione il gioco originale' ($bad.Count -eq 0) ($bad -join ' | ')

# ---------------- T06 ACL solo sulla copia ----------------
$aclTargets = @()
foreach ($cmd in @($pAst.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and @('Set-Acl', 'icacls', 'icacls.exe', 'takeown', 'takeown.exe') -contains $n.GetCommandName() }, $true))) {
    $aclTargets += [string](Get-NamedArgText $cmd 'LiteralPath')
}
$allowed = @('$archive', '$target', '$it.FullName')
$notAllowed = @($aclTargets | Where-Object { $allowed -notcontains $_ })
$restoreFn = $pAst.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Restore-AclBackup' }, $true)
$restoreGuard = ($restoreFn.Extent.Text -match 'Elemento fuori dalla copia') -and ($restoreFn.Extent.Text -match "appartiene a un'altra cartella")
$itSources = @($pAst.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Get-ChildItem' }, $true) | ForEach-Object { Get-NamedArgText $_ 'LiteralPath' } | Where-Object { $_ -ne '$archive' -and $_ -ne '$bdir' })
Add-Result 'T06' 'Set-Acl solo su $archive / elementi della copia / ripristino validato' ($aclTargets.Count -gt 0 -and $notAllowed.Count -eq 0 -and $restoreGuard -and $itSources.Count -eq 0) ("destinazioni: {0}; non ammesse: {1}; guardia ripristino: {2}; Get-ChildItem fuori copia: {3}" -f ($aclTargets -join ','), ($notAllowed -join ','), $restoreGuard, ($itSources -join ','))
$noDeny = -not ($pAst.Extent.Text -match "AccessControlType\]::Deny|'Deny'")
Add-Result 'T06' 'Nessuna ACE Deny aggiunta' $noDeny ''

# ---------------- T07 launcher: rifiuto account non sicuri ----------------
$lt = $lAst.Extent.Text
$checks = [ordered]@{
    'Token elevato'                        = 'IsInRole\(\[Security\.Principal\.WindowsBuiltInRole\]::Administrator\)'
    'Membro Administrators (whoami)'       = "S-1-5-32-544"
    'Gruppi privilegiati (Backup Op., ...)' = "S-1-5-32-551"
    'Privilegi pericolosi (whoami /priv)'  = 'SeBackupPrivilege'
    'SID uguale a ClaudeAccountSid'        = 'ClaudeAccountSid'
    'Diverso dal preparatore'              = 'PreparerSid'
    'Account non proprietario'             = 'proprietario di'
    'Diritti di modifica sulla copia'      = '\$WriteMask'
    'Diritti critici sul genitore'         = '0xD0040'
    'DACL protetta (no ereditarieta)'      = 'AreAccessRulesProtected'
    'Manifest V2 + SHA256'                 = "FILM_PRIVATE_ACII_COPY_V2"
}
foreach ($k in $checks.Keys) { Add-Result 'T07' "Launcher: $k" ($lt -match $checks[$k]) '' }
$throwsBeforeWrites = $true
$lTop = @($lAst.EndBlock.Statements)
$idxConfirm = -1
for ($i = 0; $i -lt $lTop.Count; $i++) {
    if ($lTop[$i] -is [System.Management.Automation.Language.FunctionDefinitionAst]) { continue }
    $calls = $lTop[$i].FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'Confirm-Step' }, $true)
    if (@($calls).Count -gt 0) { $idxConfirm = $i; break }
}
$throwCount = 0
for ($i = 0; $i -lt $idxConfirm; $i++) { $throwCount += @($lTop[$i].FindAll({ param($n) $n -is [System.Management.Automation.Language.ThrowStatementAst] }, $true)).Count }
for ($i = 0; $i -lt $idxConfirm; $i++) {
    if ($lTop[$i] -is [System.Management.Automation.Language.FunctionDefinitionAst]) { continue }
    if (@(Get-MutatingCalls $lTop[$i]).Count -gt 0) { $throwsBeforeWrites = $false }
}
Add-Result 'T07' 'Launcher: tutti i controlli (throw) precedono la prima conferma e qualsiasi scrittura' ($idxConfirm -gt 0 -and $throwsBeforeWrites -and $throwCount -ge 20) ("prima conferma @{0}; throw prima della conferma: {1}" -f $idxConfirm, $throwCount)

# ---------------- T08 modalita' Windows Sandbox ----------------
$sbDir = Join-Path $scriptsDir 'sandbox'
$gen = Join-Path $sbDir 'genera_film_sandbox.ps1'
$sbl = Join-Path $sbDir 'avvia_claude_sandbox.ps1'
foreach ($p in @($gen, $sbl)) {
    $r = Get-Ast $p
    $parsed[$p] = $r
    Add-Result 'T08' "Sintassi $(Split-Path -Leaf $p)" ($r.Errors.Count -eq 0) ("errori: {0}" -f $r.Errors.Count)
    $nonAscii = @([System.IO.File]::ReadAllBytes($p) | Where-Object { $_ -gt 127 }).Count
    Add-Result 'T08' "Solo ASCII $(Split-Path -Leaf $p)" ($nonAscii -eq 0) ("byte non ASCII: {0}" -f $nonAscii)
}
$gAst = $parsed[$gen].Ast
$sAst = $parsed[$sbl].Ast

# T08a: generazione .wsb (funzione pura eseguita con percorsi di esempio).
$defs = @($gAst.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and @('ConvertTo-XmlText', 'New-FilmWsbXml') -contains $n.Name }, $true) | ForEach-Object { $_.Extent.Text })
$spDef = $gAst.Find({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -eq '$SandboxPaths' }, $true).Extent.Text
$callText = "New-FilmWsbXml 'D:\FILM_ARCHIVI_RO' 'D:\FILM' 'D:\FILM_SANDBOX_CONFIG' 'D:\FILM_RISULTATI_SANDBOX' '0123456789abcdef0123456789abcdef01234567' 8192 'Enable' 'Disable' 'Disable'"
$wsbText = & ([scriptblock]::Create($spDef + "`n" + ($defs -join "`n") + "`n" + $callText))
$x = [xml]$wsbText
$maps = @($x.Configuration.MappedFolders.MappedFolder)
$roOk = ($maps.Count -eq 4)
foreach ($mm in $maps) {
    $expRo = 'true'; if ($mm.SandboxFolder -eq 'C:\FILM\RISULTATI') { $expRo = 'false' }
    if ($mm.ReadOnly -ne $expRo) { $roOk = $false }
    if ($mm.HostFolder -match 'Games|Assassin') { $roOk = $false }
}
$writable = @($maps | Where-Object { $_.ReadOnly -eq 'false' } | ForEach-Object { $_.SandboxFolder })
Add-Result 'T08a' '.wsb: 4 cartelle, sola lettura tranne RISULTATI, gioco assente' ($roOk -and $writable.Count -eq 1 -and $writable[0] -eq 'C:\FILM\RISULTATI') ("scrivibili: {0}" -f ($writable -join ','))
$netOk = ($x.Configuration.Networking -eq 'Enable' -and $x.Configuration.AudioInput -eq 'Disable' -and $x.Configuration.VideoInput -eq 'Disable' -and $x.Configuration.PrinterRedirection -eq 'Disable')
Add-Result 'T08a' '.wsb: rete attiva (richiesta), audio/video/stampanti disattivati' $netOk ''
Add-Result 'T08a' '.wsb: il LogonCommand esegue solo la VERIFICA' ([string]$x.Configuration.LogonCommand.Command -match '-SoloVerifica') ([string]$x.Configuration.LogonCommand.Command)

# T08b: generatore - DryRun prima di ogni scrittura; separazione a coppie con il gioco; gioco mai passato al .wsb.
$gTop = @($gAst.EndBlock.Statements)
$iDry = -1; $iMut = -1
for ($i = 0; $i -lt $gTop.Count; $i++) {
    $st = $gTop[$i]
    if ($st -is [System.Management.Automation.Language.FunctionDefinitionAst]) { continue }
    if ($iDry -lt 0 -and $st -is [System.Management.Automation.Language.IfStatementAst] -and $st.Clauses[0].Item1.Extent.Text -eq '$DryRun') { $iDry = $i }
    if ($iMut -lt 0 -and @(Get-MutatingCalls $st).Count -gt 0) { $iMut = $i }
}
Add-Result 'T08b' 'Generatore -DryRun: nessuna scrittura prima del ritorno' ($iDry -ge 0 -and $iDry -lt $iMut) ("DryRun @{0}, prima scrittura @{1}" -f $iDry, $iMut)
$wsbCall = $gAst.Find({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'New-FilmWsbXml' }, $true)
Add-Result 'T08b' "Generatore: il gioco non e' mai passato al file .wsb" (-not ($wsbCall.Extent.Text -match '\$game\b')) $wsbCall.Extent.Text
$gText = $gAst.Extent.Text
Add-Result 'T08b' 'Generatore: separazione a coppie di gioco/copia/clone/risultati/config' (($gText -match "'gioco originale' = \`$game") -and ($gText -match 'Assert-Separated \$all\[\$keys\[\$i\]\] \$all\[\$keys\[\$j\]\]')) ''
$genWrites = @()
foreach ($cmd in @(Get-MutatingCalls $gAst)) {
    if ($cmd -is [System.Management.Automation.Language.AssignmentStatementAst]) { continue }
    $t = [string](Get-NamedArgText $cmd 'LiteralPath'); if (-not $t) { $t = [string](Get-NamedArgText $cmd 'Path') }
    if ($t -notmatch '^\$cfg$|^\$res$|^\(Join-Path \$cfg ') { $genWrites += $cmd.Extent.Text }
}
Add-Result 'T08b' 'Generatore: scrive solo in ConfigDir e crea solo ResultsDir' ($genWrites.Count -eq 0) ($genWrites -join ' | ')

# T08c: launcher Sandbox - rifiuto fuori Sandbox, prove di sola lettura, -SoloVerifica senza scritture, conferme.
$sTop = @($sAst.EndBlock.Statements | Where-Object { $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] })
$iUser = -1; $iSolo = -1; $iFirstWrite = -1; $iClaude = -1
for ($i = 0; $i -lt $sTop.Count; $i++) {
    $t = $sTop[$i].Extent.Text
    if ($iUser -lt 0 -and $t -match 'WDAGUtilityAccount') { $iUser = $i }
    if ($iSolo -lt 0 -and $sTop[$i] -is [System.Management.Automation.Language.IfStatementAst] -and $sTop[$i].Clauses[0].Item1.Extent.Text -eq '$SoloVerifica') { $iSolo = $i }
    if ($iFirstWrite -lt 0 -and @(Get-MutatingCalls $sTop[$i]).Count -gt 0) { $iFirstWrite = $i }
    if ($iClaude -lt 0 -and $t -match '--permission-mode plan') { $iClaude = $i }
}
Add-Result 'T08c' 'Launcher Sandbox: controllo WDAGUtilityAccount tra i primi controlli' ($iUser -ge 0 -and $iUser -le 4) ("@{0}" -f $iUser)
Add-Result 'T08c' "Launcher Sandbox: -SoloVerifica ritorna prima di ogni scrittura e dell'avvio" ($iSolo -ge 0 -and $iSolo -lt $iFirstWrite -and $iSolo -lt $iClaude) ("SoloVerifica @{0}, prima scrittura @{1}, avvio @{2}" -f $iSolo, $iFirstWrite, $iClaude)
$sT = $sAst.Extent.Text
Add-Result 'T08c' 'Launcher Sandbox: prova di scrittura negata su ARCHIVI_RO, REPO, CONFIG' (($sT -match 'foreach \(\$d in @\(\$expectedPaths\.Archive, \$expectedPaths\.Repo, \$expectedPaths\.Config\)\)') -and ($sT -match 'Test-WriteDenied \$d')) ''
Add-Result 'T08c' 'Launcher Sandbox: conferme PREPARA e AVVIA prima di scrivere e avviare' (($sT -match "-cne 'PREPARA'") -and ($sT -match "-cne 'AVVIA'")) ''
$iex = @($sAst.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and @('Invoke-Expression', 'iex') -contains $n.GetCommandName() }, $true))
$dl = @($sAst.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and @('Invoke-WebRequest', 'Invoke-RestMethod', 'Start-BitsTransfer', 'iwr', 'irm') -contains $n.GetCommandName() }, $true))
$branch = $sAst.Find({ param($n) $n -is [System.Management.Automation.Language.IfStatementAst] -and $n.Extent.Text -match 'elseif \(\$InstallaClaudeCode -and -not \$SoloVerifica\)' }, $true)
$dlInBranch = $branch -and (@($dl | Where-Object { $branch.Extent.StartOffset -le $_.Extent.StartOffset -and $_.Extent.EndOffset -le $branch.Extent.EndOffset }).Count -eq $dl.Count)
$iexGuard = ($iex.Count -eq 0) -and ($dl.Count -eq 1) -and $dlInBranch -and ($sT -match "-cne 'INSTALLA'") -and ($sT -match "https://claude\.ai/install\.ps1")
Add-Result 'T08c' 'Launcher Sandbox: unico download = installer ufficiale, solo con -InstallaClaudeCode e conferma INSTALLA; niente Invoke-Expression' $iexGuard ("Invoke-Expression: {0}; download: {1}" -f $iex.Count, $dl.Count)
Add-Result 'T08c' 'Launcher Sandbox: Edit negato su archivio, clone e config; WebFetch negato' (($sT -match 'Edit\(//c/FILM/ARCHIVI_RO/\*\*\)') -and ($sT -match 'Edit\(//c/FILM/REPO/\*\*\)') -and ($sT -match 'Edit\(//c/FILM/CONFIG/\*\*\)') -and ($sT -match "'WebFetch'")) ''
# T08d: il launcher dell'host non contiene eccezioni per la Sandbox (controlli non disattivati).
Add-Result 'T08d' 'Launcher host invariato: nessuna eccezione Sandbox' (-not ($lt -match 'WDAGUtilityAccount|Sandbox')) ''

# ---------------- Riepilogo ----------------
$results | Format-Table -AutoSize -Wrap | Out-String -Width 220 | Write-Output
$fail = @($results | Where-Object { $_.Esito -eq 'FAIL' }).Count
Write-Output ("PowerShell {0} ({1}) - {2} controlli, {3} falliti. Controlli STATICI: non sostituiscono i test Windows TW-xx." -f $PSVersionTable.PSVersion, $PSVersionTable.PSEdition, $results.Count, $fail)
if ($fail -gt 0) { exit 1 }
