# BENCHMARK_TOOLCHAIN — strumenti per ricostruire AC II in fotorealismo

**Stato:** DA VERIFICARE · ricerca documentale. **Nessuno strumento è stato TESTATO sui file AC II**: questa sessione cloud non ha accesso al PC dell'utente, né GPU NVIDIA, né Blender.
**Esistenza dei repository:** verificata il 2026-10-13 con `git ls-remote`. Le pagine HTML di github.com rispondono 403 al proxy della sessione, mentre i contenuti sono stati letti da `raw.githubusercontent.com` e dai wiki clonati.
**Regola anti-promessa:** nessun numero di prestazioni o di qualità 4K è dichiarato qui. Le misure sulla RTX 5070 Ti dell'utente sono **da eseguire** (CLAUDE.md, vincolo 4).

**Procedura attiva 2026-10-13:** Opzione 2 approvata; leggere [OPZIONE2_ARCHIVI_COPIATI.md](OPZIONE2_ARCHIVI_COPIATI.md). Ogni riferimento seguente a `DataPC_Abstergo.forge` o `sounds_ita.pck` riguarda **copie private separate**, non la cartella originale. Per il primo test copiare e validare **solo Abstergo**, mantenendolo read-only per Claude; qualsiasi esportazione di asset viene scritta nella WorkDir. L'audio italiano si tratterà soltanto dopo nuova autorizzazione. Nessun tool già provato su Windows.

## 1. Estrazione dei dati del gioco (solo su una COPIA privata)
| Strumento | URL | Cosa fa per AC II (dalla documentazione) | Stato | Rischi / note |
|---|---|---|---|---|
| **AnvilToolkit** (Kamzik123) | Risorse e wiki: https://github.com/Kamzik123/AnvilToolkit-Resources · wiki: https://github.com/Kamzik123/AnvilToolkit-Resources/wiki | Apre `.forge`/`.data`; **Mesh Viewer**: esporta la scena o i singoli mesh in **glTF**; **Texture Viewer**: esporta texture e **converte le normal map di AC II/Brotherhood** in normal map standard; esportazione e importazione delle **animazioni supportate per AC2**; le lezioni 3 e 4 usano proprio l'AnimSet di Desmond AC2 come esempio. Preset Blender per 3.6, 4.0 e 5.0. | DOCUMENTATO | Il binario si distribuisce fuori da GitHub: la pagina di download (Nexus) **NON RAGGIUNGIBILE** da qui, quindi reputazione e firma vanno controllate dall'utente prima di installarlo. L'**esportazione dell'intera stanza con le posizioni reali degli oggetti** per AC2 non è documentata esplicitamente: **IPOTESI**. |
| **QuickBMS** + `wwise_pck_extractor.bms` (Luigi Auriemma) | https://aluigi.altervista.org/quickbms.htm · https://aluigi.altervista.org/bms/wwise_pck_extractor.bms (entrambi HTTP 200) | Estrae `.bnk`/`.wem` da un pacchetto Wwise AKPK (`sounds_ita.pck`). | DOCUMENTATO | Autore storico e affidabile; usare sempre una **copia** del `.pck`. |
| **vgmstream** | https://github.com/vgmstream/vgmstream | Decodifica Wwise `.wem`/`.bnk` in WAV (CLI o plugin foobar2000). | DOCUMENTATO (formato elencato in `doc/FORMATS.md`) | Open source e molto diffuso. |
| **wwiser** (bnnm) | https://github.com/bnnm/wwiser | Legge i `.bnk`, ricostruisce gli eventi e genera file `.txtp` per vgmstream. | DOCUMENTATO | Serve a collegare gli eventi alle clip. |
| **wwiser-utils / wwnames** | https://github.com/bnnm/wwiser-utils | Elenco di nomi per AC II **X360** (banchi `BNK_VO_*`). | DOCUMENTATO | Validità sul PC: IPOTESI. |
| **ww2ogg** (hcs64) | https://github.com/hcs64/ww2ogg | Converte i vecchi `.wem` Vorbis in OGG. | DOCUMENTATO | Alternativa a vgmstream; non necessario se basta vgmstream. |

## 2. Cattura della scena dal gioco in esecuzione
| Strumento | URL | Cosa fa | Stato | Limiti dichiarati dagli autori |
|---|---|---|---|---|
| **NVIDIA RTX Remix** (runtime + toolkit) | https://github.com/NVIDIAGameWorks/rtx-remix | Path tracing dei giochi DX8/9 **fixed-function**; il comando «Capture Frame in USD» salva la scena (mesh, posizioni, camera, texture) in `rtx-remix/captures` accanto all'exe. | DOCUMENTATO (wiki `Runtime-User-Guide.md`, `Compatibility.md`) | AC II usa shader e **non** è compatibile in modo nativo: servono le patch di ac2-rtx. Il runtime **aggiunge file nella cartella del gioco**, quindi usare solo una copia. |
| **ac2-rtx** | https://github.com/Kamzik123/ac2-rtx (licenza MIT; basato su https://github.com/xoxor4d/remix-comp-base) | Riemette le draw call di AC II in fixed-function: geometria, camera, texture, personaggi (skinning su CPU), vegetazione e acqua arrivano al path tracer. | DOCUMENTATO | Dalla README dell'autore: **«Lighting is flat»**, perché il materiale legacy di Remix non ha lo slot per la normal map; le luci del gioco non sono mai state viste. **Work in progress.** Testato su exe MD5 `2dd4d3c196fa270945826d2faab42007`; su build diverse le patch non si applicano. Richiede un ASI loader nella cartella del gioco e patch in memoria: **solo copia privata, mai la copia Ubisoft Connect originale**. Va valutato rispetto ai controlli di Ubisoft Connect (vedi [LIMITI_E_DIRITTI.md](LIMITI_E_DIRITTI.md)). |

