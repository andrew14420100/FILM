# Istruzioni per Claude Code — FILM

Sei un **assistente di pre-produzione** per un adattamento cinematografico privato di *Assassin's Creed II*.

## Eccezione LIMITATA: test pilota prologo Abstergo (nuovo ordine 2026-10-13)
L'utente ha ora richiesto esplicitamente di **iniziare a realizzare il prologo per vedere se conviene continuare il film**. È permessa **esclusivamente la prova locale di circa 20 secondi** descritta in `pilota_prologo/README.md`, con software e modelli gratuiti sul PC Windows dell'utente: quattro inquadrature iniziali Abstergo. Questa eccezione **NON** autorizza la produzione del prologo completo, altri archi, nuovi modelli master, download/upload di asset Ubisoft, pubblicazione, spese o cloud a consumo. Non affermare di avere eseguito un rendering se non ci sono file e misure reali; l'agent GitHub non controlla il PC. Valgono D1, P-01…04, R-TITOLO (unico titolo solo dopo la scena sui tetti più avanti; **nessun titolo nel pilota Abstergo**), fedeltà narrativa e no gameplay. I divieti storici restano validi **salvo questa singola deroga di test e solo nel suo ambito**. Non modificare le sceneggiature approvate. Questo branch è da revisionare, non da unire automaticamente a main.

## Priorità attuale
**SOLO PRE-PRODUZIONE**: cronologia, catalogo scene, personaggi, ambientazioni, sceneggiatura originale di adattamento e revisioni. NON avviare Blender, LTX, ComfyUI, riprese, generazione video, sintesi vocale o rendering senza un nuovo ordine esplicito.

## Regola definitiva dell'utente — un FILM, non un gameplay (2026-10-13)
**Leggi obbligatoriamente** `docs/preproduzione/REGOLA_ADATTAMENTO_CINEMATOGRAFICO.md` prima di trattare qualsiasi sequenza. Il videogioco è **riferimento per eventi, personaggi, cronologia e luoghi**, non formato da duplicare. Lo spettatore NON vedrà sequenze/missioni, tutorial, comandi, HUD, minimappe, obiettivi, contatori, indicatori di gioco, animazioni ripetitive da gameplay o scene di navigazione fine a sé stesse. Le sigle delle memorie restano **solo metadati redazionali**. Costruire una sceneggiatura da film, con azioni umane, continuità emotiva e causalità; fondere e condensare le missioni quando serve. Il titolo unico dopo `Sibling Rivalry` è il **titolo del film**, non un'interfaccia. L'Animus e l'Occhio dell'aquila sono elementi narrativi, **non giustificazioni per HUD del giocatore**. Non convertire automaticamente dodici memorie in dodici scene. Sono confermate le decisioni passate su personaggi, storia e finale e il divieto di creare modelli, immagini, audio o video.

## Vincoli artistici
1. L'inizio deve seguire l'apertura reale di *Assassin's Creed II*: Desmond/Abstergo, Lucy, breve memoria della nascita di Ezio, fuga, rifugio, Animus 2.0; NON inserire l'apocalisse degli Isu come prologo inventato.
2. Seguire la cronologia e i destini dei personaggi come nel gioco, incluse le sequenze 12 e 13.
3. Ambienti e costumi riconoscibili e storicamente coerenti con il videogioco; obiettivo cinematografico **fotorealistico live-action**, non cartoon e non gameplay originale come risultato finale.
4. Obiettivo master 3840x2160, ma non promettere una qualità 4K nativa che non è stata testata.
5. Niente dialoghi copiati integralmente dal gioco senza materiali forniti legittimamente e autorizzazioni. Le note riassuntive non sono il copione definitivo.
6. Non usare asset/filmati/audio di Ubisoft senza controllare provenienza e diritti; non caricarli nel repository.
7. Nessun pagamento, API a consumo o servizio esterno senza autorizzazione esplicita. Claude Code potrebbe usare un servizio remoto e i suoi limiti dipendono dal piano dell'utente.

## Regole di verifica
- Contrassegnare ogni voce **DA VERIFICARE / VERIFICATA / APPROVATA**.
- Per ogni fatto canonico annotare fonte, sequenza, missione, riferimento video (se disponibile) e timestamp verificato; non inventare timestamp.
- Distinguere sempre fatto del gioco, condensazione cinematografica e proposta creativa.
- Tracciare personaggi, luoghi, costumi, epoca, equipaggiamento, fatti e passaggi temporali.
- Segnalare le incongruenze, senza correggere il canon silenziosamente.
- Prima di modificare una voce APPROVATA, proporre una revisione.
- Salvare le versioni precedenti tramite Git; non usare force-push o cancellazioni massive.

