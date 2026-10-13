# CHR-001 · EZIO AUDITORE DA FIRENZE — Scheda tecnica per EZIO_MASTER

**Stato documento:** BOZZA DA APPROVARE · **Data:** 2026-10-13
**Documento padre:** `docs/reference/CHR-001_EZIO_MASTER.md` (non modificato)
**Ambito:** solo *Assassin's Creed II* (2009) + DLC *Battaglia di Forlì* e *Falò delle Vanità*. Esclusi *Brotherhood*, *Revelations*, *Embers*, romanzi e *Renaissance*, salvo dove indicato per segnalare un conflitto.

> Nessun modello 3D, nessun render e nessun asset è stato generato. Le immagini B consultate sono state aperte solo per studio, in una cartella temporanea della sessione. Non sono state caricate su GitHub.

---

## 0. Legenda di stato e livelli di fonte

| Sigla | Significato |
| --- | --- |
| **A** | Fotogramma o filmato del gioco originale, acquisito dall'utente con versione, sequenza, missione e momento registrati. **Nessuna fonte A è ancora disponibile.** |
| **B** | Materiale Ubisoft: promo, copertine, concept e manuale. Può differire dal modello in-game. |
| **B\*** | Artwork attribuito a Ubisoft ma ospitato da un archivio terzo (Creative Uncut, AssassinsCreed.de). |
| **C** | Wiki comunitaria, mod, mesh di terzi, statue e action figure. |
| **VERIFICATA-B/C** | Confermata da una fonte B o C, ma ancora da confermare su una fonte A. |
| **DA VERIFICARE** | Dato plausibile ma non confermato. Non usarlo come vincolo. |
| **DECISIONE UTENTE** | Il canon lascia più opzioni (per esempio equipaggiamento scelto dal giocatore). Serve la tua scelta. |

Regola di conflitto (invariata): **A > B > C.** In caso di conflitto non si fa una media tra le fonti: vince la fonte di livello più alto.

---

## 1. Esito dello studio delle reference (punti 1, 2 e 7)

### 1.1 Fonti B/B\* esaminate direttamente

| Ref | File studiato | Cosa mostra davvero | Utile per | NON utile per / avvertenze |
| --- | --- | --- | --- | --- |
| EZ-B06 | `ac2-ezio1` (render promo a figura intera, sfondo bianco) | Vesti di Giovanni con cappuccio alzato, doppia lama celata, cappa sulla spalla sinistra, fascia rossa, fibbia-insegna, pannelli inferiori ricamati, stivali | Silhouette, ordine degli strati, palette, disposizione di cinture e foderi | Volto coperto dal cappuccio fino al naso. Doppia lama già estratta: è uno stato successivo al 1478 |
| EZ-B06 (stessa galleria) | `ac2-ezio2` (promo: uccisione di un nobile) | Stesse vesti, lama destra estratta, cappa con fodera rossa | Panneggio del cappuccio, ombra sul volto | Volto parziale. Scena promozionale, non canonica |
| — | `ac2-ezio3` (key art di copertina) | Vesti, doppia lama, folla | Atteggiamento e postura | Effetti grafici dell'Animus. Volto in ombra |
| — | `ac2-ezio4` (key art con colonne e colombe) | **Guanto in pelle e ciondolo a croce con catena in mano**; tunica più scura | Mood | **Elementi solo promozionali.** Croce e guanto non vanno inseriti nel costume base senza conferma A |
| — | `ac2-ezio6` / `ac2-ezio7` (key art di combattimento) | **Spallaccio metallico** sulla spalla destra, cappa, ascia | Azione | La wiki conferma che la copertina frontale mostra un **pezzo di armatura "Metal" acquistabile**. **Non fa parte del costume base** |
| EZ-B05 | `ac2-ezio5` («Face Art») | Primo piano: naso, bocca, mento, collo, colletto con pizzo, due lame | Naso (dorso e punta), labbra, barba corta, mascella, pizzo della camicia | **Gli occhi, le sopracciglia, la fronte e l'attaccatura dei capelli non si vedono.** La descrizione attuale («studio proporzioni facciali») è troppo generosa: lo studio è possibile solo per la metà inferiore del volto |
| EZ-B07 | `ac2-hidden-blades` (concept) | Bracciale con insegna in argento, meccanismo, polsino in pizzo, mano a cinque dita | Logica del meccanismo, pizzo dei polsini | Concept preliminare. Il bracciale decorato non è stato confrontato con l'in-game |
| EZ-B08 | `ac2-hidden-gun` (concept) | Pistola celata montata sul bracciale, tre viste | Ingombro e posizione | Concept, non disegno tecnico |
| EZ-B04 | `ac2-character-heads` | 16 teste di NPC generici + 2 wireframe | Livello di realismo della pelle in-game | **Nessuna testa è identificabile come Ezio.** Non usarla per il volto |
| EZ-B04 | `ac2-character-renders1-4` («IN-GAME MODEL, 4–6000 tris») | NPC e cortigiane. Due giovani nobili (farsetto nero; tunica rossa con fascia) | Livello LOD dei civili, moda fiorentina 1476 | **Nessuno è etichettato come Ezio.** Il giovane in farsetto nero ricorda l'abito civile del 1476 ma l'identità è **DA VERIFICARE**: potrebbe essere un NPC. Non usarlo per il volto |
| EZ-B01, B02, B09 | (pagine di testo / galleria esterna) | Non riesaminate in questa sessione | — | Stato invariato: link verificati in precedenza |