## 3. Ricostruzione e rendering fotorealistico
| Strumento | URL | Ruolo | Stato | Note |
|---|---|---|---|---|
| **Blender 5.2 LTS** | https://www.blender.org/download/lts/ (HTTP 200) | Import glTF o USD, rimodellazione in alta definizione, materiali PBR, **Cycles** con path tracing (OptiX su RTX), output 3840×2160. | DOCUMENTATO | Gratuito (GPL). Strumento principale proposto per `ABSTERGO_ENV_MASTER`. |
| **Unreal Engine 5** + **MetaHuman** | https://www.metahuman.com/en-US/license (HTTP 200) | Umani digitali fotorealistici per Desmond e Lucy. | DOCUMENTATO (licenza) | La pagina della licenza indica l'uso anche con altri software e la gratuità sotto una soglia di fatturato: **i termini esatti vanno riletti dall'utente prima dell'uso** (DA VERIFICARE). Creare un MetaHuman somigliante a un personaggio Ubisoft resta un tema di diritti (vedi LIMITI). |
| **ComfyUI + Wan 2.2 TI2V 5B** (pilota PR #11) | vedi `pilota_prologo/README.md` sul branch della PR #11 | Generazione video o immagini da testo e immagine. | DOCUMENTATO (nel pilota) | **Non** garantisce la fedeltà degli ambienti AC II né l'identità; utile al massimo come look-dev. **Non** usato qui. |

## 4. Confronto: RTX Remix contro estrazione + Blender
| Criterio | A. ac2-rtx + RTX Remix (cattura USD) | B. AnvilToolkit → glTF → Blender/Cycles |
|---|---|---|
| Fedeltà geometrica alla stanza del gioco | **Alta**: cattura il frame con posizioni e camera reali | Media: i singoli mesh sono certi, **la disposizione della stanza è un'IPOTESI** |
| Fotorealismo | **Basso** senza rifare i materiali (luce piatta dichiarata dall'autore) | **Alto potenziale**, dopo rimodellazione e materiali PBR rifatti |
| Rischio sul gioco | Più alto (file aggiunti e patch in memoria; solo su copia) | Più basso (lettura degli archivi copiati) |
| Personaggi fotoreali | No: modelli 2009 a basso numero di poligoni | No: stesso limite. Servono nuovi umani digitali (MetaHuman o scansione) |
| Hardware | RTX obbligatoria (5070 Ti dell'utente: idonea secondo i requisiti Remix, **da misurare**) | GPU RTX per Cycles/OptiX (stessa macchina) |
| Stato | DOCUMENTATO, non testato | DOCUMENTATO, non testato |

**Raccomandazione (PROPOSTA, da approvare):**
- **Ibrido**: B come pipeline principale, con A usato **solo** se serve una cattura USD come «planimetria» di riferimento per posizionare i mesh. A non va mai usato come resa finale.
- In ogni caso l'**illuminazione** e i **materiali** vanno rifatti da zero in Blender: è una proposta creativa e va segnalata come tale.

## 5. Benchmark da eseguire sulla macchina dell'utente (non eseguiti)
| Test | Misura | Criterio di accettazione proposto |
|---|---|---|
| T1 Inventario | Script in sola lettura: nomi, dimensioni, MD5 dell'exe (MD5 = solo confronto della build per ac2-rtx, **non** prova di sicurezza) | CSV privato prodotto; nessun file del gioco modificato (data di modifica invariata); inventario **completo**, cioè senza file `_errori.txt` |
| T2 Provenienza del mesh | Apertura della **copia** di `DataPC_Abstergo.forge` in AnvilToolkit; export glTF di **un** mesh del laboratorio | **Prova visibile e verificabile, solo in privato:** cattura del Mesh Viewer con il nome del forge e dell'entità, nome e SHA256 del glTF, stesso mesh aperto in Blender 5.2 con le texture convertite. Su GitHub va solo lo stato. **Un glTF esportato non dimostra di aver recuperato la sala intera.** |
| T3 Stanza intera | Export della **scena**: conteggio delle istanze e verifica di posizioni e rotazioni rispetto alle reference A-EXT (D9) | Sì, le istanze sono preservate → pipeline B completa. No → la pianta resta un'IPOTESI e si valuta A (cattura USD) come planimetria |
| T4a Test modesto 720p/1080p | Blockout `ABSTERGO_ENV_MASTER` in Cycles a 1280×720 e poi 1920×1080 | Verificate e annotate **scala** (es. porte e statura di 1,83 m come riferimento), **UV**, **materiali** e **camera** 16:9. Stop e decisione dell'utente |
| T4b 4K | **Nessun render 4K della stanza vuota.** Il 3840×2160 si usa solo per l'unico frame finale con Desmond e Lucy, dopo T4a e l'approvazione dei master | Tempo per fotogramma e VRAM misurati su quel frame; **nessuna dichiarazione di 4K nativo senza la misura** |
| T5 Audio | Estrazione di `sounds_ita.pck` (copia) e ascolto di una clip `BNK_VO_P01_*` | Clip ascoltata e annotata **solo in privato**; nessun upload |

## 6. Strumenti scartati o non verificabili
- Ripper generici di frame D3D (Ninja Ripper, 3D Ripper DX) e mesh già estratti scaricati da siti di terzi: **scartati**, per reputazione dei binari non controllabile e provenienza o diritti non verificabili (CLAUDE.md).
- ModDB, Nexus, SteamDB e la documentazione Omniverse: **NON RAGGIUNGIBILI** (403) da questa sessione; non usati come prova.
- TTS, clonazione e conversione della voce: **esclusi per ordine** (#12).
