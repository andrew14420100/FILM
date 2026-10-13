# CHR-001 · EZIO_MASTER — Dossier di progettazione

**Stato:** PROPOSTA DI PRE-PRODUZIONE · D4/D5/D6/D7 **NON APPROVATE** · **Data:** 2026-10-13
**Base:** repository FILM al commit `5d54382` (`CLAUDE.md`, `CHR-001_PREPRODUZIONE_DA_BROWSER.md`, `05_DECISIONI.md`, `CHR-001_EZIO_MASTER.md` con gli addendum, scheda tecnica, scheda visiva, revisioni, `CHR-001_VERIFICHE_R1_R4.md`).
**Già approvate e qui solo applicate:** D1 (AC II originale per PC su Ubisoft Connect), D2, D2-bis, D3, D8, D9, reference esistenti sufficienti per la pre-produzione.

> Solo testo. Nessun modello, immagine, render o video. Nessuna nuova cattura richiesta. Le immagini A-EXT/B/C restano link e studio privato.

### Legenda

| Etichetta | Significato |
| --- | --- |
| **V-B** | Verificato su fonte ufficiale Ubisoft (manuale PC, portfolio/crediti) |
| **V-C** | Riportato dalla wiki comunitaria (testo delle memorie): attendibile ma non primario |
| **A-EXT** | Osservato in screenshot di gioco di terzi (versione/piattaforma non accertata) |
| **APPROVATA** | Decisione già presa da te |
| **PROPOSTA** | Scelta artistica mia, da approvare |
| **DA VERIFICARE** | Incerto: nessuna resa definitiva prima di una decisione |

---

## 1. Nucleo d'identità (non cambia in nessuna età)

| Tratto | Valore | Fonte |
| --- | --- | --- |
| Nascita | 24 giugno 1459, Firenze | V-C |
| Statura / peso | 6 ft (≈1,83 m) / 165 lb (≈75 kg); «Age 17, Year 1476» | **V-B** (manuale PC su Steam, p. 3) |
| Struttura del volto | Naso lungo e dritto con dorso alto; zigomi alti; mascella angolata; mento squadrato; labbra piene; sopracciglia scure, folte, quasi dritte; occhi a mandorla infossati | A-EXT (F01–F07), B11/B12 |
| Capelli | Castano scuro, media lunghezza, ciuffi sulla fronte, **coda bassa con nastro rosso** | A-EXT (F07, F10), B11 |
| Iride | Castana nei fotogrammi; «ambra» per la wiki | **DA VERIFICARE** (resa futura: castano caldo/ambra scuro, da decidere sul primo test) |
| Pelle | Mediterranea olivastra media | A-EXT · tono preciso DA VERIFICARE |
| Corporatura | Atletica e snella, da free-runner | V-B (misure) + A-EXT |
| Regola di Character Lock | **Un'unica struttura ossea e facciale dal 1476 al 1499.** Cambiano solo pelle, peli, cicatrice e piccoli morph approvati | APPROVATA (D8, revisione punto 8) |
| Esclusi come fonte del volto | Desmond, attori reali, *Brotherhood*, *Revelations*, mod | APPROVATA (piano da browser) |

---

## 2. D5 — Età e varianti del volto

### 2.1 Età per sequenza (calcolate dalla nascita, date delle memorie V-C)