### 1.2 Fonti C

Non ho aperto né scaricato le mesh EZ-C01 e EZ-C05: le regole del progetto vietano l'importazione automatica. Le fonti C restano utili **solo per controllare i volumi**. La wiki (EZ-C06) è stata letta via API come testo e ha fornito i dati canonici della sezione 2. **Ogni dato preso dalla wiki resta "VERIFICATA-C" finché non è confermato da una fonte A.**

### 1.3 Valutazione di fedeltà del pacchetto attuale

1. **Costume:** buono. Le fonti B convergono sullo stesso design delle vesti di Giovanni. Vanno esclusi gli elementi promozionali: spallaccio Metal, croce in mano e posa con doppia lama nelle scene del 1476.
2. **Volto: insufficiente.** In **nessuna** immagine B gli occhi di Ezio sono visibili senza cappuccio. Fronte, sopracciglia, occhi, attaccatura, orecchie e capelli dipendono **per intero** dalle fonti A, che non esistono ancora. **Oggi non è possibile definire un volto fedele. Inventarlo vorrebbe dire violare la regola "non modificare arbitrariamente".**
3. **Corpo:** dato ufficiale B (manuale) disponibile: 1,83 m e 75 kg. Mancano le viste ortogonali.
4. **Rischio di contaminazione:** molte immagini "Ezio" sul web vengono da *Brotherhood* e *Revelations* (vesti romane, barba più folta, volto più maturo) o da mod (EZ-C04). Ogni file A va etichettato con la sequenza di provenienza.

---

## 2. Dati canonici di identità

| Campo | Valore | Fonte | Stato |
| --- | --- | --- | --- |
| Nome | Ezio Auditore da Firenze | Gioco | VERIFICATA-C |
| Nascita | 24 giugno 1459, Firenze | Wiki ← memoria *The Birth of an Assassin* | VERIFICATA-C |
| Età nelle sequenze | 17 (1476) · 19 (1478) · ~27 (1486) · 29 (1488) · 38 (1497) · 40 (1499) | Calcolo dalla data di nascita | Derivata |
| Statura / peso | **1,83 m / 75 kg** | Manuale di gioco (B, citato dalla wiki) | VERIFICATA-C → da confermare sul manuale |
| Occhi | **Ambra / nocciola-dorato** in AC II. *Renaissance* (romanzo) dice "grigi": **escluso** | Wiki (trivia) | VERIFICATA-C · GAP-13 |
| Cicatrice | **Labbro**, causata da una pietra lanciata da Vieri de' Pazzi sul Ponte Vecchio, 1476 (memoria *Boys Will Be Boys*). Permanente. *Renaissance* la mette sulla fronte: **escluso** | Wiki | VERIFICATA-C · lato, forma e lunghezza **DA VERIFICARE** (GAP-12) |
| Mano sinistra | **Anulare integro.** Leonardo modifica la lama, quindi niente amputazione. Dal 1488 (iniziazione, Seq. 11) c'è un **marchio sull'anulare sinistro** | Wiki (memorie *Ace Up My Sleeve* e *Play Along*) | VERIFICATA-C |
| Barba | Ventenne con ombra di barba. **Barba corta piena nelle Seq. 12–13** (la wiki nota che la barba sparisce se la Seq. 13 viene giocata prima della 12): quindi è legata a Forlì 1488 e seguenti | Wiki | VERIFICATA-C · stato esatto in Seq. 11 e 14 DA VERIFICARE |
| Rapporto con Desmond | Un glitch con cappuccio abbassato mostra che il **modello di gameplay** condivide la testa con Desmond | Wiki | Nota tecnica. **Non derivare il volto cinematografico di Ezio da quello di Desmond**: vale solo il volto delle cutscene |
| Indole visiva | 1476: giovane nobile giocoso e affabile, sicuro di sé. Più tardi: controllo emotivo, rabbia che riaffiora (Uberto, Vieri, Rodrigo) | Wiki | Guida per le espressioni (GAP-04) |

