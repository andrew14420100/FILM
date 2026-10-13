# FILM — Opzione 2: copia privata protetta degli archivi AC II

**Decisione:** APPROVATA dall'utente · 2026-10-13. **Stato del codice:** da verificare su Windows; nessuna esecuzione remota, nessuna modifica al gioco originale, nessun render.  
**Questo documento prevale sulle descrizioni precedenti della PR #14 che chiedono a Claude un accesso diretto a `GameDir`.**

## Architettura scelta

| Percorso | Chi lo usa | Operazioni |
| --- | --- | --- |
| `D:\Games\Assassin's Creed II` | Solo script iniziale di staging, **prima di avviare Claude** | **Lettura** dei file richiesti, nessuna patch o modifica ACL |
| `D:\FILM_ARCHIVI_RO` | Claude locale (account Windows **standard distinto** dal creatore delle copie) | **Sola lettura**, da imporre tramite ACL effettive NTFS e validare col launcher |
| `D:\FILM_PRIVATO` | Claude | **Scrittura dei soli risultati** (inventario, mesh esportate su copie di lavoro, scene e render privati) |

**Importante:** sul Windows nativo le regole Claude non costituiscono una sandbox. Il launcher verifica i permessi effettivi **della copia**, ma senza isolamento OS non può matematicamente impedire che Claude acceda ad altri percorsi che Windows consente al suo account. Per proteggere anche l'originale è preferibile utilizzare un account standard dedicato che **non abbia accesso di scrittura al gioco**, oppure una macchina virtuale/isolamento accuratamente configurato. L'opzione 2 **non modifica i permessi originali del gioco**; questo compromesso viene dichiarato esplicitamente e non nascosto. Un account ordinario che può modificare `D:\Games\... ` non riceve una protezione assoluta dal solo prompt.

## Prima fase — staging, eseguito dall'account che possiede una copia valida del gioco

1. Ottenere sul PC una copia del branch della PR #14 e **leggere prima gli script**; non usarli dal cloud come se fossero stati provati.
2. **Creare prima**, con un account amministratore, un **account Windows locale standard dedicato a Claude** (es. `film_claude`). Lo script lo rifiuta se è amministratore, disabilitato, non locale o uguale al preparatore.
3. **Dry-run.** Si esegue con l'account preparatore in PowerShell **non elevato**, dal clone FILM. Mostra controlli e riepilogo **senza creare, copiare o modificare nulla**:

   ```powershell
   .\docs\ricerca_massiva\scripts\prepara_copia_privata_acii.ps1 -GameDir "D:\Games\Assassin's Creed II" -ArchiveDir "D:\FILM_ARCHIVI_RO" -ClaudeAccount "film_claude" -DryRun
   ```

   L'unica scrittura possibile è la compilazione temporanea del codice di controllo permessi (`Add-Type`) che PowerShell fa nella cartella temporanea dell'utente. La lettura dell'originale per le verifiche può aggiornare la data di ultimo accesso dei file, se Windows la registra.
4. **Esecuzione reale.** Stesso comando **senza `-DryRun`**. Lo script mostra lo stesso riepilogo (file, byte, account Claude con SID, permessi da applicare) e procede **solo se si digita `PROTEGGI`**. Poi, in ordine:
   1. crea `D:\FILM_ARCHIVI_RO` (si ferma se esiste già);
   2. salva il descrittore iniziale della copia in `%LOCALAPPDATA%\FILM\acl_backup\`, cioè nel profilo del preparatore, non accessibile all'account Claude;
   3. applica alla **sola copia** una DACL **senza ereditarietà**: SYSTEM, Administrators e preparatore con controllo completo; account Claude con **sola lettura ed esecuzione**;
   4. copia **solo** `DataPC_Abstergo.forge` e verifica SHA256 e byte tra originale e copia;
   5. scrive `MANIFEST_ARCHIVI.json` in formato **V2**, con il SID dell'account Claude;
   6. verifica con **AuthZ** l'accesso **effettivo** dell'account Claude su cartella, file e **cartella genitore**. Basta un solo diritto di scrittura, cancellazione, rinomina, modifica dei permessi o proprietà, oppure DELETE_CHILD / DELETE / WRITE_DAC / WRITE_OWNER sul genitore, per far scattare il ripristino automatico delle ACL iniziali **della sola copia** e lo STOP.
5. **Ripristino manuale**, se serve: `prepara_copia_privata_acii.ps1 -ArchiveDir "D:\FILM_ARCHIVI_RO" -RipristinaAcl`, con conferma `RIPRISTINA`. Rimette solo i permessi salvati della copia, mai quelli del genitore o del gioco. Dopo il ripristino il launcher rifiuta l'avvio.
6. **Mai** cartelle, file o permessi dell'installazione `D:\Games\Assassin's Creed II` vengono modificati. Lo script **non** modifica la cartella genitore: se questa concede diritti critici all'account Claude, si ferma prima di creare qualsiasi cosa.
7. Facoltativo: **Proprietà → Sicurezza → Avanzate → Accesso effettivo** su cartella e file, selezionando `film_claude`. Il launcher ripete comunque il controllo con il **token reale** dell'account. L'attributo «Sola lettura» viene impostato solo come segnale visivo: non sostituisce l'ACL.
8. Claude **non** viene avviato da questo script. **Non** passare ora `-IncludeHideout` o `-IncludeItalianVoices`: servono nuove decisioni e una nuova cartella di staging.