| Seq. | Periodo (memoria datata) | Età | Barba | Cicatrice labbro | Cappuccio | Variante proposta |
| --- | --- | --- | --- | --- | --- | --- |
| Intro | 24/6/1459 | neonato | — | — | — | Fuori dal Master (asset neonato separato) |
| 1 | 26–28/12/1476 | **17** | Ombra leggera | Assente → **ferita fresca dal 26/12** (rissa, pietra di Vieri) | Abbassato (abito civile) | `EZ_17_A` (senza ferita) · `EZ_17_B` (ferita fresca) |
| 2 | 28–31/12/1476 | 17 | Ombra | Ferita in guarigione | Abbassato/alzato | `EZ_17_C` (crosta) |
| 3 | genn. 1477 – apr. 1478 | 17–18 | Ombra | Cicatrice recente | Variabile | `EZ_18` |
| 4–5 | apr. 1478 (25–26/4) | **18** | Ombra | Cicatrice guarita | Variabile | **`EZ_18` = mesh neutra di riferimento** |
| 6–7 | 1480–1481 (Benvenuto: 1481) | 21–22 | Ombra | Guarita | Variabile | `EZ_22` (solo pelle) |
| 8 | 1481–1485 (DA VERIFICARE) | 22–26 | Ombra | Guarita | Variabile | `EZ_22`/`EZ_26` |
| 9–10 | 15/2/1486 – 11/7/1486 | 26–27 | Ombra | Guarita | Variabile | `EZ_26` |
| 11 | 1486 – 24–25/6/1488 | 27–29 | DA VERIFICARE se già presente | Guarita | Variabile | `EZ_28` |
| 12 (Forlì) | 7–9/7/1488 | **29** | **Barba corta piena** (V-C + A-EXT F11) | Guarita (sotto la barba?) | Abbassato in F11 | `EZ_29_BARBA` |
| 13 (Falò) | 1497 – 23/5/1498 | **37–38** | Barba piena | Guarita | **Alzato (D8)** | `EZ_38_BARBA` (solo metà inferiore visibile) |
| 14 (Vaticano) | 28/12/1499 | **40** | Barba piena | Guarita | **Alzato (D8)** | `EZ_40_BARBA` |

**Correzioni ai documenti precedenti:** «19 anni (1478)» va letto **18 anni** (aprile 1478, prima del compleanno di giugno). «38 anni (1497)» va letto **37–38**. Il «Ezio a 19 anni» della revisione D5 va aggiornato.

### 2.2 Regole delle varianti (PROPOSTA)

1. **Mesh neutra unica `EZIO_MASTER_v001` = Ezio a 18 anni** (Seq. 4, 1478): senza barba, cicatrice guarita. È il punto con più riferimenti A-EXT coerenti (F01–F07, B11–B12) e sta a metà tra 17 e 29 anni.
2. **17 anni:** stessa mesh, pelle più liscia, cicatrice spenta o in forma di ferita fresca/crosta. Nessun cambiamento osseo.
3. **22–28 anni:** stessa mesh. Pelle leggermente più matura e barba d'ombra più marcata.
4. **29 anni:** groom barba corta piena (baffi uniti al pizzetto, guance coperte in modo corto, come F11) + morph minimo «maturità» (lieve perdita di volume sotto gli zigomi).
5. **37–40 anni:** come la variante 29 + rughe d'espressione leggere (fronte, zampe di gallina, naso-labiali), pelle meno uniforme, barba più piena. Con il cappuccio alzato (D8) la priorità è **naso, bocca, barba e mascella**.
6. **Vietato:** cambiare naso, occhi, distanza interpupillare, forma della mascella o del cranio fra le varianti.
7. La **cicatrice** è una maschera unica con 4 stati: assente, ferita fresca, crosta, guarita. Per la posizione si parte dal **lato destro del labbro superiore di Ezio** (A-EXT F08/F09). Forma e lunghezza della cicatrice guarita sono **DA VERIFICARE**: resa provvisoria sottile e discreta, da approvare sul primo test.

### 2.3 Incertezze D5 (restano aperte senza bloccare)

- Presenza della barba già nella Seq. 11 (giugno 1488): **DA VERIFICARE**. Proposta: barba d'ombra marcata nella Seq. 11, barba piena dalla Seq. 12.
- Visibilità della cicatrice sotto la barba: **DA VERIFICARE**. Proposta: visibile come interruzione della barba sul labbro superiore.

---

## 3. D4 — Armi e continuità dell'equipaggiamento

### 3.1 Fatti narrativi (non scelte)

