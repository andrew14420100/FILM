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
2. Verificare la cartella `D:\Games\Assassin's Creed II`, i file, lo spazio libero e l'assenza di reparse point. **Dry-run in PowerShell** (dal clone FILM, in cartella controllata):

   ```powershell
   .\docs\ricerca_massiva\scripts\prepara_copia_privata_acii.ps1 -GameDir "D:\Games\Assassin's Creed II" -ArchiveDir "D:\FILM_ARCHIVI_RO" -DryRun
   ```

3. Solo dopo controllo della lista, eseguire lo stesso comando **senza `-DryRun`**, digitando `COPIA` quando richiesto. Verrà copiato **solo `DataPC_Abstergo.forge`**. Se assente, STOP. Lo script calcola SHA-256 sorgente/copia e registra `D:\FILM_ARCHIVI_RO\MANIFEST_ARCHIVI.json`. Se la destinazione esiste già, interrompe: non sovrascrive mai copie/manifest.
4. **Non** passare `-IncludeHideout` o `-IncludeItalianVoices` ora: sono opzioni per fasi future separate, solo dopo esplicita approvazione e nuova directory di staging. I dati audio rimangono privati, mai su GitHub.
5. Su Windows, dal **proprietario della copia**, impostare **manualmente le ACL** affinché l'account Claude possa **leggere, ma non scrivere/cancellare/rinominare/cambiare ACL o proprietà** dei file e della directory di staging. Verificare inoltre la possibilità di eliminare/renominare la directory dall'immediata directory genitore. **Non modificare** le ACL dell'installazione Ubisoft Connect.
6. Verificare **Sicurezza → Avanzate → Accesso effettivo** sulla directory e sul file `DataPC_Abstergo.forge`, selezionando esattamente l'account che lancerà Claude. Il launcher ripeterà un controllo Windows AccessCheck: se la copia non è protetta, **rifiuterà l'avvio**. Un attributo «Sola lettura» da Esplora file non sostituisce l'ACL.

**Il primo account prepara la copia e i permessi; il secondo account, standard, esegue Claude.** Non usare lo stesso account proprietario della copia per tutte e due le fasi: in molti casi il proprietario può modificare la DACL o i file.

## Seconda fase — avvio Claude SOLO dagli archivi copiati

Dopo aver controllato le ACL, accedere con il secondo account standard. Il clone FILM deve essere raggiungibile in **sola lettura** per il suo account; la cartella di lavoro dev'essere scrivibile. Il branch deve essere completo e pulito.

```powershell
$commit = (git rev-parse HEAD).Trim()
.\docs\ricerca_massiva\scripts\avvia_claude_locale.ps1 -ArchiveDir "D:\FILM_ARCHIVI_RO" -WorkDir "D:\FILM_PRIVATO" -ExpectedCommit $commit
```

- **Non** esiste più `-GameDir` nel launcher: un vecchio comando che lo usa deve fallire, non tornare ad aprire Ubisoft Connect.
- Il launcher controlla account non amministratore, separazione dei percorsi, junction/symlink, diritti Windows della **copia** su ogni file/cartella, `DELETE_CHILD` nel parent, SHA256/byte rispetto al manifest, eventuali configurazioni Claude precedenti e commit del clone pulito.
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

- Script e P/Invoke AccessCheck **non sono stati eseguiti su Windows** nella presente sessione; controllo del codice statico non è test delle ACL reali.
- Non è stata verificata l'esistenza di `DataPC_Abstergo.forge` sulla copia installata dell'utente.
- Il manifesto con SHA256 protegge da variazioni **rispetto al momento dello staging**, ma non verifica automaticamente la provenienza canonica di ogni mesh contenuta nel file.
- Accesso nativo di Claude a PowerShell/strumenti esterni non è un isolamento forte. Con account separato e permessi NTFS si limita il rischio; niente promessa di «impossibile modificare ogni altro file del computer».
- Nessun ambiente/volto/modello/audio del gioco o anteprima è stato ancora esportato, creato, convertito o pubblicato.

**Criterio di riuscita:** copia verificata + nessuna scrittura all'originale + permessi reali del secondo account confermati + L0/L1 superati. Allora si può tentare l'estrazione, non dichiararla già riuscita.