**Il primo account prepara la copia e i permessi; il secondo account, standard, esegue Claude.** Non usare lo stesso account proprietario della copia per tutte e due le fasi: in molti casi il proprietario può modificare la DACL o i file.

## Seconda fase — avvio Claude SOLO dagli archivi copiati

Dopo aver controllato le ACL, accedere con il secondo account standard. Il clone FILM deve essere raggiungibile in **sola lettura** per il suo account; la cartella di lavoro dev'essere scrivibile. Il branch deve essere completo e pulito.

```powershell
$commit = (git rev-parse HEAD).Trim()
.\docs\ricerca_massiva\scripts\avvia_claude_locale.ps1 -ArchiveDir "D:\FILM_ARCHIVI_RO" -WorkDir "D:\FILM_PRIVATO" -ExpectedCommit $commit
```

- **Non** esiste più `-GameDir` nel launcher: un vecchio comando che lo usa deve fallire, non tornare ad aprire Ubisoft Connect.
- Il launcher ricontrolla, e si ferma alla **prima** discrepanza:
  - account non amministratore e **SID uguale** a `ClaudeAccountSid` del manifest V2, diverso dal preparatore;
  - DACL della copia **protetta** (senza ereditarietà) e account Claude **non proprietario** di alcun elemento;
  - diritti **effettivi** (AccessCheck sul token reale) di sola lettura su ogni file e cartella;
  - assenza di DELETE_CHILD / DELETE / WRITE_DAC / WRITE_OWNER sul genitore;
  - SHA256 e byte rispetto al manifest, nessun file in più o in meno;
  - separazione dei percorsi e junction/symlink;
  - configurazioni Claude preesistenti e commit del clone pulito.
- Chiede conferma **prima** di creare la configurazione `D:\FILM_PRIVATO\.claude` e **prima** di lanciare Claude in modalità `plan`.
- Copia soltanto **documentazione di FILM** nel WorkDir; non ricopia alcuna risorsa Ubisoft dentro il repo né nel capitolato. Claude legge `D:\FILM_ARCHIVI_RO`, esporta e modifica soltanto file di lavoro in `D:\FILM_PRIVATO`.
- Claude deve fermarsi a ogni passaggio L0–L6 e mostrare report; nessuna generazione automatica dei primi 15 minuti.

## Ordine operativo aggiornato

L0. Ricognizione della **copia**, GPU e strumenti, senza aprire il gioco originale.  
L1. Inventario **solo della copia**: `inventario_acii_readonly.ps1 -ArchiveDir "D:\FILM_ARCHIVI_RO" -OutDir "D:\FILM_PRIVATO\inventario"`.  
L2. Staging **già avvenuto fuori da Claude**: Claude verifica manifest/hash e NON copia dal gioco.  
L3. Verifica dei software locali AnvilToolkit/Blender senza download non richiesti.  
L4. Estrazione **dalla copia protetta** verso una sotto-cartella di lavoro, con prove di provenienza mesh e trasformazioni/istanze.  
L5. Test fotorealistico dell'**ambiente** 720p/1080p e stop.  
L6. **Solo dopo approvazione separata dei personaggi**, una immagine finale 4K con Desmond/Lucy, privata; stop prima di qualunque video di 15 minuti.

## Criticità non ancora dimostrate

- Script, AuthZ e AccessCheck **non sono stati eseguiti su Windows**. I controlli statici superati sono elencati in [TEST_WINDOWS_OPZIONE2.md](TEST_WINDOWS_OPZIONE2.md): sintassi, PSScriptAnalyzer, compilazione C# e solo ASCII. Non equivalgono a un test delle ACL reali.
- AuthZ da SID, usato nella preparazione, non include i gruppi legati alla sessione (es. INTERACTIVE). Per questo la DACL della copia contiene solo voci esplicite e la verifica definitiva è quella del launcher con il token reale.
- Non è stata verificata l'esistenza di `DataPC_Abstergo.forge` sulla copia installata dell'utente.
- Il manifesto con SHA256 protegge da variazioni **rispetto al momento dello staging**, ma non verifica automaticamente la provenienza canonica di ogni mesh contenuta nel file.
- Accesso nativo di Claude a PowerShell/strumenti esterni non è un isolamento forte. Con account separato e permessi NTFS si limita il rischio; niente promessa di «impossibile modificare ogni altro file del computer».
- Nessun ambiente/volto/modello/audio del gioco o anteprima è stato ancora esportato, creato, convertito o pubblicato.

**Criterio di riuscita:** copia verificata + nessuna scrittura all'originale + permessi reali del secondo account confermati + L0/L1 superati. Allora si può tentare l'estrazione, non dichiararla già riuscita.