---

## 3. Volto: specifica (punto 3)

### 3.1 Tratti già osservabili (metà inferiore, fonti B)

Solo osservazione su EZ-B05, `ac2-ezio1`, `ezio3` e `ezio4`. Sono descrizioni, non misure.

- **Naso:** lungo e dritto, dorso definito, punta leggermente pronunciata, narici strette. *VERIFICATA-B*
- **Bocca:** labbra piene e ben disegnate, arco di Cupido marcato, labbro inferiore più pieno. *VERIFICATA-B*
- **Mascella e mento:** mandibola netta e angolata, mento squadrato di larghezza media. *VERIFICATA-B*
- **Pelle:** carnagione mediterranea chiara-olivastra. *VERIFICATA-B* (calibrazione colore DA FARE su A, in luce neutra)
- **Barba (adulto):** corta e uniforme, ombra su guance, labbro e mento. *VERIFICATA-B per l'Ezio promozionale adulto*
- **Collo:** robusto, proporzionato a un atleta snello. *VERIFICATA-B*

### 3.2 Tratti NON ancora definibili: tutti bloccati su GAP

| Tratto | Valore attuale | Sblocco |
| --- | --- | --- |
| Forma e distanza degli occhi, palpebre, colore in luce neutra | **NON DEFINITO** | GAP-01, GAP-13 |
| Sopracciglia (spessore, arco) | **NON DEFINITO** | GAP-01, GAP-02 |
| Fronte e attaccatura | **NON DEFINITO** | GAP-01, GAP-11 |
| Orecchie | **NON DEFINITO** | GAP-02 |
| Zigomi (a volto scoperto) | Indizio B: zigomi alti | GAP-01 |
| Cicatrice: lato, forma, colore e stato per età | **NON DEFINITO** | GAP-12 |

### 3.3 Misure di riferimento (da ricavare su fonti A, non da inventare)

Unità di misura: **distanza interpupillare (IPD) = 1,00**, misurata sulla frontale neutra A.

| Rapporto | Valore | Tolleranza ammessa nel Lock |
| --- | --- | --- |
| Larghezza bocca / IPD | da misurare | ±3 % |
| Lunghezza naso (nasion–subnasale) / IPD | da misurare | ±3 % |
| Larghezza naso / IPD | da misurare | ±4 % |
| Altezza terzo inferiore / terzo medio | da misurare | ±4 % |
| Larghezza bigoniale / bizigomatica | da misurare | ±3 % |
| Distanza cicatrice dal filtro (in IPD) | da misurare | ±5 % |

Le misure vanno prese su almeno 3 fotogrammi A indipendenti; si usa la mediana. L'ottica del gioco (FOV della cutscene) va annotata per correggere la distorsione prospettica.

---

## 4. Capelli

