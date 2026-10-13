# LIMITI_E_DIRITTI — vincoli per l'uso dei materiali di AC II

**Stato:** DA VERIFICARE · **non è un parere legale.** È un elenco prudenziale di vincoli tratti da CLAUDE.md, dall'issue #12 e dalle fonti tecniche. Per un uso che vada oltre la visione privata serve un consulente.

## 1. Premesse di fatto
| Fatto | Stato |
|---|---|
| L'utente possiede AC II originale per PC su Ubisoft Connect (D1) | APPROVATA (D1) |
| *Assassin's Creed II*, i suoi personaggi, i modelli, le texture, le voci, la musica, i filmati, il logo Abstergo e i messaggi del Soggetto 16 sono opere protette di Ubisoft (e dei rispettivi interpreti) | Fatto generale; licenza d'uso specifica (EULA Ubisoft) **DA VERIFICARE** dall'utente |
| Il repository GitHub del progetto è **pubblico** | Dichiarato dall'utente (#12) |
| Il film è un progetto **privato e non commerciale** | Dichiarato in CLAUDE.md |

## 2. Regole operative (vincolanti)
1. **Mai su GitHub:** mesh, texture, glTF/USD, audio (`.wem`, `.wav`, `.ogg`), video, fotogrammi, screenshot, sottotitoli o testi di dialogo, e il futuro `FILM_PREVIEW_01_ABSTERGO.png`. Su GitHub vanno soltanto Markdown e script originali.
2. **Spazio privato:** proposta `D:\FILM_PRIVATO\` (o un altro disco locale dell'utente) con sottocartelle `acii_copia\`, `estratti\`, `audio_ita\`, `blender\`, `render\`. È da escludere da qualsiasi sincronizzazione cloud pubblica.
3. **Copia Ubisoft Connect intoccabile:** non modificare, patchare, sovrascrivere né aggiungere file nella cartella di installazione. Strumenti come ac2-rtx o RTX Remix vanno usati solo su una **copia** della cartella. **Se** la copia non si avvia senza aggirare il launcher o il DRM, ci si **ferma**: aggirare DRM o controlli d'accesso è vietato.
4. **Nessun binario non controllato:** prima di installare AnvilToolkit, QuickBMS, vgmstream o RTX Remix, l'utente scarica **solo** dalle pagine ufficiali degli autori elencate in [BENCHMARK_TOOLCHAIN.md](BENCHMARK_TOOLCHAIN.md) e controlla l'antivirus. Niente pacchetti ripubblicati da terzi.
5. **Nessun asset di terzi:** niente mesh «ripped» scaricate, mod con asset ridistribuiti o pacchetti di voci di terzi (CLAUDE.md: nessun download o import automatico).
6. **Voci:** soltanto le registrazioni italiane originali estratte dalla copia legittima dell'utente. **Vietati** TTS, clonazione, conversione della voce e alterazione di timbro o tono (#12). Eventuali pulizie (rumore, livelli) sono **rinviate** e da autorizzare. Le voci restano protette anche quando vengono usate in privato: diritti degli interpreti e di Ubisoft.
7. **Dialoghi:** nessun testo di dialogo copiato nel repository (CLAUDE.md, vincolo 5). Il catalogo voci contiene solo **codici e descrizioni**, non le battute.
8. **Somiglianza delle persone:** Desmond, Lucy e Ezio hanno modelli e volti basati su attori o modelli reali. Le ricostruzioni fotorealistiche servono soltanto alla visione privata. **Non pubblicare** immagini dei volti ricostruiti.
9. **Claude Code e dati:** con Claude Code, locale o in Windows Sandbox, ciò che Claude legge con i suoi strumenti viene inviato ai modelli Anthropic tramite l'account dell'utente. Non far leggere per intero file del gioco dentro la conversazione; lavorare con tool locali e riportare sintesi. Con la rete attiva la Sandbox vede anche la rete locale ([SANDBOX_WINDOWS.md](SANDBOX_WINDOWS.md) §4).
10. **Servizi:** niente pagamenti, API a consumo o servizi cloud di generazione senza autorizzazione esplicita (CLAUDE.md, vincolo 7).
11. **Marchi:** il logo Abstergo e le grafiche dei messaggi non vanno ricreati in file pubblici; nei documenti si descrivono a parole.

## 3. Limiti tecnici che incidono sulla fedeltà
| Limite | Conseguenza | Fonte | Stato |
|---|---|---|---|
| I modelli AC II (2009) sono a basso numero di poligoni | Vanno usati come **riferimento di forma e proporzioni**, non come resa finale fotorealistica | Data del gioco e motore Scimitar in D3D9 (README di ac2-rtx) | DOCUMENTATO |
| Con ac2-rtx la luce è piatta e mancano le normal map | Le catture Remix non sono fotoreali senza rifare i materiali | README di ac2-rtx | DOCUMENTATO |
| Patch di ac2-rtx legate a un MD5 specifico | Sulla build Ubisoft Connect potrebbero non funzionare | README di ac2-rtx | DOCUMENTATO; MD5 dell'utente DA VERIFICARE |
| Export della scena intera con posizioni da AnvilToolkit per AC2 | Se non disponibile, la pianta va ricostruita a mano dalle reference | Wiki di AnvilToolkit (export «scene» documentato in generale) | IPOTESI |
| I nomi dei banchi audio vengono da X360 | La mappatura sul PC va confermata | wwiser-utils | IPOTESI |
| Gli eventi Wwise sono hash, non testo | La mappatura clip → scena richiede ascolto e sottotitoli | Documentazione di wwiser | DOCUMENTATO |
| La sessione cloud di Claude non vede il PC dell'utente | Claude non può né testare né produrre l'anteprima basata sui file del gioco | Ambiente di sessione | Fatto |

## 4. Gate di approvazione
- L'anteprima `FILM_PREVIEW_01_ABSTERGO.png` richiede la pipeline verificata (#12, Fase C) e resta privata. La sua valutazione (APPROVO / MODIFICA / NON VA BENE) spetta all'utente.
- I primi 15 minuti (Fase D) **non sono autorizzati**.
- Nessun merge di questa PR senza approvazione.
