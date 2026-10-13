# TEST_WINDOWS_OPZIONE2 — controlli statici eseguiti e test reali da eseguire

**Stato:** controlli statici **ESEGUITI** (sotto) · test su Windows **NON ESEGUITI** · nessun test reale è da considerare superato finché l'utente non lo esegue e ne riporta l'esito.
**Script interessati:** `scripts/prepara_copia_privata_acii.ps1`, `scripts/avvia_claude_locale.ps1`, `scripts/inventario_acii_readonly.ps1`.

## 1. Controlli statici eseguiti nella sessione cloud (2026-10-13)
| Controllo | Strumento | Esito |
|---|---|---|
| Sintassi dei tre script | Parser di PowerShell 7.4.6 (`[Parser]::ParseFile`), release ufficiale per Linux con SHA256 confrontato con `hashes.sha256` della release | **OK**, nessun errore |
| Compilazione del codice C# `FilmAuthz` (AuthZ, preparazione) e `FilmAccess` (AccessCheck, launcher) | `Add-Type` in PowerShell 7.4.6 | **Compila**. Le chiamate a `authz.dll` e `advapi32.dll` **non** sono state eseguite: esistono solo su Windows |
| Analisi statica | PSScriptAnalyzer 1.23.0 (PSGallery) | Nessuna segnalazione di gravità Error. Corretti: confronto con `$null` e carattere non ASCII. Restano solo regole di stile accettate (`Write-Host` per uso interattivo, nomi plurali, parametri posizionali, `ShouldProcess`) e un falso positivo (`RipristinaAcl` è usato tramite il parameter set) |
| Codifica | Ricerca di caratteri non ASCII | **Tutti e tre gli script sono solo ASCII**. Evita letture errate in Windows PowerShell 5.1, che legge i file UTF-8 senza BOM come ANSI |

Comandi per ripetere i controlli statici su Windows (PowerShell 5.1 o 7):
```powershell
foreach ($f in Get-ChildItem .\docs\ricerca_massiva\scripts\*.ps1) {
  $t=$null; $e=$null
  [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName,[ref]$t,[ref]$e)
  "{0}: {1} errori" -f $f.Name, $e.Count
}
# facoltativo, se PSScriptAnalyzer e' installato:
Invoke-ScriptAnalyzer -Path .\docs\ricerca_massiva\scripts -ExcludeRule PSAvoidUsingWriteHost
```

## 2. Preparazione dell'ambiente di test (a cura dell'utente)
- Account **preparatore**: quello abituale dell'utente, in PowerShell **non elevato**.
- Account **Claude**: locale, **standard**, dedicato (es. `film_claude`), creato da un amministratore.
- Prima di ogni test che crea `D:\FILM_ARCHIVI_RO`, la cartella **non deve esistere**. Per ripetere un test, eliminarla dall'account preparatore.
- **Riferimento d'integrità dell'originale**, da salvare prima e dopo i test per confronto (sola lettura, file privato fuori dal repository):
  ```powershell
  Get-Item "D:\Games\Assassin's Creed II\DataPC_Abstergo.forge" | Select-Object Length, LastWriteTime
  (Get-Acl "D:\Games\Assassin's Creed II").Sddl | Out-File "$env:USERPROFILE\film_sddl_gioco_prima.txt"
  ```

## 3. Test reali su Windows — DA ESEGUIRE
Esito atteso → da annotare in privato e riassumere nella PR (solo testo, nessun file del gioco).