| Campo | Valore | Stato |
| --- | --- | --- |
| Colore | Castano scuro | VERIFICATA-B (render) · tono esatto su A |
| Lunghezza | Media, raccolta dietro | VERIFICATA-C: Hot Toys EZ-C02 ha una «coda rimovibile» |
| Acconciatura | **Coda bassa corta legata con un nastro** | DA VERIFICARE: colore del nastro (spesso descritto rosso) e altezza del nodo → GAP-11 |
| Sotto il cappuccio | Capelli non visibili | Coerente con le promo |
| Variazioni per età | Nessun cambiamento documentato | DA VERIFICARE su Seq. 12–14 |

---

## 5. Corporatura

- **1,83 m · 75 kg** (manuale): figura **atletica e snella**, da free-runner, non da culturista. Spalle larghe rispetto alla vita, avambracci definiti, gambe lunghe.
- **Proposta per il live-action** (da approvare): circa 7,5 teste di altezza; massa muscolare da arrampicatore o ginnasta, grasso corporeo basso ma non estremo.
- **Postura:** 1476 rilassata e spavalda; dopo il 1478 eretta, controllata e pronta. Animazioni da Desmond con l'abito nobile, da Assassino con le vesti (nota della wiki: utile per GAP-09).
- **Mani:** cinque dita integre su entrambe; dal 1488 marchio sull'anulare sinistro.

---

## 6. Costumi per epoca

### 6.1 COS-EZ-01 · Abito da nobile fiorentino (1476, Seq. 1–2 fino a *Jailbird*)

Memorie: *Boys Will Be Boys*, *You Should See the Other Guy*, *Sibling Rivalry*, *Nightcap*, *Paperboy*, *Petruccio's Secret*, *Beat a Cheat*, *Friend of the Family*, *Special Delivery*, *Jailbird* (elenco dalla wiki, VERIFICATA-C).

Composizione: **DA VERIFICARE su A (GAP-06).** Indizio non confermato: camicia bianca con colletto alto, farsetto scuro senza maniche con motivo a volute, cintura con borchie, calze scure, stivali in pelle. **Senza lama celata e senza vesti da Assassino.**

### 6.2 COS-EZ-02 · Vesti di Giovanni Auditore (dalla fine della Seq. 2, 1476 → 1499)

Costume principale. Descrizione dalla wiki, coerente con le promo B:

