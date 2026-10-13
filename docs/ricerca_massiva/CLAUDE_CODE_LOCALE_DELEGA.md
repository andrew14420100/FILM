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
| Istruzioni per il Claude locale | Un `CLAUDE.md` nella cartella privata che rimanda a questo file, a `LIMITI_E_DIRITTI.md` e ai gate del §4 |

Il **launcher** [scripts/avvia_claude_locale.ps1](scripts/avvia_claude_locale.ps1):
- esegue solo controlli in lettura (GPU, percorso del gioco, cartella privata, presenza della CLI `claude`);
- se l'utente conferma, crea la cartella privata e i file di configurazione **solo dentro** `D:\FILM_PRIVATO\`;
- avvia Claude Code in modalità `plan`.

Anche il launcher è **non eseguito né testato**.

## 2. Permessi proposti (`D:\FILM_PRIVATO\.claude\settings.json`)
Il launcher lo crea solo con conferma. **La sintassi dei percorsi Windows nelle regole va verificata** con il comando `/permissions` dentro Claude Code prima di iniziare, perché le regole usano percorsi in stile POSIX (`//c/...`). In caso di dubbio Claude locale deve fermarsi e chiedere.

```json
{
  "permissions": {
    "defaultMode": "plan",
    "deny": [
      "Edit(//<GAME_DIR_POSIX>/**)",
      "Write(//<GAME_DIR_POSIX>/**)",
      "Bash(git push:*)",
      "Bash(curl:*)",
      "Bash(Invoke-WebRequest:*)",
      "WebFetch"
    ],
    "ask": [
      "Bash",
      "Edit",
      "Write"
    ]
  }
}
```
`<GAME_DIR_POSIX>` è la cartella del gioco in forma POSIX, ad esempio `c/Program Files (x86)/Ubisoft/...`; la compila il launcher. Il blocco di `WebFetch` e dei download è voluto: i tool di terzi li scarica **l'utente** dalle pagine ufficiali ([BENCHMARK_TOOLCHAIN.md](BENCHMARK_TOOLCHAIN.md)) e Claude locale ne verifica solo la presenza e l'hash.

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
