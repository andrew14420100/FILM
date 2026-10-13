# CLAUDE_CODE_LOCALE_DELEGA — far eseguire il lavoro a Claude sul PC Windows, con accesso limitato

**Stato:** PROPOSTA · DA VERIFICARE · **non autorizza alcuna esecuzione.** Risponde al punto 2 della revisione del proprietario sulla PR #14: il committente preferisce che sia Claude a fare il lavoro, non eseguire a mano una procedura in molti passi.
**Fatto attuale:** la sessione di Claude che ha scritto questo documento gira **nel cloud** e **non ha accesso al PC**. L'accesso esisterà solo quando l'utente avvierà Claude Code **localmente** sul proprio PC con le limitazioni qui descritte. Fino ad allora nessun documento può dichiararlo.

## 1. Come funziona la delega
| Elemento | Proposta |
|---|---|
| Dove gira Claude | **Claude Code locale** (CLI) sul PC Windows dell'utente, avviato dall'utente stesso |
| Cartella di lavoro | Solo `D:\FILM_PRIVATO\` (spazio privato, fuori da GitHub e fuori dalla cartella del gioco) |
| Cartella del gioco | Accesso **in sola lettura**; mai scrittura, mai avvio del gioco o del launcher |
| Modalità iniziale | `plan` (Claude propone, l'utente approva) e poi `default`, con **richiesta di conferma per ogni comando** |
| Costi | Usa il piano Claude esistente dell'utente; **nessun** servizio o API aggiuntivo a pagamento (CLAUDE.md, vincolo 7) |
| Istruzioni per il Claude locale | Un `CLAUDE.md` nella cartella privata e una **copia di tutte le istruzioni di FILM** in `D:\FILM_PRIVATO\capitolato\`: `README.md`, `CLAUDE.md` del repository e **l'intera cartella `docs/`** (solo Markdown e script originali, nessun asset), con `MANIFEST_SHA256.txt` e la revisione Git. **Prima di L0** Claude locale legge il capitolato e dichiara quale revisione ha letto; l'utente conferma. |

Il **launcher** [scripts/avvia_claude_locale.ps1](scripts/avvia_claude_locale.ps1) va eseguito dalla copia locale del branch. Nell'ordine:
1. Esegue solo controlli in lettura, **prima di creare qualsiasi file**:
   - `WorkDir` separata dal gioco (non uguale, non contenuta, non contenitore);
   - **nessuna junction o symlink** in alcun componente di `GameDir` o `WorkDir`;
   - PowerShell **non elevato**;
   - **analisi delle ACL NTFS** (sola lettura) della cartella del gioco e dei file principali (`AssassinsCreedIIGame.exe`, `DataPC.forge`, `DataPC_Abstergo.forge`, `sounds_ita.pck`): se Windows consente all'utente corrente di **scrivere, cancellare, cambiare permessi** o se l'utente ne è **proprietario**, il launcher **si rifiuta di proseguire**;
   - GPU, CLI `claude` e file chiave del gioco.
2. Solo con conferma:
   - crea `WorkDir` e **ricontrolla** che sia un percorso reale fuori dal gioco;
   - copia il capitolato senza sovrascrivere;
   - crea `.claude\settings.json` e `CLAUDE.md` se assenti.
3. Solo con conferma, avvia Claude Code in modalità `plan`.

In modalità `plan` Claude **non scrive file** finché l'utente non approva un piano e un cambio di modalità. `bypassPermissions` e auto mode sono disattivati nelle impostazioni.

Anche il launcher è **non eseguito né testato**: nessuno di questi punti si considera risolto finché non è provato in locale.

## 2. Permessi Claude ≠ protezione del filesystem
Fonte: documentazione ufficiale di Claude Code, consultata il 2026-10-13: https://code.claude.com/docs/en/permissions e https://code.claude.com/docs/en/sandboxing. Ne derivano tre punti:
- Le regole sui file consultano **solo `Edit(path)` e `Read(path)`**. Una regola `Write(path)` viene accettata ma **ignorata**, quindi si usa `Edit`, che copre anche le scritture.
- Le regole `Edit` e `Read` valgono per gli strumenti di file di Claude, per i comandi riconosciuti (es. `cat`, `sed`, `tee`) e per le redirezioni. **Non** valgono per sottoprocessi arbitrari: uno script o un tool avviato dalla shell può scrivere dove `Edit` è negato. Le regole `Bash(...)` **non** coprono lo strumento `PowerShell(...)`: servono regole separate.
- Su **Windows nativo il sandbox di Claude Code non è disponibile**: i comandi girano senza isolamento. Il sandbox esiste solo su macOS, Linux e WSL2.

**Di conseguenza** le regole di Claude sono una **seconda linea**. La protezione reale della cartella del gioco deve venire dal **sistema operativo**:

| Livello | Misura | Stato |
|---|---|---|
| 1 (obbligatorio, **imposto dal launcher**) | Eseguire launcher e Claude **da utente standard non elevato**. Il launcher rifiuta una sessione da amministratore e **si ferma se le ACL NTFS consentono all'utente corrente scrittura, cancellazione o cambio dei permessi** sul gioco. Sotto `Program Files` i permessi predefiniti di Windows di norma lo negano. | Controllo implementato ma **non testato**. L'analisi statica delle ACL va confermata dall'utente, per esempio con la scheda *Sicurezza → Accesso effettivo* di Esplora risorse |
| 2 (necessario se il launcher rifiuta l'avvio per le ACL) | **Utente Windows dedicato** e standard (es. `film_claude`) che ha solo lettura sulla cartella del gioco e scrittura solo su `D:\FILM_PRIVATO`. Le ACL si impostano a mano dall'utente; il launcher **non** modifica i permessi della cartella del gioco. | **DA DECIDERE** dall'utente |
| 3 (facoltativo) | Claude Code dentro **WSL2** con sandbox attivo, con la cartella del gioco in sola lettura. Da valutare: AnvilToolkit è un programma Windows. | IPOTESI |

Le impostazioni generate dal launcher (`D:\FILM_PRIVATO\.claude\settings.json`):
```json
{
  "permissions": {
    "defaultMode": "plan",
    "disableBypassPermissionsMode": "disable",
    "disableAutoMode": "disable",
    "deny": [
      "Edit(//<GAME_DIR_POSIX>/**)",
      "Bash(git push *)", "Bash(curl *)", "Bash(wget *)",
      "PowerShell(git push *)", "PowerShell(Invoke-WebRequest *)", "PowerShell(Invoke-RestMethod *)",
      "PowerShell(Start-BitsTransfer *)", "PowerShell(Remove-Item *)",
      "WebFetch"
    ],
    "ask": ["Bash", "PowerShell", "Edit"]
  }
}
```
`<GAME_DIR_POSIX>` è la cartella del gioco in forma POSIX: per esempio `C:\Program Files (x86)\...` diventa `/c/Program Files (x86)/...`, e nella regola si scrive `//c/...`. La compila il launcher. **Verificare con `/permissions`** che le regole compaiano senza avvisi prima di L0.

