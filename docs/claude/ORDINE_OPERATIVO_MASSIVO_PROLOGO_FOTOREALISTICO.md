# ORDINE OPERATIVO A CLAUDE — FILM: PROLOGO FOTOREALISTICO, UN'ANTEPRIMA, VOCI ORIGINALI
**Priorità:** massima · **Richiesta esplicita dell'utente:** 13 ottobre 2026 · **Stato:** INCARICO DA ESEGUIRE, non lavoro già eseguito.
**Repository:** andrew14420100/FILM · **Edizione canonica:** Assassin's Creed II PC originale 2009/2010, posseduto su Ubisoft Connect.
**Hardware destinatario:** Windows + NVIDIA RTX 5070 Ti 16 GB. **Costo software:** zero; nessuna API a consumo né acquisto autorizzati.

## 0. LETTURA OBBLIGATORIA PRIMA DI INTERVENIRE
- `CLAUDE.md` e `docs/05_DECISIONI.md`: preservare ogni decisione approvata.
- `docs/preproduzione/PROLOGO_TRATTAMENTO_V1.md` (revisione interna V3) e `docs/preproduzione/REGOLA_ADATTAMENTO_CINEMATOGRAFICO.md`: storia canonica, ma **FILM, non gameplay**.
- `pilota_prologo/CATALOGO_COMPLETO_PROLOGO_ACII_2009_2010.md`, `pilota_prologo/INDICE_IMMAGINI_ACII_E_SHOTLIST_PROLOGO.md`, `pilota_prologo/REFERENCE_ONLINE_AC2_ABSTERGO_DESMOND_LUCY.md`: al momento sono sul branch della **PR #11**, non ancora in main; se non accessibili segna la dipendenza e usa i link GitHub: https://github.com/andrew14420100/FILM/pull/11.
- `docs/claude/SORGENTI_E_STRUMENTI_DA_VERIFICARE.md` e `docs/claude/ACCETTAZIONE_ANTEPRIMA_E_VOCI.md` (in questo branch).

### NUOVO ORDINE DELL'UTENTE
> Claude deve fare una **ricerca massiva e documentata** di tutto ciò che serve a ricostruire ambienti, personaggi, costumi, luci e oggetti **direttamente dagli asset originali di AC II**, dove concretamente possibile. Deve trasformare la resa in **cinema live-action fotorealistico**: come se una telecamera reale fosse fisicamente nella stanza, non un videogioco con risoluzione più alta. **Dopo ricerca/verifiche deve presentare UNA SOLA immagine di anteprima** di come potrebbe apparire la prima scena. L'utente valuta la foto; **SOLO DOPO approvazione esplicita** si potrà considerare una prova dei **primi 15 minuti**, non prima. **Le voci devono essere quelle italiane ORIGINALI del gioco per ogni personaggio**, ricavate da fonti autorizzate/disponibili all'utente: non vanno sintetizzate, clonate, ricreate, alterate nell'identità, sostituite con TTS o doppiate da nuovi attori. L'eventuale sola pulizia tecnica dell'audio è rinviata. Nessuna musica o audio copiato va pubblicato su GitHub.

