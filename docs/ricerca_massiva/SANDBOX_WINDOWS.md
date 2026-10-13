# FILM — Claude Code dentro Windows Sandbox (modalità dedicata)

**Stato:** PROPOSTA · script **NON TESTATI SU WINDOWS** · controlli statici superati (vedi [TEST_WINDOWS_SANDBOX.md](TEST_WINDOWS_SANDBOX.md)). Nessun merge; Claude non è stato avviato; il gioco originale non è stato toccato.
**Base verificata dall'utente (2026-10-13):** Windows 11 Pro; Windows Sandbox funzionante; archivio Abstergo condiviso in sola lettura e SHA256 verificato; creazione di cartelle **negata** («Accesso negato»); installazione originale di AC II **non condivisa**.

## 1. Perché una modalità dedicata
- Dentro Windows Sandbox l'utente è `WDAGUtilityAccount`, che per progetto è **amministratore** (documentazione Microsoft sul file `.wsb`). Il launcher dell'host, [`avvia_claude_locale.ps1`](scripts/avvia_claude_locale.ps1), lo rifiuterebbe giustamente, e **resta invariato**: nessun controllo è stato disattivato. La suite statica (T08d) verifica che non contenga eccezioni per la Sandbox.
- La Sandbox ha un **modello di sicurezza diverso**:
  - è una macchina usa e getta, che a ogni chiusura cancella tutto ciò che contiene;
  - **vede solo** le cartelle dell'host dichiarate nel file `.wsb`;
  - la **sola lettura** delle cartelle condivise è imposta dall'host (`<ReadOnly>true</ReadOnly>`).
- Il nuovo launcher [`avvia_claude_sandbox.ps1`](scripts/sandbox/avvia_claude_sandbox.ps1) verifica questi fatti **sul campo** e si rifiuta di funzionare fuori dalla Sandbox.

## 2. Architettura

| Cartella host (esempio) | Nella Sandbox | Accesso | Contenuto |
|---|---|---|---|
| `D:\FILM_ARCHIVI_RO` | `C:\FILM\ARCHIVI_RO` | **Sola lettura** | Copia privata di `DataPC_Abstergo.forge` + `MANIFEST_ARCHIVI.json` (V2) |
| clone FILM (es. `D:\FILM`) | `C:\FILM\REPO` | **Sola lettura** | Istruzioni e capitolato al commit approvato |
| `D:\FILM_SANDBOX_CONFIG` | `C:\FILM\CONFIG` | **Sola lettura** | `FILM_SANDBOX.json`, `CAPITOLATO_SHA256.txt`, il file `.wsb` stesso |
| `D:\FILM_RISULTATI_SANDBOX` | `C:\FILM\RISULTATI` | **Scrivibile, persistente** | Unico posto in cui i risultati sopravvivono alla chiusura |
| — | `C:\FILM\LAVORO` | Scrivibile, **temporanea** | Lavoro di Claude; sparisce alla chiusura |
| `D:\Games\Assassin's Creed II` | **non presente** | — | Mai condivisa; il generatore verifica che nessuna cartella condivisa coincida con il gioco, lo contenga o ne sia contenuta |

**Impostazioni del `.wsb` generato:**
- `Networking` **Enable**: necessario, vedi §4;
- `AudioInput`, `VideoInput` e `PrinterRedirection` **Disable**;
- `ClipboardRedirection` **Disable** (modificabile con un parametro);
- `ProtectedClient` **Enable**: isolamento AppContainer del client. Se impedisse il login si può provare `-ProtectedClient Disable`, test TS-11;
- `VGpu` **Disable**: da riconsiderare solo per Blender in fasi successive, con una decisione separata;
- `MemoryInMB` 8192;
- `LogonCommand` apre **solo la verifica** (`-SoloVerifica`): Claude **non parte da solo**.

## 3. Procedura (sul PC dell'utente)
1. **Prerequisito:** la copia privata è già preparata con `prepara_copia_privata_acii.ps1` (manifest V2). La protezione NTFS per un secondo account **non è necessaria** per la Sandbox: la sola lettura la impone la mappatura. Resta comunque consigliata.
2. **Clone FILM pulito** al commit da usare: `git rev-parse HEAD` → hash di 40 caratteri.
3. **Generazione** sull'host, in PowerShell **non elevato**, dal clone:
   ```powershell
   $c = (git rev-parse HEAD).Trim()
   .\docs\ricerca_massiva\scripts\sandbox\genera_film_sandbox.ps1 -OriginalGameDir "D:\Games\Assassin's Creed II" -ArchiveDir "D:\FILM_ARCHIVI_RO" -ResultsDir "D:\FILM_RISULTATI_SANDBOX" -ConfigDir "D:\FILM_SANDBOX_CONFIG" -ExpectedCommit $c -DryRun
   ```
   Si legge il riepilogo e il file `.wsb` mostrato a schermo. Poi si ripete **senza `-DryRun`** e si digita `GENERA`. Lo script:
   - scrive **solo** in `D:\FILM_SANDBOX_CONFIG` (che deve essere nuova) e crea `D:\FILM_RISULTATI_SANDBOX` se manca;
   - non legge né condivide il gioco;
   - verifica SHA256 e contenuto della copia, e commit e pulizia del clone.
