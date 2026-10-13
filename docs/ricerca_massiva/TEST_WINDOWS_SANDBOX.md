# TEST_WINDOWS_SANDBOX — controlli statici eseguiti e prove da eseguire sul PC

**Stato:** controlli statici **ESEGUITI** · prove in Windows Sandbox **NON ESEGUITE**. Nessuna prova è da considerare superata finché l'utente non la esegue e ne riporta l'esito.
**Script:** `scripts/sandbox/genera_film_sandbox.ps1` (host), `scripts/sandbox/avvia_claude_sandbox.ps1` (solo Sandbox).

## 1. Controlli statici eseguiti (2026-10-13, sessione cloud)
| Controllo | Esito |
|---|---|
| Suite `scripts/test/Test-StaticoOpzione2.ps1` con PowerShell 7.4.6, comprese le nuove sezioni **T08** | **55/55 PASS** |
| T08a: il generatore produce un `.wsb` (funzione eseguita con percorsi di esempio) con **4** cartelle condivise, **tutte in sola lettura tranne `C:\FILM\RISULTATI`**, nessun percorso del gioco, rete attiva, audio, video e stampanti disattivati, e `LogonCommand` con `-SoloVerifica` | PASS |
| T08b: generatore. `-DryRun` precede ogni scrittura; il gioco non viene mai passato al `.wsb`; separazione a coppie tra gioco, copia, clone, risultati e configurazione; scrittura solo in ConfigDir e creazione solo di ResultsDir | PASS |
| T08c: launcher della Sandbox. Il controllo `WDAGUtilityAccount` è tra i primi; `-SoloVerifica` ritorna prima di ogni scrittura e dell'avvio; c'è la prova di scrittura negata su ARCHIVI_RO, REPO e CONFIG; ci sono le conferme `PREPARA` e `AVVIA`; l'unico download è l'installer ufficiale, solo con `-InstallaClaudeCode` e conferma `INSTALLA`, senza `Invoke-Expression`; `Edit` è negato su archivio, clone e configurazione, e `WebFetch` è negato | PASS |
| T08d: il launcher dell'host non contiene eccezioni per la Sandbox | PASS |
| Verifica della suite con errori introdotti di proposito: `ReadOnly=false` sul clone; scrittura prima di `-SoloVerifica` | **Entrambi rilevati** |
| PSScriptAnalyzer 1.23.0: regole standard e compatibilità PowerShell 5.1/7.0 (sintassi, comandi, tipi) | Nessuna segnalazione; `Invoke-Expression` sostituito |
| Codifica | Script solo ASCII |

## 2. Prove sul PC — DA ESEGUIRE (in quest'ordine)
| ID | Dove | Azione | Esito atteso | Stato |
|---|---|---|---|---|
| TS-01 | host | `powershell.exe -NoProfile -File .\docs\ricerca_massiva\scripts\test\Test-StaticoOpzione2.ps1` (e `pwsh`, se presente) | «0 falliti» | NON ESEGUITO |
| TS-02 | host | `genera_film_sandbox.ps1 … -DryRun` (comando in SANDBOX_WINDOWS.md §3) | Copia e clone verificati; `.wsb` mostrato; «DRY RUN: nessun file scritto»; `D:\FILM_SANDBOX_CONFIG` **non** creata | NON ESEGUITO |
| TS-03 | host | Come TS-02 ma con `-ResultsDir` dentro `D:\Games\Assassin's Creed II` oppure `-ConfigDir` uguale a `-ArchiveDir` | Rifiuto «Percorsi non separati», nessuna scrittura | NON ESEGUITO |
| TS-04 | host | Esecuzione reale con `GENERA` | Creati `FILM_SANDBOX.wsb`, `FILM_SANDBOX.json` e `CAPITOLATO_SHA256.txt`; `D:\FILM_RISULTATI_SANDBOX` presente; gioco, copia e clone **invariati** (`git status` vuoto) | NON ESEGUITO |
| TS-05 | Sandbox | Doppio clic su `FILM_SANDBOX.wsb` | Si apre la finestra di verifica; S1–S7 OK; «VERIFICA COMPLETATA… Claude NON e' stato avviato» | NON ESEGUITO |
| TS-06 | Sandbox | Prova manuale: creare una cartella e un file in `C:\FILM\ARCHIVI_RO`, `C:\FILM\REPO` e `C:\FILM\CONFIG` | **Accesso negato** in tutte e tre | NON ESEGUITO |
| TS-07 | Sandbox | Prova manuale: creare un file di testo in `C:\FILM\RISULTATI`, poi chiudere la Sandbox | Il file è presente sull'host in `D:\FILM_RISULTATI_SANDBOX` | NON ESEGUITO |
| TS-08 | Sandbox | Esplora file della Sandbox: cercare `D:\` o la cartella del gioco | Non esistono (solo l'unità C: della Sandbox) | NON ESEGUITO |
| TS-09 | host | Eseguire `avvia_claude_sandbox.ps1 -ExpectedCommit <hash> -SoloVerifica` **sull'host** | Rifiuto immediato «funziona SOLO dentro Windows Sandbox» | NON ESEGUITO |
| TS-10 | Sandbox | Script con `-InstallaClaudeCode`; rispondere **no** a `INSTALLA` | Installer scaricato e mostrato (dimensione, SHA256), non eseguito; STOP | NON ESEGUITO |
| TS-11 | Sandbox | Script con `-InstallaClaudeCode`: `INSTALLA`, `PREPARA`, **no** ad `AVVIA` | `claude --version` funziona; `C:\FILM\LAVORO\CLAUDE.md` e `.claude\settings.json` creati; Claude **non** avviato. Se `ProtectedClient=Enable` impedisce installazione o login, annotarlo e rigenerare con `-ProtectedClient Disable` | NON ESEGUITO |
| TS-12 | Sandbox | Solo dopo la tua decisione: `AVVIA`, accesso con il tuo account Claude, `/permissions` | Modalità `plan`; regole `deny` visibili senza avvisi; Claude dichiara il commit e attende conferma prima di L0 | NON ESEGUITO |
| TS-13 | Sandbox | Chiedere a Claude, in `plan`, di **descrivere** un tentativo di scrittura in `C:\FILM\ARCHIVI_RO`, senza eseguirlo; facoltativamente approvare un `Edit` di prova su un file di `C:\FILM\REPO` | Regola `deny` di Claude e, in ogni caso, accesso negato dalla mappatura | NON ESEGUITO |

## 3. Criterio per procedere
**TS-01…TS-11 superati** e TS-04 senza modifiche a gioco, copia e clone: allora, solo con la tua decisione, si passa a TS-12 e poi a L0. Qualsiasi esito diverso → **STOP**; il messaggio va riportato nella PR (solo testo, nessun file del gioco).