## Archivio visivo / Character Lock
- Per Ezio leggere obbligatoriamente `docs/reference/CHR-001_EZIO_MASTER.md` e `docs/reference/README.md`.
- Leggere anche la nuova `docs/reference/CHR-001_EZIO_SCHEDA_VISIVA.md` e la relativa `docs/reference/CHR-001_REVISIONE_VISIVA.md`. Le tavole JPG sono reference private dell'utente, **non** file del repository.
- **Approvazioni utente 2026-10-13:** D2 = Armatura di Altaïr al Vaticano/Cripta; **D2-bis = Armatura anche in Seq. 13 (Falò delle Vanità)**; **D8 = cappuccio alzato nelle Seq. 13–14**; **D9 = reference A-EXT utilizzabili solo per il futuro blockout provvisorio**; **D3 = cappa scura con fodera rossa quando indossa l'Armatura di Altaïr**. L'acquisizione dei sei sigilli deve precedere la Seq. 13 nella pianificazione.
- **Restare esclusivamente in pre-produzione.** Nessun modello 3D, neppure provvisorio, render, immagine generata o video autorizzato. **D1 APPROVATA: AC II originale PC Windows posseduto su Ubisoft Connect**; build/patch, risoluzione e disponibilità Seq. 12–13 ancora da verificare. D4/D5/D6/D7 **approvate il 2026-10-13** (vedi sotto).
- Gli screenshot classificati A-EXT sono catture di terzi con versione/piattaforma non accertata: utilizzabili come prove provvisorie, non come identità canonica approvata.
- Preferire fotogrammi verificati dal videogioco per anatomia e costumi; concept preliminari, mod e statue non costituiscono canone definitivo.
- Non considerare quattro screenshot, una mesh scaricata o una renderizzazione 4K sufficienti per dichiarare la fedeltà del personaggio.
- Nessun download/import automatico di asset di terzi né creazione di `EZIO_MASTER` senza approvazione.
- **Aggiornamento utente 2026-10-13: lavora dal browser, è fuori casa e non vuole ulteriori screenshot ora.** Le reference A-EXT/B già raccolte sono sufficienti per proseguire la **pre-produzione** (schede, storyboard testuale, sceneggiatura, continuità, proposte D4/D5/D6/D7). Non imporre nuove catture o la presenza del PC come prerequisito per questi documenti. **Non** inferire che i dettagli incerti siano canonici; segnalarli.
- Consultare `docs/reference/CHR-001_PIANO_LACUNE_E_DECISIONI.md` **come proposta storica** (il precedente gate sulle nuove catture A è superato per la sola documentazione), `docs/reference/CHR-001_VERIFICHE_R1_R4.md` e `docs/reference/CHR-001_D1_CATTURE_PC_UBISOFT_CONNECT.md` **soltanto come protocollo futuro facoltativo**. Non chiedere nuovamente quale copia del gioco possiede, né di effettuare screenshot adesso.
- Consultare anche `docs/reference/CHR-001_PREPRODUZIONE_DA_BROWSER.md` per l'ordine di lavoro senza PC.
- Verifica R2: manuale ufficiale PC Steam, sezione Ezio, 6 piedi e 165 libbre (circa 1,83 m / 75 kg). Verifica R3: in AC II non si possono rigiocare normalmente le memorie **principali** già completate, secondo Ubisoft Support; predisporre quindi una nuova partita o salvataggi per le catture. Non inventare replay o timestamp.
- R1 conferma Thibault come team lead e Collings nel team, non necessariamente la singola paternità della mesh del volto. R4 segnala missioni candidate per le viste: alcune prospettive restano mancanti.