4. **Avvio della Sandbox:** doppio clic su `D:\FILM_SANDBOX_CONFIG\FILM_SANDBOX.wsb`. Si apre una finestra PowerShell con la **verifica S1–S7**:
   - S1: è davvero la Sandbox, con la configurazione al commit giusto;
   - S2: **prove di scrittura** negate su archivio, clone e configurazione, riuscita su `RISULTATI`;
   - S3: SHA256 della copia;
   - S4: SHA256 di ogni file del capitolato;
   - S5: rete;
   - S6: Claude Code;
   - S7: nessuna configurazione Claude preesistente.

   Termina **senza scrivere nulla** e senza avviare Claude.
5. **Installazione di Claude Code**, da ripetere a ogni sessione perché la Sandbox è temporanea: nella finestra della Sandbox,
   ```powershell
   powershell -ExecutionPolicy Bypass -File C:\FILM\REPO\docs\ricerca_massiva\scripts\sandbox\avvia_claude_sandbox.ps1 -ExpectedCommit <hash> -InstallaClaudeCode
   ```
   Ripete S1–S7, scarica **solo** l'installer ufficiale `https://claude.ai/install.ps1` in un file temporaneo, ne mostra dimensione e SHA256 e lo esegue solo dopo la conferma `INSTALLA`. Poi chiede `PREPARA`, che crea `C:\FILM\LAVORO` con `CLAUDE.md` e `.claude\settings.json`, e `AVVIA`.
6. **Primo avvio:** Claude parte in modalità `plan`, con `--add-dir` su `RISULTATI`, `ARCHIVI_RO` e `REPO`.
   - Al primo uso chiede l'**accesso con il tuo account Claude** nel browser della Sandbox. Le credenziali spariscono alla chiusura.
   - Prima di L0 Claude deve dichiarare il commit letto e attendere la tua conferma.
7. **Fine sessione:** tutto ciò che va conservato deve trovarsi in `C:\FILM\RISULTATI`. Chiudendo la Sandbox si perdono `C:\FILM\LAVORO`, l'installazione e l'accesso a Claude.

## 4. Rischi residui e limiti (dichiarati)
- **Rete attiva:** è indispensabile perché Claude Code usa i modelli Anthropic (`api.anthropic.com`, `claude.ai`, `platform.claude.com`, `downloads.claude.ai` secondo la documentazione di rete di Claude Code). Windows Sandbox **non** permette di limitare i domini: con la rete attiva la Sandbox vede anche la **rete locale**, come avverte la documentazione Microsoft. Le impostazioni di Claude negano `WebFetch`, `curl`, `wget`, `Invoke-WebRequest` e `git push`, ma **non sono un firewall**.
- **Dati inviati ad Anthropic:** ciò che Claude legge con i suoi strumenti (testi, output di comandi, eventuali estratti) viene inviato ai modelli Anthropic tramite il tuo account. È un servizio esterno: l'utente ne autorizza l'uso avviando Claude (CLAUDE.md, vincolo 7). Gli archivi binari non vanno letti per intero dentro la conversazione; si lavora con tool locali e si riportano solo sintesi.
- **Cartella dei risultati:** è scrivibile e **persistente sull'host**. Ciò che contiene va trattato come non verificato: non eseguire sull'host programmi o script prodotti nella Sandbox senza revisione, e non caricarlo su GitHub se contiene materiale del gioco.
- **Prove di scrittura (S2):** creano un file di prova con eliminazione automatica alla chiusura. Se, contro le attese, la creazione riuscisse in una cartella di sola lettura, il file verrebbe eliminato subito e lo script si fermerebbe.
- **Amministratore nella Sandbox:** dentro la Sandbox Claude agisce come amministratore della macchina virtuale. La protezione degli archivi e del clone **non** dipende da questo, ma dalla mappatura in sola lettura dell'host, verificata in S2.
- **GPU disattivata:** per L5 (render di prova) o Blender servirà rivalutare `VGpu`, oppure lavorare sull'host. Decisione separata.
- **Prestazioni:** la memoria predefinita è 8 GB e va regolata con `-MemoryInMB`.

## 5. Cosa resta invariato
- **Gioco originale:** mai letto dagli script della Sandbox, mai condiviso, mai modificato.
- **Launcher dell'host:** invariato, con tutti i controlli per l'uso fuori dalla Sandbox.
- **Vincoli creativi:**
  - fasi L0–L6 con stop;
  - un solo frame finale fotorealistico con Desmond e Lucy;
  - voci solo originali italiane;
  - niente primi 15 minuti;
  - nessun file Ubisoft su GitHub.