## 1. FASE A — RICERCA MASSIVA REALE, NON PER IPOTESI
1. Esaminare **tutti i documenti esistenti** del repository, ricercare online (GitHub, manuali tecnici, forum di reverse engineering, wiki con gallerie, archivi scene, articoli degli artisti originali, documentazione dei formati), e annotare per **ogni fonte**: URL reale verificato, data/gioco/versione indicata, autore, licenza o condizioni d'uso note, funzionalità **provata/documentata/ipotizzata**, stato di accessibilità, versioni software e limiti. **Non inventare link, file, nomi strumenti, timestamp o compatibilità.**
2. Individuare gli **archivi veri del gioco PC** e la loro corrispondenza agli ambienti del prologo. Controllare struttura `DataPC*.forge`, possibili risorse `DataPC_WhiteRoom.forge`, archivi dei livelli Abstergo, ambienti 1459/1476 e altri dati; il solo nome dell'archivio **non certifica** che contenga una stanza specifica.
3. Identificare e testare compatibilità **AC II originale** dei lettori `.forge`, estrattori mesh, importer Blender, export OBJ/FBX/glTF, texture, skeleton e animazioni, strumenti RTX Remix e alternative. Verificare se mantengono **coordinate, gerarchia/istanziazione, UV, scala, rig, materiali e illuminazione** oppure esportano soltanto oggetti isolati. Registrare errori e limiti.
4. Preparare **inventario a sola lettura** e script di verifica non distruttivi per Windows. L'installazione del gioco **NON può essere letta da una sessione cloud** senza un computer/artefatti accessibili; non dichiarare file estratti prima di averli aperti. Mai alterare, patchare o sovrascrivere la copia Ubisoft Connect, mai aggirare DRM o controlli d'accesso. Lavora solo su backup privati leciti e per uso personale, nel rispetto dei diritti.
5. Per **ogni singolo ambiente/protagonista/prop del prologo** predisporre tabella di copertura: `TROVATO NEL FILE LOCALE / VISTA A-EXT / CONCEPT B / SOLO TESTO C / MANCANTE / NON VERIFICATO`. Verificare i 14 gruppi di reference e tutti i personaggi, non limitarsi a Desmond/Lucy.
6. Valutare costo hardware e memoria senza indovinare: stima pesi/modelli/scene, test locale di performance e percorso di fallback gratuito. Differenziare rendering GPU geometrico (Blender/Eevee/Cycles/RTX Remix) dalla generazione video AI. **Il video generativo da prompt non può bloccare strutture e volti al pixel.**

**Deliverable Fase A:** `docs/ricerca_massiva/INDICE_ASSET_ACII.md`, `MATRICE_ENV_E_PERSONAGGI.md`, `BENCHMARK_TOOLCHAIN.md`, `LIMITI_E_DIRITTI.md`, script non distruttivi (facoltativi). Ogni elemento deve avere URL o verifica locale, o indicazione **DA VERIFICARE**. Nessun asset proprietario su GitHub.

## 2. FASE B — RICOSTRUZIONE REALE, FEDELE MA VISIVAMENTE VIVA
**Scopo:** gli asset del gioco servono eventualmente da **riferimento geometrico**, NON da immagine finale pronta. La camera deve sembrare inserita in un set reale, non dentro il motore di AC II.

1. **Geometria:** ricostruire in **Blender** o pipeline verificata un `ABSTERGO_ENV_MASTER` con porte, pareti, camera di Desmond, laboratorio, console e griglie realmente coerenti con AC II. Preferire mesh originali quando recuperate lecitamente e con sufficiente integrità. Se l'estrazione perde un'intera stanza, completarla **manualmente come interpretazione indicata**, non attribuirla all'originale. Mai dichiarare esatto ciò che è inferito.
2. **Materiali fisici:** usare PBR per vetro vero, metallo, intonaco, tessuti, plastica e pelle; roughness e riflessi fisicamente plausibili; **non** lasciare texture pixellose o surface shading da gioco. Ricostruire texture ad alto dettaglio **senza inventare loghi, oggetti o geometrie storicamente non supportati**.
3. **Luce cinematografica:** luci reali nel set, GI / contact shadows, falloff, esposizione coerente, temperatura del colore motivata dalle scene. Texture e dettagli credibili: impronte, micrograffi, materiale vissuto ma **Abstergo resta clinica, non sporca come un edificio abbandonato**.
4. **Camera fisica:** inquadratura con focale e prospettiva coerenti, DOF dosata, altezza realistica, ottiche/aberrazioni minime, moto realistico; disattivare HUD, minimappe, animazioni di interfaccia per giocatore. Il film **non deve sembrare una scena renderizzata dalla vecchia engine** né un gameplay rimasterizzato.
5. **Personaggi:** `DESMOND_MASTER_ACII` e `LUCY_MASTER_ACII` con volto, proporzioni, capelli, abiti **uniformi in ogni shot**. Se il master non è ancora verificabile, segnare prototipo e **non chiamarlo identico**. Il regista deve poter girare la camera attorno ai personaggi senza mutamenti. Movimento/recitazione umani, volto con microespressioni, peso corporeo, tessuti realistici e contatto fisico con ambiente, non rigidezze da NPC.
6. **Coerenza temporale:** Animus 1.28 (Abstergo) ≠ Animus 2.0 (rifugio). La nascita di Ezio **avviene prima della fuga**, non eliminare sequenze canoniche. Titolo FILM solo sui tetti con Federico secondo R-TITOLO.
7. **Rendering e qualità:** lavorare prima a risoluzione di verifica e conservare **una scena editabile** sul PC. Obiettivo finale 4K solo dopo prova concreta e tempo/VRAM misurati; **un PNG ingrandito a 3840×2160 non è 4K nativo**.

