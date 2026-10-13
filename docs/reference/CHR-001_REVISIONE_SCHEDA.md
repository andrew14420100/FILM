# CHR-001 — Revisione della scheda tecnica di Ezio
**Stato:** REVISIONE EDITORIALE · 2026-10-13 · **Nessuna scelta D1–D7 approvata qui automaticamente.**

Documento oggetto della revisione: [Scheda tecnica ricevuta da Claude](CHR-001_EZIO_SCHEDA_TECNICA.md). L'originale allegato viene conservato senza modifiche per tracciabilità.

## Esito
La struttura della scheda è valida come bozza: distingue fonti A/B/C, tiene conto di costumi e attrezzatura per epoca, propone un Master 3D unico. Prima del modellamento restano obbligatori screenshot di origine certa dal **gioco AC II originale 2009/2010** e la decisione esplicita sulle varianti cinematografiche.

## Correzioni e precisazioni da sottoporre a Claude
1. **Volto non completamente ignoto.** §1.3 e §3.2 affermano che il volto sia oggi indefinibile perché le immagini promozionali B mostrano il cappuccio. Questa osservazione vale per *quella selezione* di B; Ezio compare a volto scoperto nelle scene iniziali fiorentine di AC II. La foto da confrontare con il gioco è disponibile in questa [immagine di confronto originale/mod](https://www.moddb.com/mods/assassins-creed-ii-overhaul-mod/images/ezionewcomparison) (NON usare la metà modificata come canon) e in [un esempio di scena con volto scoperto](https://www.accesstheanimus.com/ACI_the_prophet_ezio_story.html). Sono reference ausiliarie fino alla cattura primaria A. Non inventare forma e colore degli occhi: acquisirli da screenshot A.
2. **Linea «nessuna fonte A».** È corretta per le reference archiviate nel progetto, non per la disponibilità di immagini del gioco in generale. Registrare opportunamente questo per evitare che Claude consideri lo stato bloccato in assoluto.
3. **Costume di Lineage non identico a AC II.** Il live-action ufficiale può orientare tessuti e presenza fisica, ma il design di cappuccio, posizionamento fodero e coltelli differisce dal gioco: [scheda di Lineage e note di confronto](https://assassinscreed.fandom.com/wiki/Assassin%27s_Creed:_Lineage). Preferire il gioco.
4. **Armatura di Altaïr, Seq. 14.** In AC II è un'opzione ottenuta tramite sigilli delle tombe, ma le ricostruzioni della cronologia della serie la collocano anche nel finale del Vaticano; è una scelta di fedeltà narrativa da sottoporre all'utente: [riferimento comunitario, Armor of Altaïr](https://assassinscreed.fandom.com/wiki/Armor_of_Alta%C3%AFr). Non chiamare "obbligatoria in ogni partita".
5. **Misure facciali e QC** (§3.3, §10.5). I ±3–5%, ΔE≤6 e soglia embedding sono **valori progettuali**, non soglie scientificamente convalidate. Per misurare dimensioni occorrono prospettiva, scala, posa e focale coerenti; registrare gli intervalli e calibrare con test prima di dichiarare il controllo affidabile.
6. **Materiali e budget VRAM.** §8 prescrive texture volto 8K UDIM, ma non è un requisito assoluto del rendering 4K. Sulla RTX 5070 Ti 16 GB decidere la risoluzione texture per dettaglio in camera, uso effettivo della GPU e prove; un asset 8K multicanale può essere pesante.
7. **Invecchiamento e Character Lock.** L'identità deve rimanere riconoscibile senza richiedere rigidità anatomica letterale tra 17 e 40 anni; consentire morph controllati e approvati, non creare ogni volta un volto nuovo.
8. **Anulare, barba, colore occhi, cicatrice, peso/altezza.** Sono per ora dati comunitari o citazioni indirette del manuale. Mantenerli **VERIFICATA-C / DA VERIFICARE SU A o manuale** fino a prova primaria. La wiki documenta per esempio la ferita sul labbro nella rissa del [26 dicembre 1476](https://assassinscreedwiki.accesstheanimus.com/wiki/Ezio_Auditore_da_Firenze).
9. **La collana di perline non va esclusa a priori.** È visibile in screenshot del giovane Ezio, ma la singola scena/versione dovrà essere convalidata; al momento rimane una variante **DA VERIFICARE SU A** e la scelta D7 rimane aperta.
10. **Fedeltà vs realismo.** Non esiste un volto fotorealistico «identico» a un volto videoludico poco dettagliato senza scelte artistiche. Obiettivo: somiglianza approvata dall'utente, render 4K e continuità di asset; evitare percentuali di fedeltà arbitrarie.

## Raccomandazioni sulle decisioni D1–D7 (NON approvazioni)
| ID | Proposta | Stato |
| --- | --- | --- |
| D1 | **AC II originale 2009/2010** come fonte canonica. *Ezio Collection* solo comparazione secondaria. | CONSIGLIATA, da ratificare |
| D2 | **Armatura di Altaïr** nel Vaticano se si segue la continuità della saga, documentando l'acquisizione dei sigilli; oppure vesti Giovanni se si privilegia percorso minimo del gioco. | DA DECIDERE |
| D3 | Cappa **Medici** dopo il dono; cappa **Veneziana** se disponibile nell'epoca; evitare cambiamenti senza motivazione. | CONSIGLIATA, da ratificare |
| D4 | Usare solo armi disponibili alla sequenza; inventario visivo da approvare per ogni epoca. | DA COMPILARE |
| D5 | **19 anni (1478)** come età della mesh neutra; 17/27/29/38/40 derivate con morph controllati. | CONSIGLIATA, da ratificare |
| D6 | Materiali PBR del §8 come **bozza**: scegliere da render-test, non vincolare 8K per tutto. | NON ANCORA APPROVATA |
| D7 | **Collana solo se confermata** nei riferimenti A delle scene in cui appare. | CONSIGLIATA, da ratificare |

## Prossima operazione autorizzabile, ma non avviata
1. Catturare da AC II originale Ezio senza cappuccio: neutro frontale, profili, 3/4, in luce coerente.
2. Mettere immagini A localmente sul PC, registrando nel repo solo missione, versione e timestamp.
3. Rivedere GAP-01–18; spostare i dettagli da «ignoti» a «verificati» soltanto con fonti adeguate.
4. Proporre all'utente D1–D7, con priorità D2 e D4.
5. Solo dopo approvazione realizzare `EZIO_MASTER_v001` e confronto 8 viste.

**Diritti:** non sono stati caricati sul repository asset audiovisivi, screenshot, mesh o texture proprietarie; solo riferimenti testuali e URL esterni. Il repository resta pubblico finché l'utente non ne modifica la visibilità.
