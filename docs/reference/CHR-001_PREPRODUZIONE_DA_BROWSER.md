# CHR-001 — Pre-produzione REMOTA usando soltanto le reference esistenti

**Data:** 2026-10-13  
**Stato:** PIANO OPERATIVO DI DOCUMENTAZIONE · Nessuna produzione audiovisiva autorizzata.  
**Contesto utente:** lavora dal sito di Claude, **non si trova a casa**, non desidera fare screenshot: il materiale già raccolto è ritenuto **sufficiente per proseguire la progettazione**.

## Principio operativo
1. Utilizzare immediatamente come base i documenti [scheda visiva](CHR-001_EZIO_SCHEDA_VISIVA.md), [scheda tecnica](CHR-001_EZIO_SCHEDA_TECNICA.md), [Master reference pack](CHR-001_EZIO_MASTER.md), [revisione visiva](CHR-001_REVISIONE_VISIVA.md) e [registro decisioni](../05_DECISIONI.md).
2. **Non chiedere di tornare al PC o di aprire il gioco**, né fare delle catture aggiuntive una condizione per schede, costumi, inventario armi, continuity, copione, script breakdown, piano scene o decisioni creative.
3. D1 è **approvata**: AC II originale su PC Windows tramite Ubisoft Connect; build/patch non verificati e irrilevanti per la progettazione remota corrente.
4. A-EXT = screenshot da terzi *attribuiti* ad AC II con versione/piattaforma non accertata; B = materiali creativi/pubblicitari/portfolio ufficiali. Possono ispirare il progetto, ma **non promuoverli falsamente a catture A**.
5. Le lacune di colore dell'iride, cicatrice guarita, profilo destro, dettagli della cappa e delle armi non impediscono di creare la **scheda progettuale**; segnalarle come «DA VERIFICARE» e scegliere in futuro una resa artistica informata dalle fonti più coerenti, quando l'utente la approverà.
6. Per eventuali **future** versioni preliminari 3D, D9 autorizza l'uso A-EXT come riferimento senza imporre acquisizioni personali. **Nessuna modellazione o generazione può però partire senza nuovo ordine esplicito**.
7. Le tavole JPG restano in uno spazio privato di studio, non vanno caricate su GitHub; il repo risulta pubblico.

## Priorità remote — senza creare immagini, asset o filmati

| Ordine | Attività | Output solo testuale | Vincoli |
| --- | --- | --- | --- |
| 1 | **Continuity Bible di Ezio** | Caratteristiche stabili del volto, silhouette, costume e armatura, con etichette A-EXT/B/C | Non cambiare il volto fra le età; segnare colore iride DA VERIFICARE |
| 2 | **D4: inventario armi** | Matrice Seq. 1–14 con introduzione verificata degli strumenti narrativi, armi opzionali e configurazione consigliata | Distinguere «mostrato nel gioco» da «scelta del film» |
| 3 | **D5: età e morph** | Proposta mesh base 19 anni e tabella varianti 17/19/29/38–40 anni, barba/cicatrice/invecchiamento | Il master 3D non esiste e non va creato |
| 4 | **D6: lookdev PBR** | Tabella materiali, palette relativa, strategie per texture/VRAM future | Non inventare codici colore sRGB «canonici»; benchmark futuro |
| 5 | **D7: collana** | Accessorio di continuità, anni e fonti, dettagli incerti | È visibile nelle A-EXT, ma numero e materiale delle perline da confermare |
| 6 | **Armatura di Altaïr** | Tabella componenti, cappuccio alzato Seq. 13–14, cappa scura con fodera rossa, sei sigilli prima Seq. 13 | D2, D2-bis, D3, D8 già approvate |
| 7 | **Preparare per approvazione** | Una singola pagina con D4/D5/D6/D7, opzioni consigliate, pro/contro e punti incerti | Non approvare le scelte al posto dell'utente |
| 8 | **Riprendere il film completo** | Schede personaggi, ambientazioni e sceneggiatura scena per scena | Conservare prologo e finale del gioco |

## Policy qualità e provenienza
- Non esistono percentuali garantite di fedeltà basate sul numero di screenshot; il 4K finale non elimina le incertezze della sorgente.
- Il personaggio **deve essere riutilizzabile** e coerente nel volto, età, costume e materiali; l'identità finale richiederà controllo visivo dell'utente dopo l'eventuale futuro primo modello.
- Non utilizzare volti di Desmond, di attori reali, di Brotherhood o Revelations per ricavare arbitrariamente quello di Ezio.
- Le fonti ufficiali e i fotogrammi riportati da terzi restano link/documentazione; nessun download/import automatico di asset Ubisoft o di terzi.
- Nessun acquisto o API a consumo. **Solo pre-produzione**, senza immagini sintetiche, modelli, render, animazioni o video.

## Testo pronto per Claude sul sito
> Nel repository FILM, leggi `CLAUDE.md` e `docs/reference/CHR-001_PREPRODUZIONE_DA_BROWSER.md`. L'utente non è a casa e **non vuole fare screenshot aggiuntivi**: usa le fonti A-EXT/B già raccolte per proseguire esclusivamente i documenti di pre-produzione. Prepara la matrice D4 (armi), la proposta D5 (età/varianti), il lookdev D6 e la continuità della collana D7, separando fatti canonici da scelte proposte. Mantieni D2/D2-bis/D3/D8/D9 approvate, D1 approvata su AC II originale PC Ubisoft Connect, ma NON considerare approvate D4/D5/D6/D7. Non generare immagini, modelli o video. Presentami un unico dossier testuale conciso da approvare.
