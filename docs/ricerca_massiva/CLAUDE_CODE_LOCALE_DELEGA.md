# FILM — Claude Code locale, delega con archivi COPIATI

**Revisione 2026-10-13 — OPZIONE 2 APPROVATA.** Questo testo sostituisce la precedente impostazione del launcher che controllava direttamente `GameDir`. La versione storica resta nella cronologia Git. **Script non testati su Windows**. Non è stato avviato Claude né è stata modificata l'installazione originale.

## Prima di tutto: leggere il protocollo vincolante
**[OPZIONE2_ARCHIVI_COPIATI.md](OPZIONE2_ARCHIVI_COPIATI.md)** è il riferimento principale, contiene le procedure e i limiti della sicurezza. Eseguire soltanto dopo verifica manuale delle ACL e del codice.

| Percorso | Scopo | Permesso atteso |
| --- | --- | --- |
| `D:\Games\Assassin's Creed II` | Copia originale Ubisoft Connect | Solo lettura dallo script di **staging iniziale**, non si usa più da Claude |
| `D:\FILM_ARCHIVI_RO` | Archivio `DataPC_Abstergo.forge` e manifest SHA256 | **Sola lettura NTFS per l'account Claude** |
| `D:\FILM_PRIVATO` | Risultati e capitolato Claude | Scrittura con account Claude, fuori dalla copia |

### Protezione reale e limiti
1. **Due account distinti:** il primo account prepara la copia; il secondo è un account standard dedicato a Claude. La copia viene resa non scrivibile per il secondo account **automaticamente** da `prepara_copia_privata_acii.ps1`, dopo riepilogo e conferma `PROTEGGI`; c'è un ripristino `-RipristinaAcl` limitato alla sola copia. Non modificare i permessi dell'installazione originale.
2. Claude Code su Windows nativo **non è automaticamente isolato dal resto del filesystem**. Il launcher valida i permessi della **copia** con AccessCheck Windows e ne verifica l'hash, ma non può garantire che Claude non tocchi altre cartelle accessibili al suo account. Evitare diritti superflui all'account dedicato; il principio «non aprire mai il gioco originale» resta una regola comportamentale se le sue ACL permettono comunque l'accesso. Non dichiarare protezione totale senza un confine OS indipendente.
3. Vietati bypass di permessi, patching, accesso in scrittura all'archivio, uso di software dubbi/DRM bypass, network upload e pubblicazione di asset proprietari. Ogni fase ha uno **STOP**.
4. I tre script sono in `docs/ricerca_massiva/scripts/` e vanno **letti prima dell'esecuzione**:
   - `prepara_copia_privata_acii.ps1`: **separato, da eseguire PRIMA di Claude** con l'account preparatore. Legge il gioco, copia soltanto Abstergo con verifica SHA256, applica i permessi NTFS **della sola copia** per l'account Claude (`-ClaudeAccount`) dopo conferma, li verifica con AuthZ e, in caso di errore, li ripristina. Supporta `-DryRun` e `-RipristinaAcl`.
   - `avvia_claude_locale.ps1`: opera **esclusivamente con `-ArchiveDir`**, verifica manifest SHA256 e ACL sola lettura, copia istruzioni, chiede conferma, avvia `plan`.
   - `inventario_acii_readonly.ps1`: inventaria **esclusivamente gli archivi copiati**, scrive CSV nella WorkDir.

## Procedura da seguire

**A. Preparazione con l'account del proprietario del gioco**

```powershell
.\docs\ricerca_massiva\scripts\prepara_copia_privata_acii.ps1 -GameDir "D:\Games\Assassin's Creed II" -ArchiveDir "D:\FILM_ARCHIVI_RO" -ClaudeAccount "film_claude" -DryRun
```

Controllare il riepilogo; poi eseguire **senza** `-DryRun`, digitando `PROTEGGI`. Lo script copia solo `DataPC_Abstergo.forge`, crea `MANIFEST_ARCHIVI.json` (V2) e protegge la copia. Non sovrascrive una cartella di staging esistente e non avvia Claude. Non copiare ancora voci e rifugio senza una successiva decisione.

**B. Proteggere la copia, non il gioco**

**Automatico** nel passo A: DACL senza ereditarietà, account Claude in sola lettura ed esecuzione, verifica AuthZ di cartella, file e genitore, e ripristino automatico in caso di errore. Ripristino manuale: `-RipristinaAcl`. Controllo facoltativo: `Proprietà → Sicurezza → Avanzate → Accesso effettivo` per `film_claude`. Nessuna modifica ai permessi del gioco né della cartella genitore.

**C. Avviare dal secondo account Windows standard dedicato**

```powershell
$commit = (git rev-parse HEAD).Trim()
.\docs\ricerca_massiva\scripts\avvia_claude_locale.ps1 -ArchiveDir "D:\FILM_ARCHIVI_RO" -WorkDir "D:\FILM_PRIVATO" -ExpectedCommit $commit
```

La copia Git della PR #14 dev'essere **pulita**, alla revisione riconosciuta. Il launcher verifica le ACL effettive della copia, SHA256, source separate, symlink, permessi e impostazioni Claude; poi chiede due conferme per copiare il capitolato e avviare Claude in `plan`. Prima di L0 Claude deve leggere `capitolato/CLAUDE_REPOSITORY_FILM.md`, `capitolato/docs/`, comunicare il commit e attendere consenso.

**D. Fasi locali e stop**

| Fase | Azione | Conferma |
| --- | --- | --- |
| L0 | GPU, Windows e archivi **nella copia**, non gioco originale | STOP |
| L1 | Inventario `-ArchiveDir "D:\FILM_ARCHIVI_RO" -OutDir "D:\FILM_PRIVATO\inventario"` | STOP |
| L2 | **Verifica manifest/hash dello staging già eseguito**, non copia dal gioco | STOP |
| L3 | Verifica disponibilità/liceità AnvilToolkit, Blender e tool ufficiali | STOP |
| L4 | Estrazione modelli/istanze **dalla copia** in cartella di lavoro modificabile | STOP |
| L5 | Render tecnico della **stanza vuota 720p/1080p**, non master finale | STOP |
| L6 | Solo dopo approvazione umana dei master, **una sola immagine finale 4K** con Desmond e Lucy | STOP |

**Regole creative:** voci originali italiane non modificate né clonate; assenza di audio non autorizza nuove frasi sintetiche. Nessun gameplay, nessun upload di texture/mesh/suoni/video nel repo pubblico. **Non produrre i primi 15 minuti** prima del giudizio sull'anteprima.

## Cosa è realmente verificato finora
Codice presente nella PR e procedura documentata. **Nessuna copia degli archivi, prova AccessCheck, estrazione, rendering o test del launcher è stata eseguita da questa sessione.** Se permessi, hash, account o percorsi non tornano, lo script deve fermarsi; non aggirare il blocco.
