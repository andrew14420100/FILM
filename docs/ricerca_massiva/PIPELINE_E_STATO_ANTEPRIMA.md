# PIPELINE_E_STATO_ANTEPRIMA — Fasi B e C dell'incarico #12

**Stato:** pipeline **PROPOSTA, NON VERIFICATA** · anteprima **BLOCCATA, NON GENERATA**.

## 1. Esito della Fase C
> **`FILM_PREVIEW_01_ABSTERGO.png` NON è stata generata.** Nessuna immagine è stata prodotta, salvata o caricata.

### Blocco circostanziato
| # | Requisito per un'anteprima da pipeline verificata | Situazione nella sessione di Claude (cloud) | Esito |
|---|---|---|---|
| 1 | Accesso ai file AC II dell'utente (`DataPC_Abstergo.forge`, copia privata) | Assente: la sessione gira in un container remoto e non vede il PC dell'utente (#12: «Non assumere di avere accesso al PC…») | **BLOCCO** |
| 2 | GPU NVIDIA RTX per Cycles/OptiX o RTX Remix | Assente: container con 4 CPU e 15 GB di RAM, senza GPU | **BLOCCO** |
| 3 | Blender 5.2, AnvilToolkit (Windows), RTX Remix | Non installati. AnvilToolkit e RTX Remix sono per Windows; installare binari non controllati è vietato | **BLOCCO** |
| 4 | Umani fotorealistici verificati di Desmond e Lucy (`DESMOND_MASTER_ACII`, `LUCY_MASTER_ACII`) | Non esistono; richiedono lavoro sul PC dell'utente e una sua approvazione | **BLOCCO** |
| 5 | Nessun servizio a pagamento o generativo esterno | Rispettato: un'immagine da un modello generativo **non** sarebbe una pipeline verificata dagli asset AC II e violerebbe #12 | vincolo |

Una qualsiasi immagine prodotta oggi sarebbe un'invenzione non ancorata ai file del gioco, quindi non viene prodotta.

## 2. Pipeline proposta (Fase B) — componenti
| Master | Definizione | Fonti | Stato |
|---|---|---|---|
| `ABSTERGO_ENV_MASTER` | Scena Blender 5.2 del **laboratorio Animus e della camera di Desmond** (ENV-001/002). Geometria ricostruita in alta definizione sulle forme e misure dei mesh AC II esportati in privato; materiali PBR rifatti; luce cinematografica fredda (P-03); camera 16:9 a 3840×2160 | `DataPC_Abstergo.forge` (copia) → AnvilToolkit glTF; eventuale cattura USD con ac2-rtx come planimetria; reference A-EXT (D9) | PROPOSTA |
| `DESMOND_MASTER_ACII` | Umano digitale fotorealistico di Desmond **versione AC II** (abiti del 2012), con proporzioni e acconciatura confrontate col mesh AC II esportato in privato | Mesh e texture AC II (privati); galleria A-EXT; nessun volto di attori reali preso da fonti esterne | PROPOSTA |
| `LUCY_MASTER_ACII` | Come sopra, per Lucy (abbigliamento Abstergo del 2012) | Come sopra | PROPOSTA |
| Inquadratura `FILM_PREVIEW_01_ABSTERGO` | PRO-002/003: **Lucy entra e Desmond si volta**. 16:9, nessun HUD, nessun logo leggibile in primo piano (regole su film e diritti) | `PROLOGO_TRATTAMENTO_V1.md` (V3) | PROPOSTA |

**Criterio «pipeline verificata»:**
- T1, T2 (provenienza del mesh da `DataPC_Abstergo.forge` dimostrata), T3 (istanze e posizioni della stanza accertate o dichiarate mancanti) e T4a (test 720p/1080p con scala, UV, materiali e camera verificati) di [BENCHMARK_TOOLCHAIN.md](BENCHMARK_TOOLCHAIN.md) superati e annotati;
- T4b (4K) solo dopo T4a e **solo sul frame finale con Desmond e Lucy** (nessun 4K della stanza vuota);
- i master Desmond e Lucy approvati dall'utente.

Solo allora si fa **un solo** render finale fotorealistico con Desmond e Lucy.

## 3. Unico percorso — delegabile a Claude Code locale
Su richiesta del committente (revisione della PR #14) il percorso è pensato per essere **eseguito da Claude Code locale con accesso limitato** sul PC dell'utente, non come procedura manuale in molti passi. Dettagli, permessi e launcher sono in [CLAUDE_CODE_LOCALE_DELEGA.md](CLAUDE_CODE_LOCALE_DELEGA.md). I passi seguono la documentazione degli autori e **non sono stati testati**.

**Avvio (unico intervento manuale dell'utente):** installare Claude Code e lanciare `scripts/avvia_claude_locale.ps1 -GameDir "<cartella AC II>" -WorkDir "D:\FILM_PRIVATO" -ExpectedCommit <hash controllato>` da un **account Windows standard dedicato**. Il launcher fa solo controlli in lettura, poi chiede conferma per creare la configurazione privata e avviare Claude in modalità `plan`.

**Fasi eseguite da Claude locale (stop e consenso a ogni fase):**
1. **L0 Ricognizione** in sola lettura: GPU, disco, cartella del gioco, tool presenti.
2. **L1 Inventario** (T1): prima un dry-run dei percorsi, poi il CSV privato. *Controllo:* `DataPC_Abstergo.forge` presente, inventario completo.
3. **L2 Copia privata** soltanto di `DataPC_Abstergo.forge`, con consenso esplicito. *Controllo:* la data di modifica dell'originale non cambia.
4. **L3 Tool di terzi:** AnvilToolkit e Blender 5.2, installati dall'utente dalle pagine ufficiali. Claude registra versione e SHA256 e chiede consenso prima del primo avvio.
5. **L4 Estrazione (T2/T3):** prova della provenienza di un mesh e verifica delle istanze della stanza.
6. **L5 Test 720p/1080p (T4a)** di `ABSTERGO_ENV_MASTER`, **solo ambiente**. Poi **stop e decisione**.
7. Dopo l'approvazione: lavoro su `DESMOND_MASTER_ACII` e `LUCY_MASTER_ACII` (es. MetaHuman, previa lettura della licenza). Infine **L6**: **un solo** render 4K (T4b, nessun 4K precedente della stanza vuota) `FILM_PREVIEW_01_ABSTERGO.png` con Desmond e Lucy, in `D:\FILM_PRIVATO\render\`, **mai su GitHub**.

Le alternative (ac2-rtx e RTX Remix come planimetria USD) restano **facoltative** e solo su una copia dell'intera installazione.

## 3-bis. Gate creativi invariati
- **Un solo** frame finale fotorealistico con **Desmond e Lucy**. I render di prova dell'ambiente non sono l'anteprima.
- Voci solo originali italiane, mai sintetizzate o modificate; dove mancano le battute originali: `AUDIO_ORIGINALE_ASSENTE`, indicato chiaramente.
- Nessun file Ubisoft (audio, texture, mesh, immagini) su GitHub pubblico.
- Nessuna produzione dei primi 15 minuti prima dell'approvazione dell'anteprima.

## 4. Richiesta di decisione all'utente
Per l'anteprima rispondere **APPROVO / MODIFICA / NON VA BENE**. Poiché l'immagine non esiste, la decisione riguarda il percorso del §3:
- **APPROVO:** l'utente avvia Claude Code locale con il launcher; Claude esegue L0–L5 fermandosi a ogni fase per il consenso, poi si decide sui master Desmond e Lucy.
- **MODIFICA:** indicare cosa cambiare (es. RTX Remix come via principale, oppure nessuna estrazione e blockout soltanto dalle reference A-EXT secondo D9).
- **NON VA BENE:** si resta nella pre-produzione documentale.

Nel frattempo: **Fase D (primi 15 minuti) non avviata.**
