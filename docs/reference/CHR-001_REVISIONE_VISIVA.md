# CHR-001 — Revisione della seconda raccolta visiva (Ezio / Armatura di Altaïr)

**Data:** 2026-10-13  
**Stato:** REVISIONE PRE-PRODUZIONE, NON APPROVAZIONE DEL PERSONAGGIO  
**Documento esaminato:** [CHR-001_EZIO_SCHEDA_VISIVA.md](CHR-001_EZIO_SCHEDA_VISIVA.md)  
**Materiali esaminati:** `TAVOLA_VOLTO.jpg` e `TAVOLA_ARMATURA.jpg` (forniti dall'utente; solo fuori repository).

## Cosa risulta dalle tavole fornite

- **Volto:** diverse immagini con cappuccio abbassato (quasi frontale, due 3/4, profilo sinistro), vista posteriore dei capelli e modello 3D del giovane Ezio etichettato con crediti degli artisti. **Sufficienti per un blockout di forme**, non per accertare colore degli occhi e texture della pelle.
- **Armatura di Altaïr:** vista fronte/retro, riferimento nel Santuario, alcune inquadrature contestuali e render di componenti provenienti da terzi. **Sufficiente per pianificare la forma generale e l'elenco dei pezzi**, non per certificare i materiali PBR definitivi.
- **Mancano / sono deboli:** frontale neutra adatta a misure, profilo destro puro, cicatrice guarita in primo piano, barba pulita 1488, verifica colori in luce neutra, interno della cappa e fianco destro dell'armatura.

## Precisazioni alla scheda e cautele editoriali

1. **A-EXT non è automaticamente PC.** Un'immagine caricata nel 2011–2013 è coerente con la generazione originale di AC II, ma data upload e risoluzione 1920×1080 non dimostrano la piattaforma PC né il build esatto. Registrare come «cattura di terzi, piattaforma/versione non verificata». Non chiamarla fonte A canonica definitiva.
2. **La nuova prova del volto supera il vecchio blocco totale**, ma non sostituisce foto A comparabili in luce e prospettiva. Il documento precedente va mantenuto come storico, mentre quello nuovo è la reference più recente.
3. **Artista accreditato nel collage:** i fogli del modello 1476 riportano l'attribuzione della testa a Michel Thibaut/Thibault e il resto a Nicolas Collings. Il contenuto va conservato con la variante di grafia indicata dalle fonti, non presentato come verifica indipendente del motore originale.
4. **Conflitti cromatici:** occhi ambra vs castani e varianti cappa rossa/scura dipendono da illuminazione, abbigliamento e fonti diverse. Non risolverli inventando una media.
5. **Età 38–40:** la mancata individuazione di un fotogramma senza cappuccio non prova l'inesistenza assoluta nel gioco. Per massima fedeltà mantenere cappuccio alzato nelle scene finali è una **raccomandazione**, non un fatto imposto al film.
6. **Armatura nella Seq. 13:** la presenza in screenshot e riferimenti della wiki giustifica la proposta di anticipare il costume rispetto al Vaticano, ma il suo ottenimento in AC II è opzionale nel gameplay. La scelta cinematografica va registrata solo dopo consenso.
7. **Modelli estratti/render di fan:** come reference C non sono automaticamente utilizzabili o redistribuibili, anche se visualizzabili ad alta risoluzione. Nel repo restano solo collegamenti e descrizioni.
8. **Un solo master, ma età credibili:** varianti di barba, rughe, pelle e piccole deformazioni approvate non violano il Character Lock. Nessuna sequenza generata da zero deve sostituire il volto approvato.
9. **Controlli automatici:** i parametri numerici della precedente scheda tecnica (similarità, rapporti facciali, Delta E) sono da calibrare sui render; non sono garanzia matematica di fedeltà.
10. **4K UHD:** il render 3840×2160 è un obiettivo di output, distinto da dettagli del modello e qualità delle animazioni. Non prescrivere 8K su ogni texture prima di benchmark VRAM.

## Decisioni: stato effettivo

| ID | Stato | Raccomandazione motivata |
| --- | --- | --- |
| D2 | **APPROVATA** | Armatura di Altaïr al Vaticano e nella Cripta di Minerva. |
| D2-bis | IN ATTESA | Consigliato: Armatura anche nella Seq. 13 (*Falò delle Vanità*), con acquisizione narrativa dei sei sigilli prima di quella sequenza. |
| D8 | IN ATTESA | Consigliato: cappuccio alzato nelle scene della Seq. 13–14 come nel riferimento filmico; volto maturo preparato comunque nel master per animazione/test. |
| D9 | IN ATTESA | Consigliato: accettare A-EXT **solo per blockout non definitivo**, senza convertire le incertezze cromatiche in dati approvati. |
| D3 | IN ATTESA | Consigliato: cappa **scura all'esterno e rossa all'interno** con Armatura di Altaïr nel finale; cappe Medici/Veneziana solo dove corrette per epoca e scena. |
| D1/D4/D5/D6/D7 | NON APPROVATE (salvo dichiarazioni successive) | Mantenere lo stato precedente delle decisioni; D7 possiede ora evidenza A-EXT della collana. |

## Prossima operazione raccomandata

1. Far approvare all'utente D2-bis, D8, D9 e D3.
2. Chiedere a Claude di integrare, **con tracciamento delle correzioni**, i riferimenti più affidabili nelle schede già archiviate, senza riscrivere la bozza originale ricevuta.
3. Far acquisire da una copia legittima del gioco 3–5 inquadrature A (fronte neutra, profilo destro, occhi, cicatrice guarita, barba 1488). Se non immediatamente possibili, consentire solo blockout provvisorio da A-EXT.
4. Non generare modelli, render o video senza nuova autorizzazione.

**NOTA DIRITTI:** le tavole JPEG contengono immagini di opere di terzi. Non caricarle in questo repo (attualmente pubblico); conservare il materiale di riferimento su supporto privato rispettando le licenze applicabili.
