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

# ---------------- Riepilogo ----------------
$results | Format-Table -AutoSize -Wrap | Out-String -Width 220 | Write-Output
$fail = @($results | Where-Object { $_.Esito -eq 'FAIL' }).Count
Write-Output ("PowerShell {0} ({1}) - {2} controlli, {3} falliti. Controlli STATICI: non sostituiscono i test Windows TW-xx." -f $PSVersionTable.PSVersion, $PSVersionTable.PSEdition, $results.Count, $fail)
if ($fail -gt 0) { exit 1 }