| Data / Seq. | Fatto | Fonte |
| --- | --- | --- |
| 26/12/1476 · 1 | Rissa con Vieri **a mani nude** | V-C («Boys Will Be Boys»: arma iniziale «Fists») |
| 28/12/1476 · 1–2 | Nella cassa di Giovanni: **spada comune**, bracciale con **lama celata rotta**, pagina del Codice, **vesti bianche**. Ezio indossa le vesti e rinfodera la spada | V-C («Family Heirloom») |
| 29/12/1476 · 2 | Esecuzione: Ezio **viene disarmato** da un bruto. Il filmato mostra una sciabola siriana invece della spada comune: **errore del gioco**, da non riprodurre | V-C («Last Man Standing») |
| 30/12/1476 · 2 | Leonardo **ripara la lama celata** | V-C («Ace Up My Sleeve») |
| 1477–1478 · 3 | Addestramento con Mario; Ezio ha la spada e la «lama di tuo padre» | V-C («Practice Makes Perfect») |
| apr. 1478 · 4 | **Seconda lama celata** e bracciale | V-C («Practice What You Preach») |
| 1478 · 5 | **Lama avvelenata** («A Blade With Bite»); il cesto metallico è acquistabile da qui | V-C |
| feb. 1486 · 9 | **Pistola celata** + maschera. Leonardo: «non puoi portare armi oggi» → **niente armi visibili al Carnevale** | V-C («Knowledge is Power») |
| giu. 1488 · 11 | Travestimento da **guardia Borgia** | V-C |
| lug. 1488 · 12 | Ezio uccide Checco con la lama celata e **viene ferito** da Checco | V-C («Checcomate») |
| 28/12/1499 · 14 | Rodrigo pugnala Ezio al ventre: **l'Armatura di Altaïr lo salva**. Ezio **getta a terra Spada di Altaïr, Cinquedea dentellata e Lama celata** prima del duello a pugni. Minerva gli fa lasciare il Bastone | V-C («In Bocca al Lupo») |
| — | Una Cinquedea dentellata è **conficcata nel tavolo** della stanza di Ezio a Villa Auditore | V-C (curiosità su AC II) |
| — | La Spada di Altaïr è venduta **solo dal fabbro di Monteriggioni** | V-C |

### 3.2 Matrice per sequenza (PROPOSTA dove indicato)

| Seq. | Spada | Lama corta | Lame celate | Pistola | Altro in scena | Nota di continuità |
| --- | --- | --- | --- | --- | --- | --- |
| 1 (civile) | — | — | — | — | Pugni | Fatto |
| 2 | **Spada comune di Giovanni** | — | 1 (rotta → riparata 30/12) | — | Pagina del Codice | Persa al disarmo del 29/12; **PROPOSTA:** recuperata o sostituita fuori scena con lo stesso modello |
| 3 | Spada comune | — | 1 | — | Coltelli da lancio (**PROPOSTA**) | Duello con Mario |
| 4 | Spada comune | — | **2** | — | — | Fatto: seconda lama |
| 5 | Spada comune | **Cinquedea dentellata** (**PROPOSTA:** introdotta qui) | 2 + **avvelenata** | — | Fiale, fumogeni (**PROPOSTA**) | Fatto: lama avvelenata |
| 6–8 | Spada comune *(o arma intermedia, D4-b)* | Cinquedea | 2 + avvelenata | — | — | Viaggio a Venezia |
| 9 (Carnevale) | **Nessuna visibile** | **Nessuna visibile** | 2 + avvelenata (nascoste) | **Sì** (dal 1486) | Maschera | Fatto (battuta di Leonardo) |
| 10 | Come Seq. 6–8 | Cinquedea | 2 + avvelenata | Sì | — | — |
| 11 | Arma da guardia Borgia nel travestimento | — | Lame nascoste | Sì | Mela dell'Eden | Fatto: travestimento |
| 12 (Forlì) | Come Seq. 10 | Cinquedea | 2 | Sì | Mela persa | Fatto: ferita da Checco |
| 13 (Falò) | **Spada di Altaïr** | Cinquedea dentellata | 2 + avvelenata | Sì | Armatura (D2-bis) | **PROPOSTA** coerente con la Seq. 14 |
| 14 (Vaticano) | **Spada di Altaïr** | **Cinquedea dentellata** | Lama celata | Sì | Bastone papale (preso a Rodrigo, poi lasciato) | **Fatto V-C:** le tre armi vengono gettate prima dei pugni |