Il blocco di `WebFetch` e dei download è voluto: i tool di terzi li scarica **l'utente** dalle pagine ufficiali ([BENCHMARK_TOOLCHAIN.md](BENCHMARK_TOOLCHAIN.md)); Claude locale ne verifica solo presenza e hash.

## 3. Fasi con stop obbligatori
Ogni fase termina con un **resoconto testuale** (incollabile nella PR o in chat, senza file del gioco) e uno **STOP** in attesa di consenso.

| Fase | Cosa fa Claude locale | Tipo | Stop / consenso richiesto |
|---|---|---|---|
| L0 Ricognizione | Legge GPU (`nvidia-smi`), versione di Windows, spazio su disco, presenza della cartella del gioco e dei tool già installati | **sola lettura** | Stop: l'utente conferma che i dati sono corretti |
| L1 Inventario | Esegue `inventario_acii_readonly.ps1` (dry-run: stampa i percorsi risolti e si ferma prima di scrivere, poi chiede conferma) | sola lettura e un CSV privato | Stop: inventario completo o INCOMPLETO |
| L2 Copia privata | Propone **quali** archivi copiare (all'inizio solo `DataPC_Abstergo.forge`), con spazio richiesto e destinazione | **dry-run**, poi copia solo con consenso | **Consenso esplicito** per la copia |
| L3 Tool di terzi | Verifica che l'utente abbia installato AnvilToolkit, Blender 5.2 ecc. dalle pagine ufficiali; registra versione e SHA256 | sola lettura | **Consenso esplicito** prima del primo avvio di ogni tool |
| L4 Estrazione T2/T3 | Vedi i criteri nel [BENCHMARK](BENCHMARK_TOOLCHAIN.md) §5: prova di un mesh **realmente proveniente** dalla copia di `DataPC_Abstergo.forge` e verifica di istanze e posizioni della stanza | lavoro sulle copie | Stop: l'utente vede le prove private |
| L5 Test 720p/1080p | Blockout e render di prova a bassa risoluzione; verifica di scala, UV, materiali e camera | render privato | Stop e decisione |
| L6 Frame finale 4K | **Nessun 4K della stanza vuota.** Un solo render 3840×2160 con Desmond e Lucy, dopo L5 e l'approvazione dei master | render privato | **Consenso esplicito** |

**Regole per il Claude locale:**
- non dichiarare un risultato senza prova;
- non modificare la cartella del gioco;
- non usare la rete;
- non caricare nulla su GitHub, salvo Markdown di stato senza contenuti del gioco;
- fermarsi a ogni errore o ambiguità.

## 4. Gate creativi invariati (punto 4 della revisione)
- **Un solo** frame finale fotorealistico, `FILM_PREVIEW_01_ABSTERGO.png`, con **Desmond e Lucy** (Lucy entra, Desmond si volta). I render di prova L5 dell'ambiente (720p/1080p) **non** sono l'anteprima e restano privati.
- Voci **solo** dalle registrazioni originali italiane, **mai** sintetizzate, clonate o modificate; dove mancano: `AUDIO_ORIGINALE_ASSENTE`, indicato in chiaro.
- **Nessun** file Ubisoft (audio, texture, mesh, immagini) su GitHub pubblico.
- **Nessuna** produzione dei primi 15 minuti prima dell'approvazione dell'anteprima.
- Nessun merge della PR #14 senza approvazione.