**Deliverable Fase B:** progetto di scena **locale e privato** `ABSTERGO_ENV_MASTER` se gli strumenti consentono, relazione su provenienza, scostamenti, materiali, schema camera e check continuità. Non caricare `.blend`, mesh, texture o file proprietari nel repository pubblico senza controllo diritti e consenso.

## 3. FASE C — UNA E UNA SOLA IMMAGINE DI ANTEPRIMA
**L'utente vuole prima un'immagine singola di valutazione**, non quattro immagini né un video. Se c'è un ambiente e personaggi sufficientemente verificati, produrre localmente **un frame cinematografico orizzontale 16:9**.

**Shot deciso per la prova:** `PREVIEW-01` — laboratorio/stanza di Desmond ad Abstergo, nel momento in cui **Lucy entra e Desmond si volta verso di lei**. Inquadratura cinematografica grandangolare moderata o piano medio a due, entrambi riconoscibili, parte dell'ambiente chiaramente leggibile (porta, pareti, letto/postazione a seconda della disposizione reale), luci fredde naturali. Niente HUD, scritte decorative, segnaposto, loghi sovrapposti o filtri da gameplay. Conservare costume originale AC II: verificare il top di Lucy, le macchie e l'abbigliamento di Desmond prima del frame. **Una sola immagine finale**, nessun collage, nessun set di varianti.