### 3.3 Regole di continuità D4

- Ogni scheda-scena riporta il **loadout** della sequenza dalla tabella 3.2.
- **Braccio delle lame** (PROPOSTA provvisoria, DA VERIFICARE): lama originale di Giovanni sul **sinistro**, seconda lama sul destro, lama avvelenata e pistola sul destro. Da confermare se in futuro farai catture.
- Gli acquisti opzionali del gioco (mazze, armi pesanti, armature acquistabili, tinture) **non entrano nel film**, salvo tua decisione.
- Seq. 14: dopo che Ezio getta le armi, nessuna arma in mano fino all'uscita dalla Cripta.

---

## 4. D7 — Collana e accessori per epoca

| Accessorio | Epoche | Stato | Dettagli |
| --- | --- | --- | --- |
| **Collana** (cordino scuro con circa 4–5 perline chiare/argentee) | **1476 → 1499**, tutte le epoche, anche sotto l'Armatura | A-EXT (F01, F04, F07, F11, AR-F01, B11) | Numero e materiale delle perline **DA VERIFICARE**. Resa proposta: argento opaco su cuoio intrecciato |
| **Nastro rosso** sulla coda | Tutte le epoche | A-EXT | Tessuto rosso scuro, annodato basso |
| Marchio sull'anulare sinistro | Dal 24–25/6/1488 | V-C | Visibilità e forma **DA VERIFICARE**; proposta: piccolo segno discreto |
| Pagine del Codice | 1476 → | V-C | Oggetto di scena |
| Maschera di Carnevale | Solo Seq. 9 | V-C | Metallo e maschera d'oro |
| Mela dell'Eden | Seq. 11–12, 14 | V-C | Oggetto di scena separato |
| Piume (per Petruccio/Maria) | Facoltativo | V-C | **PROPOSTA:** usarle solo se il copione lo richiede |
| **Fibbia-insegna** | Argento con le vesti di Giovanni; **dorata con l'Armatura** | A-EXT/C | — |
| **Cappe prima dell'Armatura** | Semplice (dal 1476); Medici (dono di Lorenzo, fine Seq. 5); Veneziana (dopo la Seq. 11) | V-C (sblocchi) | Uso nel film **da decidere**: D7-b |
| Cappa con l'Armatura | Seq. 13–14: esterno scuro, fodera rossa | **APPROVATA (D3)** | AR-F06 (rossa) resta documentata come difformità |

---

## 5. Armatura di Altaïr e costumi — Seq. 13–14 e continuità generale

### 5.1 Linea dei costumi (fatti e scelte approvate)

| ID | Costume | Sequenze | Stato |
| --- | --- | --- | --- |
| COS-EZ-01 | Abito nobile fiorentino | Seq. 1 fino a «Family Heirloom» (28/12/1476) | V-C |
| COS-EZ-02 | Vesti di Giovanni | dal 28/12/1476 a prima della Seq. 13 | V-C |
| COS-EZ-03 | Costume di Carnevale (cappa nera e oro, maschere) | Solo Seq. 9 | V-C |
| COS-EZ-04 | Armatura da guardia Borgia | Seq. 11 (giugno 1488) | V-C (corregge la scheda tecnica, che diceva Seq. 14) |
| COS-EZ-05 | **Armatura di Altaïr** | **Seq. 13 e 14** | **APPROVATA (D2, D2-bis)** |

**Prerequisito narrativo (APPROVATO):** i sei sigilli e l'apertura del Santuario prima della Seq. 13. Collocazione delle tombe nel copione **DA VERIFICARE** (`01_CRONOLOGIA.md`).

### 5.2 Componenti dell'Armatura (forma da A-EXT/B, dettagli da C)