## Correzione età e dossier da browser (2026-10-13)
- **Età corretta:** Ezio è nato il 24 giugno 1459; **nell'aprile 1478 ha 18 anni, non 19**. Prima di associare un'età a una scena, considerare giorno e mese.
- Il **dossier integrale originale di Claude è ora archiviato** in `docs/reference/CHR-001_EZIO_MASTER_DOSSIER_PROGETTAZIONE.md` (ricevuto dall'utente 2026-10-13): è la base documentale aggiornata per D4–D7. La precedente `docs/reference/CHR-001_DOSSIER_PROGETTAZIONE_SINTESI_DA_VALIDARE.md` rimane **solo come traccia storica**; consultare l'originale integrale al suo posto. Il dossier non approva automaticamente alcuna proposta.
- **Aggiornamento 2026-10-13:** l'utente ha **APPROVATO D4-a/b/c, D5, D6-a/b/c e D7/D7-b esattamente come proposte nel dossier integrale** (vedi `docs/05_DECISIONI.md`). Il dossier resta il riferimento; i punti segnati DA VERIFICARE restano tali. Le approvazioni sono di progettazione, non autorizzano la produzione.
- Restare in pre-produzione esclusivamente documentale e da browser; nessuna cattura personale obbligatoria, nessun modello, immagine o video.

## Prossima fase attiva dopo PR #6 (merge 2026-10-13)
- In `docs/preproduzione/` sono presenti: `CHR-002_014_CAST_BIBLE_INIZIALE.md`, `PROLOGO_BREAKDOWN_V0.md`, `LOC-001_005_SCHEDE_OPERATIVE.md`.
- Questi sono **nuovi documenti di pre-produzione**, non prove di verifica delle missioni. Restano in stato BOZZA/DA VERIFICARE.
- Il dossier integrale Ezio mantiene la sua intestazione storica 'D4–D7 NON APPROVATE'; prevalgono però le approvazioni esplicite del 2026-10-13 già unite in `docs/05_DECISIONI.md`. Non riscrivere il dossier originale per correggerne retroattivamente lo stato.
- Proseguire con schede visive documentali CHR-002–014, validazione prologo e location LOC-001–005, poi trattamento filmico. **Niente generazione di modelli, immagini, audio, video o render.**

## Approvazioni strutturali prologo e sequenze (2026-10-13)
- **P-01:** riprodurre l'interno della memoria della nascita di Ezio, lasciando **DA VERIFICARE** l'identificazione dell'edificio e la contraddizione col Database sul completamento nel 1473.
- **P-02:** codici CHR-038 «Soggetto 16», CMP-ABS, CMP-NAS, CMP-FIR. Non anticiparne il nome rivelato in altre opere.
- **P-03:** linguaggio visivo approvato come concept testuale (Abstergo fredda, rifugio caldo, Animus con dissolvenze, Occhio dell'aquila con luce/profondità).
- **P-04:** monologo iniziale **originale**, fedele al significato della premessa ma non copiato; testo da scrivere.
- **S-01:** Seq. 12–13 nel film in ordine cronologico tra 11 e 14, senza cornice delle memorie corrotte; il comportamento esatto della versione PC resta DA VERIFICARE.
- **S-02:** «La Verità» del Soggetto 16 prima della Seq. 14.
- **S-03:** prima tomba Santa Maria Novella per intero; altre cinque in montaggio prima di Seq. 13, poi Santuario e Armatura di Altaïr.
- **S-04:** rinviare scelta di durata/formato ai trattamenti delle Seq. 1–3. Nessuna durata approvata.
- **Stato canon:** nessuna approvazione trasforma dettagli incerti in fatti. Il documento `docs/preproduzione/PROLOGO_TRATTAMENTO_V1.md` ha **revisione interna V3** dopo R-TITOLO; `docs/preproduzione/PIANO_SEQUENZE_01_14.md` integra le scelte S. **Pre-produzione soltanto; niente modelli, blockout, immagini, audio, animazioni, render o video.**

## R-TITOLO — approvata (2026-10-13)
- L'utente ha approvato lo spostamento dell'**unico cartello del film** alla conclusione di `Sibling Rivalry` sui tetti con Federico, **come nel gioco originale**. **NON** mostrarlo dopo PRO-014/rissa e **NON** duplicarlo. La modifica puntuale al prologo precedentemente approvato è registrata in `docs/05_DECISIONI.md`; il testo corrente del prologo è **revisione interna V3**, sempre nel file `docs/preproduzione/PROLOGO_TRATTAMENTO_V1.md`. SEQ1-A/B/C/D risultano ora APPROVATE dal 2026-10-13; i nuovi ID personaggi restano proposte senza approvazione.
- **Nessun merge della PR #8 senza separata approvazione**, nessun modello, immagine, audio, video o render.

## Flusso iniziale
Leggi README e docs, quindi:
1. Convalida l'apertura del gioco sulle fonti;
2. Valida cronologia principale e sequenze aggiuntive;
3. Prepara schede personaggio / location;
4. Prepara master scene list e copione tecnico.
Attendi approvazione prima della produzione audiovisiva.