- Salvare localmente come `FILM_PREVIEW_01_ABSTERGO.png` in area privata non tracciata da Git.
- Se Claude ha accesso a un canale/strumento capace di **mostrare realmente l'immagine all'utente**, allegarla lì per la revisione (senza spacciarla per screenshot del gioco; sarà un'anteprima di remake). In GitHub pubblico caricare **solo report, non file immagine Ubisoft o ricostruzioni basate su asset proprietari**.
- Nel report indicare: risoluzione realmente renderizzata, motore, materiali/asset usati, fonte geometria, grado di fedeltà, elementi inventati/indeducibili, durata e VRAM misurate su PC, e **possibilità di riutilizzare la stessa stanza e i volti in altre camere**.
- **Se il sistema di Claude non può usare il PC, non ha un renderer oppure non ha l'asset legittimamente accessibile, NON dichiarare di aver generato l'immagine; segnalare il blocco in modo circostanziato e fornire un singolo percorso manuale verificato.**
- Non creare altre immagini non richieste.

**STOP OBBLIGATORIO DOPO PREVIEW-01.** Chiedere all'utente di scegliere **APPROVATA / DA CORREGGERE / NON MI PIACE**. Non creare clip o sequenze aggiuntive prima di una conferma positiva.

## 4. FASE D — SOLO SE L'UTENTE APPROVA: PRIMI 15 MINUTI
**NON AUTORIZZATA ORA.** Dopo approvazione esplicita della **preview** e richiesta di procedere:
- decomporre il **prologo V3** in shot e shot-lock professionali secondo l'ordine del gioco, incluse memoria del parto, fuga, rifugio e transizione verso Firenze;
- fare pianificazione vera del **blocco fino a 15 minuti** senza riempitivi, separando durata effettiva della storia e obiettivo temporale; se il prologo approvato è più breve, non aggiungere scene solo per arrivare al numero;
- stimare GPU/VRAM, ore di produzione e fattibilità su RTX 5070 Ti **con benchmark**, poi produrre **solo dopo ulteriore via libera operativo** a cronoprogramma/risorse.
- montaggio, continuità di set, volti, costumi, recitazione, lip sync e audio richiederanno verifiche autonome.

## 5. REGOLE VINCOLANTI PER LE VOCI — SOLO AUDIO ITALIANO ORIGINALE DEL GIOCO
- **Per tutti i personaggi:** usare esclusivamente le **voci originali in italiano come già incise nel gioco**, con timbro e interpretazione originali. **Niente** generazione vocale, IA TTS, voice cloning, voice conversion, sostituzione attori, manipolazione del timbro/pitch/prosodia, nuova recitazione simulata, filtri per imitare il doppiatore. L'eventuale sola pulizia di rumore/qualità sarà valutata **più avanti** e non è autorizzata qui.
- **Inventario audio**: ricercare `SoundData/pc/sounds_ita.pck` della copia AC II Windows, catalogare le tracce/linee disponibili e come vengono associate alle cutscene; anche `sounds_sfx.pck` è distinto. Sono candidature da verificare nella copia posseduta, non garantire che ogni voce sia già isolata e disponibile.
- Verificare gli **strumenti reali** per leggere i pacchetti con copia privata in sola lettura senza bypass DRM/criptazioni o protezioni tecniche. Registrare bitrate, frequenza campionamento, codec, canali, id evento, nome personaggio, linea e lingua quando verificabile; **non inventare una trascrizione di battute assenti**.
- **Biblioteca vocale privata** sul PC con nome speaker, sequenza/cutscene, timecode realmente misurato, qualità, sorgente legittima, licenza/stato di permesso. Non pubblicare o distribuire voci, interi pacchetti audio o doppiaggio originale Ubisoft.
- **Limite fondamentale:** una registrazione originale può pronunciare solo le parole effettivamente registrate. **Senza sintesi, doppiaggio nuovo o manipolazione non è possibile farle pronunciare dialoghi inesistenti.** Quindi mappare le battute della sceneggiatura sulla disponibilità reale; segnalare `AUDIO_ORIGINALE_ASSENTE` e proporre riscrittura/riduzione delle battute, silenzio motivato o chiedere nuova decisione all'utente. **Non aggirare il vincolo con clonazione clandestina**.
- Prima di qualsiasi uso, distinguere studio locale privato da redistribuzione: il fatto di possedere AC II non trasferisce diritti sui doppiaggi. Non promettere disponibilità o autorizzazione alla pubblicazione; se servono diritti/licenze, segnalarli.

**Deliverable audio:** `docs/ricerca_massiva/VOCE_ITALIANA_ORIGINALE_CATALOGO.md` con dati delle sorgenti, metodologie lecite, possibili limiti e **tabella PERSONAGGIO → CLIP ORIGINALE → SCENA** (righe ancora vuote dove non verificato). **NESSUN file vocale su GitHub**.

## 6. PORTATA, REQUISITI DI QUALITÀ E DIVIETI
- Ricerca **massiva**, non ricerca superficiale su tre screenshot; verificare una per una stanze, personaggi, accessori e audio di TUTTO il prologo.
- Il repo FILM è **pubblico**: solo istruzioni, URL, codice originale, dati ricavati non coperti da copyright salvo quanto lecito. File di gioco, mesh, voci, fotogrammi, campioni/soundbanks e reference private devono rimanere **esclusivamente locali**.
- Niente costi, API a consumo, infrastrutture cloud a pagamento o acquisti, in assenza di approvazione espressa.
- Non assumere di avere accesso al PC o al filesystem di AC II tramite GitHub Cloud.
- Non alterare i master/decisioni storicamente approvati; proporre nuove revisioni come PR separate in bozza.
- Non inventare percentuali di completezza né dimostrazioni; distinguere `RICERCA DOCUMENTATA / VERIFICATO SU PC / TESTATO / PROPOSTA / MANCANTE`.
- Prima consegna tecnica: **rapporto reale della Fase A**; prima consegna visiva (solo se fattibile): **UNA anteprima PREVIEW-01**.
- **Primi 15 minuti non autorizzati**: dopo una singola anteprima soddisfacente, chiedere espressa conferma.

## 7. CHECKLIST DI ACCETTAZIONE
- [ ] Elenco asset/ambienti e personaggi **completo di ogni voce** del catalogo del prologo, con stato e link reale.
- [ ] Tabella di strumenti `.forge` / mesh / texture / suoni italiane compatibili AC II, **provati o classificati non testati**.
- [ ] Valutazione RTX Remix vs Blender/extraction motivata da prove e licenza.
- [ ] Mappa spaziale della cella/laboratorio coerente, senza geometrie inventate presentate come canon.
- [ ] Desmond e Lucy con reference e abito AC II, identità costante; nessun CGI plasticoso/videogioco.
- [ ] **Una sola preview fotorealistica reale** o blocco tecnico documentato; mai dichiarare un render non eseguito.
- [ ] Inventario voci italiane **originali**, niente TTS/cloni/alterazioni.
- [ ] Misure reali di risoluzione/performance dove disponibili; no 4K finto.
- [ ] **STOP** prima di primi 15 minuti, in attesa di valutazione dell'utente.