| Componente | Descrizione | Fonte |
| --- | --- | --- |
| Cappuccio | Nero/marrone scuro, punta a becco; fodera posteriore a forma d'insegna | A-EXT + V-C · fodera DA VERIFICARE |
| Colletto | Risvolti bianchi della camicia | A-EXT |
| Pettorale | Piastre scure orizzontali sovrapposte, bordi e rivetti dorati, chiusura centrale a lacci | A-EXT + C01 |
| Maniche | Scure con bande verticali chiare | A-EXT · materiale DA DEFINIRE |
| Spallaccio sinistro | Cuoio scuro, cinghie a treccia, fibbie chiare; regge la cappa | A-EXT + C02 |
| Cappa | Esterno scuro, fodera rossa | **APPROVATA D3** |
| Fascia / insegna | Fascia rossa; insegna dorata con fogliame e pietra rossa | A-EXT + C01 |
| Cintura | Cuoio con borse, anche sul retro | A-EXT |
| Falde | Tre strati: nero con bordo dorato → pannelli rossi damascati → strato chiaro segmentato «ad ali» | A-EXT + V-C |
| Bracciali | Metallo dorato inciso (motivo d'uccello), guanti di cuoio marrone | A-EXT + C03 |
| Stivali | Cuoio scuro sopra il ginocchio, risvolto, 5 fibbie laterali, rilievo floreale | C04 + A-EXT |
| Retro | Cappa, cintura con borse, falde lunghe | A-EXT (AR-F01, F04, F05) + B01 |
| Fianco destro, cappuccio dall'alto, interno della cappa | **Non documentati** | Da interpretare dal retro e dalla scultura B01, segnando la parte come PROPOSTA |

### 5.3 Regole di continuità Seq. 13–14

1. Cappuccio sempre alzato (D8). Volto visibile solo nella metà inferiore, con la barba della variante `EZ_38`/`EZ_40`.
2. Collana visibile al colletto (A-EXT AR-F01).
3. Seq. 14: dopo la pugnalata di Rodrigo, **PROPOSTA:** un segno o un'ammaccatura sul pettorale e sangue sulle vesti sotto. La wiki indica solo che l'armatura «attutisce» il colpo.
4. Seq. 14: le armi restano a terra dopo l'abbandono; il Bastone resta nella Cripta; Ezio esce con la Mela (V-C: «puoi tenere il resto»).
5. L'armatura **non si tinge** (V-C): nessuna variante di colore.

---

## 6. D6 — Materiali fotorealistici e specifiche future

### 6.1 Principi

- I colori del gioco sono **bersagli relativi** (scuro/chiaro/saturo), **non** codici sRGB canonici. Nessun valore numerico di colore viene fissato ora.
- Il realismo dei materiali si appoggia a **oggetti storici reali** (Met Open Access, Rijksmuseum, licenze da verificare caso per caso), consultati e non caricati nel repository.
- Le risoluzioni si decidono con un **benchmark futuro** sulla RTX 5070 Ti 16 GB, solo quando autorizzato.

### 6.2 Tabella materiali (PROPOSTA)

| Elemento | Materiale reale proposto | Note di resa |
| --- | --- | --- |
| Veste di Giovanni | Lana leggera/mezzalana ecru, non sbiancata | Opaca, con lieve peluria; sporco su orli e gomiti |
| Risvolti e pannelli rossi | Damasco di seta cremisi con passamaneria dorata | Lucentezza direzionale; oro filato, non metallo pieno |
| Camicia | Lino, pizzo ai polsi e al collo | Pizzo leggermente traslucido |
| Fascia | Lana/seta rossa | Rosso meno saturo dello schermo di gioco |
| Cuoio (cinghie, spallaccio, stivali, guanti) | Cuoio conciato al vegetale; nero/marrone scuro per l'Armatura | Usura su pieghe e bordi, cuciture a mano |
| Piastre dell'Armatura | **Acciaio annerito con finiture dorate** (doratura a fuoco o ottone sui bordi e sui rivetti) | DECISIONE D6-c: «oro» come doratura sui bordi oppure ottone pieno |
| Bracciali dell'Armatura | Ottone/bronzo dorato inciso | Ossidazione nei solchi |
| Fibbie e insegna | Argento (vesti) / ottone dorato (Armatura) | Patina nei recessi |
| Lame | Acciaio lucidato con incisioni | Lucidatura lungo la lama |
| Collana | Cordino di cuoio intrecciato + perline d'argento opaco | Da confermare |
| Pelle | Strati separati: pori, peluria, barba; traslucenza sottocutanea | Più strati di traslucenza |
| Capelli e barba | Groom a ciocche | Castano scuro con riflessi caldi |

### 6.3 Specifiche tecniche future (solo pianificazione)

| Voce | Proposta |
| --- | --- |
| Scala | 1 unità = 1 m; Ezio adulto 1,83 m senza stivali (V-B); ±1 cm nella variante 17 anni (DA VERIFICARE se differenziare) |
| Struttura dell'asset | `EZIO_MASTER_vNNN` = testa + corpo + groom + 5 kit costume (COS-EZ-01…05) + accessori separati (collana, nastro, cappe, armi) |
| Varianti d'età | Livelli di pelle, groom e piccoli morph sulla stessa mesh (§2.2) |
| Texture del volto | Livello A: 8K albedo + displacement, 4K per il resto. Livello B: tile UDIM 4K. **Scelta dopo il benchmark** |
| Budget orientativo | 4K RGBA 8-bit ≈ 64 MB; 8K ≈ 256 MB a mappa, se caricate non compresse (assunzione da verificare per il motore scelto) |
| Costume e armatura | 4K sui pezzi da primo piano, 2K sul resto (da verificare) |
| Controlli qualità | Turnaround a 8 viste + espressioni; confronto con A-EXT; soglie numeriche **solo dopo calibrazione** (revisione punto 9) |
| Output | Master del film 3840×2160 (APPROVATO); il 4K non garantisce da solo la fedeltà |

---

## 7. Ancora DA VERIFICARE (non bloccano il dossier)

Colore dell'iride · forma della cicatrice guarita · profilo destro · barba nella Seq. 11 · braccio di ogni lama · numero e materiale delle perline · forma del marchio sull'anulare · fianco destro, cappuccio dall'alto e interno della cappa dell'Armatura · date della Seq. 8 · collocazione delle sei tombe nel copione · motore di rendering e compressione delle texture.

---

## 8. Decisioni che richiedono la tua approvazione

| ID | Domanda | Proposta consigliata |
| --- | --- | --- |
| **D4-a** | Loadout delle Seq. 13–14 | **Spada di Altaïr + Cinquedea dentellata + lame celate + pistola** (allineato alla scena V-C del Vaticano) |
| **D4-b** | Spada tra il 1476 e il 1496 | **Spada comune di Giovanni per tutto il periodo** (filo familiare, nessun cambio arbitrario); alternativa: un solo cambio arma a Venezia |
| **D4-c** | Matrice 3.2 e regole 3.3 (Carnevale senza armi, braccio provvisorio delle lame, nessun acquisto opzionale) | Approvare come base di continuità |
| **D5** | Mesh neutra e varianti | **`EZIO_MASTER` = 18 anni (Seq. 4, 1478)**; varianti 17 / 22–28 / 29 con barba / 37–40 con barba (§2.2); cicatrice a 4 stati |
| **D6-a** | Tabella materiali 6.2 | Approvare come bozza di lookdev |
| **D6-b** | Risoluzioni texture | **Rinviare** al benchmark futuro (livelli A/B) |
| **D6-c** | «Oro» dell'Armatura | Acciaio annerito con **bordi e rivetti dorati**, bracciali in ottone inciso |
| **D7** | Collana | **Presente in tutte le epoche**, anche con l'Armatura; resa: argento opaco su cuoio |
| **D7-b** | Cappe prima dell'Armatura (1478–1496) | **Semplice fino al dono di Lorenzo (fine Seq. 5), poi Medici fino alla Seq. 12** (un solo cambio, motivato dalla trama); Veneziana non usata |

Tutto il resto del dossier è fatto documentato o applicazione di decisioni già approvate.