| # | Elemento | Specifica | Stato |
| --- | --- | --- | --- |
| 1 | **Cappuccio** | Unito alla veste, **punta a becco d'aquila** al centro della fronte; ombreggia gli occhi | VERIFICATA-B/C |
| 2 | **Veste/tunica** | Bianco **sbiadito** (non bianco ottico), collo aperto con risvolti interni **rossi damascati bordati d'oro** | VERIFICATA-B/C |
| 3 | **Camicia** | Lino bianco, maniche ampie, **colletto e polsini in pizzo** (EZ-B05, EZ-B07) | VERIFICATA-B |
| 4 | Profilature | Strisce verticali rosse sul busto e sulle falde | VERIFICATA-B |
| 5 | **Parte inferiore** | Doppio strato; **dietro più lunga che davanti**; falde anteriori con ricamo grigio-argento (volute e motivo ad uccello) lungo l'orlo | VERIFICATA-B/C |
| 6 | **Fascia** | Fascia rossa lunga in vita, con un'estremità pendente sul lato sinistro della figura | VERIFICATA-B |
| 7 | **Cintura e borse** | Cintura in cuoio con borse: fumogeni (dopo l'acquisto), proiettili (dal 1486), veleno (dal 1478), medicine | VERIFICATA-C · contenuto per epoca, vedi 7 |
| 8 | **Fibbia-insegna** | Insegna degli Assassini ornata, metallo argentato con fogliame; pietra rossa al vertice (`ac2-ezio1`) | VERIFICATA-B · pietra DA VERIFICARE su A |
| 9 | Foderi per coltelli da lancio | Ai lati della fibbia | VERIFICATA-C |
| 10 | **Spallaccio** | Cuoio sulla **spalla sinistra** con motivo a volute impresso; regge la cappa | VERIFICATA-B/C |
| 11 | **Cappa** | Drappeggiata **sopra e intorno al braccio e alla spalla sinistra**; fodera rossa scura. Esterno: vedi le varianti in 6.3 | VERIFICATA-B/C |
| 12 | Tracolle | Cinghia in cuoio in diagonale sul petto (spalla destra della figura → fianco sinistro) con fibbie | VERIFICATA-B |
| 13 | **Bracciali** | Bracciale in cuoio con meccanismo, uno per lama | DA VERIFICARE: decorazione in-game (GAP-08) |
| 14 | Guanti | Cuoio marrone su almeno una mano nelle promo | DA VERIFICARE: in-game a dita intere o mezze dita |
| 15 | Calzoni | Scuri (marrone o grigio scuro) | VERIFICATA-B |
| 16 | **Stivali** | Cuoio marrone fino al ginocchio, cinghie e fibbie, risvolto | VERIFICATA-B |
| 17 | Collana | Collana corta di perline scure visibile in `ac2-ezio1` | **DA VERIFICARE** (forse solo promozionale) |

**Esclusi dal costume base:** spallaccio "Metal" (copertina), armature acquistabili (Cuoio, Helmschmied, Metal, Missaglias), tinture alternative, ciondolo a croce (`ezio4`), dettagli delle vesti romane di *Brotherhood*.

### 6.3 Cappe (varianti con significato narrativo)

| Cappa | Quando è disponibile in canon | Uso proposto nel film |
| --- | --- | --- |
| Semplice | Con le vesti (Seq. 2) | **Default** |
| Medici | Dono di Lorenzo dopo la morte di Jacopo de' Pazzi (fine Seq. 5, 1478) | DECISIONE UTENTE: può segnare l'alleanza con i Medici |
| Veneziana | Dopo la Seq. 11 | DECISIONE UTENTE |
| Auditore | 100 piume (attività opzionale) | Sconsigliata come default; ha senso solo con il filo narrativo delle piume per Maria |

### 6.4 Costumi temporanei

| ID | Costume | Quando | Stato |
| --- | --- | --- | --- |
| COS-EZ-03 | **Costume del Carnevale**: cappa nera con motivi dorati simili all'insegna, due maschere (metallo e **Maschera d'oro**) | Solo Seq. 9, 1486 | VERIFICATA-C · GAP-07 |
| COS-EZ-04 | **Armatura da guardia Borgia** | Memorie *Play Along* (Seq. 11) e *All Things Come to He Who Waits* (Seq. 14) | VERIFICATA-C |
| COS-EZ-05 | **Armatura di Altaïr** | Sbloccabile dopo i 6 sigilli (anni '90 del Quattrocento). La wiki riporta che nella Cripta/Vault (1499) Ezio la indossava | VERIFICATA-C · **DECISIONE UTENTE** per la Seq. 14 |
| — | Vesti di Altaïr (bonus Uplay, dito amputato) | Contenuto bonus, non narrativo | **ESCLUSO** |

---

## 7. Accessori e armi: cronologia (punto 3)

| Anno / Seq. | Equipaggiamento che entra | Fonte | Stato |
| --- | --- | --- | --- |
| 1476 · Seq. 2 | Vesti di Giovanni, spada, **lama celata rotta** e pagina del Codice dalla cassa di Giovanni (*Jailbird*) | Wiki | VERIFICATA-C |
| 1476 · Seq. 2 | **Lama celata riparata** da Leonardo (*Ace Up My Sleeve*). Nessuna amputazione | Wiki | VERIFICATA-C · braccio (sinistro?) DA VERIFICARE |
| 1478 · Seq. 4 | **Seconda lama celata** (doppia lama) | Wiki (*Practice What You Preach*) | VERIFICATA-C |
| 1478 · Seq. 5 | **Lama avvelenata** | Wiki (*A Blade With Bite*) | VERIFICATA-C · braccio DA VERIFICARE |
| 1478 · fine Seq. 5 | Cappa Medici disponibile | Wiki | VERIFICATA-C |
| 1478 → | Coltelli da lancio, fumogeni, medicine (acquisti) | Wiki | Uso per epoca DA VERIFICARE |
| 1486 · Seq. 9 | **Pistola celata** (*Knowledge is Power*), usata in *Damsels in Distress* e su Marco Barbarigo | Wiki | VERIFICATA-C |
| 1488 · Seq. 11 | **Marchio sull'anulare sinistro** (iniziazione, *Play Along*) | Wiki | VERIFICATA-C |
| 1488 · Seq. 12 → | Barba piena | Wiki | VERIFICATA-C |
| anni '90 | Armatura e Spada di Altaïr (opzionali) | Wiki | DECISIONE UTENTE |
| 1499 · Seq. 14 | Confronto con Rodrigo; Bastone papale; Cripta e Minerva | Wiki | Costume DECISIONE UTENTE |

**Armi in mano (spada o pugnale):** nel gioco dipendono dagli acquisti del giocatore, quindi non esiste un'arma canonica unica per ogni scena. **DECISIONE UTENTE:** una lista di armi "da film" per epoca, scelta fra quelle realmente presenti in AC II, va approvata prima del Master.

---

## 8. Materiali per la traduzione live-action (PROPOSTA CREATIVA)

> Questa sezione **non è canon**: traduce in materiali reali ciò che il gioco mostra in shader. Va approvata separatamente.

| Elemento | Materiale proposto | Finitura / note PBR |
| --- | --- | --- |
| Veste | Lana leggera o mezzalana tessuta a mano, **ecru** non sbiancato | Ruvidità 0,7–0,8. Sporco ai bordi e polvere ai gomiti. Lieve fuzz (sheen) |
| Risvolti rossi | Damasco di seta cremisi con passamaneria dorata | Sheen anisotropo; oro filato, non metallo pieno |
| Camicia | Lino medio, polsini e collo in pizzo a fuselli | Trasmissione luce sui bordi in pizzo (SSS leggero o opacità) |
| Fascia | Lana o seta cremisi, tinta con robbia o kermes | Saturazione inferiore al rosso in-game |
| Cinghie, spallaccio, bracciali, stivali | Cuoio conciato al vegetale, marrone medio-scuro | Usura sulle pieghe, cuciture a mano, bordi bruniti |
| Spallaccio | Cuoio impresso a volute | Normal map dall'impressione, niente displacement eccessivo |
| Fibbia-insegna | Argento o peltro fuso con fogliame cesellato | Metallico 1,0. Ossidazione nei recessi |
| Lame celate | Acciaio forgiato con incisione a girali (EZ-B07) | Anisotropia di lucidatura lungo la lama |
| Meccanismo | Ottone o bronzo e ferro | — |
| Cappa | Esterno in panno di lana; fodera in lana o seta rosso scuro | Simulazione cloth pesante, non seta leggera |
| Pelle | Mediterranea chiara-olivastra; pori, peluria e barba come strati separati | SSS a 3 strati; texture del volto 8K UDIM per i primi piani in 4K |

**Calibrazione del colore:** i valori sRGB di riferimento (bianco della veste, rosso della fascia, rosso della fodera, cuoio) vanno campionati su fotogrammi A in luce diurna neutra e convertiti in ACEScg. I valori non si prendono dalle promo, che hanno grading pesante.

---

## 9. Immagini mancanti (punto 4)

I GAP-01…GAP-10 del documento padre restano tutti **DA ACQUISIRE**. Propongo di aggiungere:

| ID | Materiale necessario | Perché |
| --- | --- | --- |
| **GAP-11** | Nuca e capelli da dietro, cappuccio abbassato: coda, nastro, attaccatura | Nessuna fonte B mostra i capelli in dettaglio |
| **GAP-12** | Primo piano della cicatrice al labbro: ferita fresca (dicembre 1476, medico) e cicatrice guarita (1478, 1488, 1499) | Lato, forma e colore sconosciuti; continuità critica |
| **GAP-13** | Occhi in luce neutra (cutscene diurna, primo piano) | Colore ambra da confermare; occhi mai visibili nelle B |
| **GAP-14** | Mano sinistra dopo il 1488 (marchio sull'anulare) | Dettaglio di continuità |
| **GAP-15** | Campioni di colore della veste, della fascia e del cuoio in 3 condizioni di luce (Firenze di giorno, Venezia di giorno, interno) | Calibrazione dei materiali |
| **GAP-16** | Costume e stato della barba in Seq. 11 e 14; Armatura di Altaïr se scelta | Variante 1488–1499 |
| **GAP-17** | Fotogrammi di *Assassin's Creed: Lineage* (cortometraggio live-action Ubisoft del 2009) con le **vesti di Giovanni** | **Unica traduzione live-action ufficiale** delle stesse vesti → fonte B preziosa per i materiali reali |
| **GAP-18** | Scelta della **versione di gioco** per le fonti A: originale (2009/2010) o *Ezio Collection* (2016, texture e illuminazione modificate) | Le due versioni mostrano volti e materiali diversi: va fissata una sola versione primaria |

**Nota:** il «Volto scoperto» (GAP-01) è il blocco più importante. Secondo la wiki, durante il viaggio in Italia Ezio si toglie il cappuccio nelle cutscene **solo se indossa le vesti di Giovanni**. Le cutscene a cappuccio abbassato vanno quindi giocate con le vesti di default.

---

## 10. Sistema Character Lock (punto 6)

Obiettivo: **un solo volto**, generato una volta, approvato e poi riutilizzato in ogni scena. Mai rigenerato.

### 10.1 Strati di identità

```
L0  CANON SET        Fonti A (locali, mai su GitHub) + ID registrati qui
 │                   ↓ misura
L1  IDENTITY SHEET   Questo documento + tabella rapporti (§3.3) + campioni colore
 │                   ↓ scultura/approvazione
L2  EZIO_MASTER      Testa e corpo digitali neutri, età di riferimento 1478 (19 anni)
 │                   ↓ solo deformazioni controllate
L3  VARIANTI ETÀ     _1476 (17, pre-cicatrice → cicatrice fresca)
 │                   _1486 (27) · _1488 (29, barba) · _1499 (40, barba)
 │                   ↓
L4  SHOT ASSET       Render o inferenze per scena, condizionati SEMPRE da L2/L3
```

Regola d'oro: **L3 e L4 non creano mai geometria facciale nuova.** Le varianti d'età cambiano solo pelle, peli, cicatrice e un piccolo set di deformazioni approvate (morbidezza dei tessuti, piccole rughe). Struttura ossea, naso, bocca e occhi restano identici.

### 10.2 Contenuto di EZIO_MASTER (quando sarà autorizzato)

- Mesh della testa neutra con topologia per animazione facciale, più un set di blendshape (FACS) per le espressioni del GAP-04.
- Texture UDIM: albedo, roughness, normal, displacement, cavity, mappe SSS. Il volto a 8K serve ai primi piani in 3840×2160.
- Groom separati: capelli con coda, sopracciglia, ciglia, barba per età.
- Cicatrice come **maschera separata versionata**: posizione bloccata nello spazio UV.
- Occhi: iride ambra calibrata, mesh separata (cornea, sclera, iride).
- **Turnaround di approvazione:** 8 viste (0°, 45°, 90°, 135°, 180°, 225°, 270°, 315°) in luce neutra, più 5 espressioni. Questo è il "documento d'identità" visivo.

### 10.3 Versioni e congelamento

- Nome: `EZIO_MASTER_vMMM` (per esempio `v001`). Ogni versione ha un **hash** dei file sorgente registrato in questo repository (solo l'hash, non l'asset).
- Stati: `WIP → REVIEW → APPROVED → FROZEN`. Una versione `FROZEN` non si modifica: ogni correzione crea `vMMM+1` con un changelog e una nuova approvazione.
- Ogni scheda-scena (`docs/04_SCENE_TEMPLATE.md`) dovrà riportare `character_master: EZIO_MASTER_v00X_<variante>`.

### 10.4 Uso negli strumenti di produzione (quando autorizzato)

Due strade possibili, entrambe ancorate al Master:

1. **Pipeline 3D (consigliata per i primi piani):** render del Digital Double in Blender. Il volto è identico per costruzione.
2. **Pipeline generativa (per quadri ampi o di supporto):** condizionamento obbligatorio su immagini o modelli derivati **solo da render di EZIO_MASTER** (per esempio un adattatore di identità addestrato solo sui render del turnaround), più controllo della geometria (depth/normal/pose dal rig). **Vietato** generare il volto da solo testo, da foto di persone reali o da immagini di *Brotherhood*/*Revelations* o di mod.

### 10.5 Controllo automatico per ogni shot (QC Gate)

| Controllo | Metodo | Soglia (da tarare sul turnaround) |
| --- | --- | --- |
| Somiglianza d'identità | Embedding facciale dello shot rispetto alla galleria del Master | ≥ soglia ricavata dalla variazione interna al turnaround (per esempio il 5° percentile) |
| Proporzioni | Landmark → rapporti della §3.3 | Entro le tolleranze della §3.3 |
| Cicatrice | Presenza, lato e posizione rispetto al filtro | Obbligatoria dopo il 26/12/1476 |
| Occhi | Tonalità dell'iride campionata | ΔE ≤ 6 rispetto al riferimento, in luce neutra |
| Barba / età | Conforme alla variante L3 dichiarata | Binario |
| Costume ed equipaggiamento | Checklist della §7 per anno e sequenza | Binario |
| Revisione umana | Confronto affiancato Master / shot | Obbligatoria |

Uno shot che fallisce anche un solo controllo **non entra nel montaggio** e non va "corretto" a mano libera: si rigenera dal Master.

**Nota sulle licenze:** molti modelli di riconoscimento facciale (per esempio i pesi InsightFace) hanno licenze solo non commerciali. Va bene per un uso privato, ma vanno verificati prima dell'adozione. Nessun servizio a pagamento senza autorizzazione.

### 10.6 Divieti del Lock

- Nessun volto di persone reali come base, nemmeno "ispirazione". Nessun attore come riferimento di somiglianza.
- Non derivare Ezio dal volto di Desmond, anche se il modello di gameplay è condiviso.
- Nessuna miscela di fonti: un tratto viene da A, oppure resta "NON DEFINITO".
- Nessuna "miglioria" estetica (simmetrizzare, ringiovanire, abbellire) rispetto al canon.

---

## 11. Correzioni proposte al documento padre (da approvare)

1. **EZ-B05:** cambiare la nota d'uso da «Studio proporzioni facciali» a «Solo metà inferiore del volto (naso, bocca, mento). Occhi e fronte non visibili».
2. **EZ-B04:** aggiungere che «Character Heads» e «Character Renders 1–4» sono **NPC**: nessuno è etichettato come Ezio.
3. **EZ-B06 e galleria promo:** annotare che la copertina frontale (spallaccio Metal) e `ezio4` (croce, guanto) contengono **elementi non di default**.
4. Aggiungere le righe **GAP-11 … GAP-18**.
5. Aggiungere **EZ-B10**: *Assassin's Creed: Lineage* (live-action Ubisoft 2009), da reperire come fonte B per le vesti di Giovanni.
6. Aggiungere un campo obbligatorio **"versione di gioco"** a ogni futura fonte A.

---

## 12. Decisioni che ti chiedo (prima del Master)

| # | Domanda | Opzioni |
| --- | --- | --- |
| D1 | Versione di gioco per le fonti A | Originale 2009/2010 (consigliata come canon) · *Ezio Collection* 2016 |
| D2 | Costume nella Seq. 14 (Vaticano, Cripta) | Armatura di Altaïr (secondo la wiki) · vesti di Giovanni |
| D3 | Uso narrativo delle cappe | Solo cappa semplice · Medici dal 1478 · Veneziana dal 1488 |
| D4 | Arma principale per epoca | Lista da approvare fra le armi di AC II |
| D5 | Età di riferimento del Master | 19 anni (1478, consigliata: volto con cicatrice, senza barba, al centro dell'arco) · altra |
| D6 | Approvazione della traduzione dei materiali (§8) | Approvo · modifico |
| D7 | Collana di perline (`ezio1`) | Includere se confermata su A · escludere |

---

## Checklist pre-master (aggiornata)

- [x] Reference B esaminate e classificate (sezione 1)
- [x] Dati canonici raccolti (fonte C, da confermare su A)
- [x] Costume base e accessori definiti per epoca (con DA VERIFICARE espliciti)
- [x] Character Lock progettato (sezione 10)
- [ ] **Fonti A acquisite** (GAP-01…18) ← blocco principale
- [ ] Rapporti facciali misurati (§3.3)
- [ ] Decisioni D1–D7
- [ ] Approvazione utente della scheda → solo allora EZIO_MASTER_v001