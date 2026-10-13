# Modello di scheda-scena

Utilizzare una copia per ciascuna scena da trasformare in film. Non considerare definitivo alcun testo non verificato.

```yaml
scene_id: SC-000
titolo: ""
stato: DA_VERIFICARE # DA_VERIFICARE, VERIFICATA, APPROVATA
epoca: ""
sequenza_gioco: ""
missione_gioco: ""
riferimento_fonte: ""
timestamp_fonte: null
location_id: ""
personaggi: []
costumi: []
oggetti_di_scena: []
avvenimento_canonico: ""
condensazione_cinematografica: ""
proposta_creativa_separata: ""
durata_stimata_secondi: null
scene_precedenti: []
scene_successive: []
controlli_continuita: []
note_doppiaggio: ""
note_regia: ""
note_diritti: ""
approvazione_utente: false
```

## Controlli prima dell'approvazione
- La posizione cronologica corrisponde al gioco?
- Le azioni e il destino dei personaggi sono rimasti invariati?
- La fonte primaria è citata precisamente, senza timestamp inventati?
- Le informazioni su costume, voce, volto e oggetti sono coerenti?
- Sono distinti *fatto canonico*, *taglio di montaggio* e *aggiunta*?
- È chiaro il bisogno visivo per una scena con attori dall'aspetto reale?
- È stato rispettato il vincolo di non usare materiali protetti nel repository?

## Esempio minimo — apertura
SC-001 · Presente, Abstergo. **Da verificare sul filmato originale.** Desmond si trova all'interno della struttura. Lucy lo coinvolge nell'utilizzo dell'Animus, che mostra brevemente la nascita di Ezio prima della fuga. Suddividere in scene distinte dopo la visione e non inventare battute.
