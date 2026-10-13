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

**Criterio «pipeline verificata»:** T1–T4 di [BENCHMARK_TOOLCHAIN.md](BENCHMARK_TOOLCHAIN.md) superati e annotati, più i master Desmond e Lucy approvati dall'utente. Solo allora si fa **un solo** render.

## 3. Unico percorso manuale (da eseguire sul PC dell'utente, quando e se vorrà)
I passi seguono la documentazione degli autori (vedi BENCHMARK). **Non sono stati testati da Claude**: ogni passo ha il suo controllo.

1. **Inventario in sola lettura.** In PowerShell, eseguire `docs/ricerca_massiva/scripts/inventario_acii_readonly.ps1 -GameDir "<cartella AC II>" -OutDir "D:\FILM_PRIVATO\inventario"`. *Controllo:* il CSV elenca `DataPC_Abstergo.forge` e riporta l'MD5 dell'exe.
2. **Copia privata.** Copiare **soltanto** `DataPC_Abstergo.forge` (e in seguito `DataPC.forge`) in `D:\FILM_PRIVATO\acii_copia\`. *Controllo:* la data di modifica dei file originali non cambia.
3. **AnvilToolkit** (dalla pagina ufficiale dell'autore, dopo il controllo antivirus): aprire la **copia** del forge, cercare il laboratorio o la camera nel Mesh Viewer ed esportare la scena in glTF in `D:\FILM_PRIVATO\estratti\abstergo\`. Convertire le normal map AC II con il Texture Viewer. *Controllo:* il glTF si apre in Blender 5.2 con il preset AnvilToolkit per Blender 5.0.
4. **Blender 5.2 LTS:** creare `ABSTERGO_ENV_MASTER.blend` in `D:\FILM_PRIVATO\blender\`. Usare il glTF come riferimento di scala e forma, rimodellare e assegnare materiali PBR, illuminare, poi un render di prova **solo dell'ambiente** a 3840×2160 con Cycles/OptiX. *Controllo:* annotare il tempo per fotogramma e la VRAM (T4).
5. **Stop e decisione:** l'utente valuta il render dell'ambiente e decide se approvare il lavoro sugli umani `DESMOND_MASTER_ACII` e `LUCY_MASTER_ACII` (ad esempio con MetaHuman, previa lettura della licenza). Solo dopo l'approvazione dei master si fa il render unico `FILM_PREVIEW_01_ABSTERGO.png`, salvato in `D:\FILM_PRIVATO\render\` e **mai su GitHub**.

Le alternative (ac2-rtx e RTX Remix come planimetria USD) restano **facoltative** e solo su una copia dell'intera installazione: non fanno parte del percorso unico.

## 4. Richiesta di decisione all'utente
Per l'anteprima rispondere **APPROVO / MODIFICA / NON VA BENE**. Poiché l'immagine non esiste, la decisione riguarda il percorso del §3:
- **APPROVO:** l'utente esegue i passi 1–4 sul suo PC (o chiede a Claude di affiancarlo passo per passo con i risultati incollati come testo) e poi si valuta il passo 5.
- **MODIFICA:** indicare cosa cambiare (es. RTX Remix come via principale, oppure nessuna estrazione e blockout soltanto dalle reference A-EXT secondo D9).
- **NON VA BENE:** si resta nella pre-produzione documentale.

Nel frattempo: **Fase D (primi 15 minuti) non avviata.**