| ID | Account | Azione | Esito atteso | Stato |
|---|---|---|---|---|
| TW-01 | preparatore | Controllo sintassi del §1 | 0 errori per tutti gli script | NON ESEGUITO |
| TW-02 | preparatore | `prepara… -ProtectCopyForUser film_claude -DryRun` | Riepilogo con SID; messaggio «DRY RUN»; **`D:\FILM_ARCHIVI_RO` non esiste** dopo l'esecuzione | NON ESEGUITO |
| TW-03 | preparatore (sessione **elevata**) | Stesso comando | Rifiuto «Sessione elevata», nessuna creazione | NON ESEGUITO |
| TW-04 | preparatore | `-ProtectCopyForUser` = account preparatore | Rifiuto «deve essere DIVERSO» | NON ESEGUITO |
| TW-05 | preparatore | `-ProtectCopyForUser` di un amministratore o inesistente | Rifiuto, nessuna creazione | NON ESEGUITO |
| TW-06 | preparatore | `-ArchiveDir` dentro `D:\Games\Assassin's Creed II` o uguale a `-WorkDir` | Rifiuto «Percorsi non separati» | NON ESEGUITO |
| TW-07 | preparatore | Esecuzione reale, risposta diversa da `COPIA` | «Annullato. Nessuna modifica», cartella assente | NON ESEGUITO |
| TW-07b | preparatore | Esecuzione **senza** `-ProtectCopyForUser`, `COPIA` | Copia e manifest creati, avviso «copia NON protetta», ACL della copia **ereditate** e invariate; il launcher di `film_claude` va in STOP | NON ESEGUITO |
| TW-07c | preparatore | Con `-ProtectCopyForUser`: `COPIA`, poi risposta diversa da `PROTEGGI` | Mostrati permessi attuali e proposti; «Permessi NON modificati» | NON ESEGUITO |
| TW-08 | preparatore | Esecuzione reale con `COPIA` e poi `PROTEGGI` (oppure modalità `-ArchiveDir … -ProtectCopyForUser film_claude` su copia esistente) | Copia creata, «Copiato e verificato SHA256», backup ACL creato in `%LOCALAPPDATA%\FILM\acl_backup\…`, verifica AuthZ e impronte «OK», «Claude NON e' stato avviato» | NON ESEGUITO |
| TW-09 | preparatore | `icacls D:\FILM_ARCHIVI_RO` e `icacls D:\FILM_ARCHIVI_RO\DataPC_Abstergo.forge` | Nessuna voce ereditata dal genitore; `film_claude:(RX)` (sulla cartella `(OI)(CI)(RX)`); SYSTEM, Administrators e preparatore `(F)` | NON ESEGUITO |
| TW-10 | preparatore | Confronto con il riferimento del §2 | `Length`, `LastWriteTime` e SDDL della cartella del gioco **identici** a prima | NON ESEGUITO |
| TW-11 | preparatore | Esplora risorse → Accesso effettivo per `film_claude` su cartella e file | Solo lettura, esecuzione ed elenco | NON ESEGUITO |
| TW-12 | **film_claude** | Tentativi manuali, **senza Claude**: creare un file in `D:\FILM_ARCHIVI_RO`, rinominare o cancellare `DataPC_Abstergo.forge`, rinominare la cartella, `icacls … /grant film_claude:F` | Tutti **Accesso negato** | NON ESEGUITO |
| TW-13 | film_claude | `avvia_claude_locale.ps1 -ArchiveDir … -WorkDir D:\FILM_PRIVATO -ExpectedCommit <hash>`, rispondendo **no** alla prima conferma | Tutti i controlli 1a–1f superati; nessun file creato in `D:\FILM_PRIVATO`; Claude **non** avviato | NON ESEGUITO |
| TW-14 | un **terzo** account o il preparatore | Avvio del launcher con un account diverso da `ClaudeAccountSid` | Rifiuto «non e' l'account Claude…» | NON ESEGUITO |
| TW-15 | preparatore | Simulazione di manomissione su una **copia di prova** creata con lo script (es. `-ArchiveDir D:\FILM_ARCHIVI_TEST`), non quella reale: aggiungere un file nella cartella, o concedere a `film_claude` la scrittura con `icacls` | Launcher di `film_claude` in STOP («file inattesi» oppure «diritti di scrittura») | NON ESEGUITO |
| TW-16 | preparatore | `-RipristinaAcl` sulla copia di prova, conferma `RIPRISTINA` | Ripristinate **solo** le ACL della copia; SDDL della cartella genitore e del gioco invariati; il launcher successivo va in STOP | NON ESEGUITO |
| TW-17 | preparatore | Genitore non sicuro: `-ArchiveDir` in una cartella genitore di prova dove `film_claude` ha «Controllo completo» | STOP **prima** di creare la copia («Cartella genitore non sicura»); nessuna cartella creata | NON ESEGUITO |

**Nota su TW-17:** il ripristino automatico dopo un errore successivo all'applicazione dei permessi (es. hash non corrispondente) è difficile da provocare in modo sicuro. Si considera verificato solo se capita davvero o tramite TW-16, e va segnalato come tale.

## 4. Criteri per procedere
Solo con **TW-01…TW-13 superati** e TW-10 senza alcuna differenza si può passare a L0 con Claude in modalità `plan`. Qualsiasi esito diverso da quello atteso → **STOP**, annotare il messaggio e riportarlo nella PR.
