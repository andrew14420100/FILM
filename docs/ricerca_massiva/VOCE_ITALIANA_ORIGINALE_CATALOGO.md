# VOCE_ITALIANA_ORIGINALE_CATALOGO — registrazioni originali italiane

**Stato:** DA VERIFICARE · nessuna clip ascoltata, estratta o mappata in questa sessione.
**Regole (#12, vincolanti):**
- solo `SoundData/pc/sounds_ita.pck` della copia legittima dell'utente;
- **nessuna** sintesi, TTS, clonazione, conversione o alterazione di timbro o tono;
- **nessun file audio su GitHub**;
- **nessuna battuta trascritta** in questo file (CLAUDE.md, vincolo 5); si annotano solo codici, durate e descrizioni neutre;
- pulizia o restauro **rinviati**;
- dove manca la registrazione si scrive `AUDIO_ORIGINALE_ASSENTE` e si propone una revisione del copione.

## 1. Metodo di estrazione privata (DOCUMENTATO, non TESTATO)
1. Copiare `sounds_ita.pck` (251.339.055 byte nell'installazione Steam 2011; la copia Ubisoft Connect è da verificare) in `D:\FILM_PRIVATO\audio_ita\pck\`.
2. Estrarre il contenitore AKPK con QuickBMS e `wwise_pck_extractor.bms` (https://aluigi.altervista.org/bms/wwise_pck_extractor.bms) in `...\audio_ita\bnk_wem\`.
3. Leggere i `.bnk` con **wwiser** (https://github.com/bnnm/wwiser), usando i nomi di **wwiser-utils** (`wwnames/Assassin's Creed II (X360).txt`) per dare un nome ai banchi, e generare i `.txtp`.
4. Riprodurre o decodificare con **vgmstream** (https://github.com/vgmstream/vgmstream) in WAV, solo in locale.
5. Associare ogni clip alla scena **ascoltandola** e confrontandola con i sottotitoli italiani del gioco (IPOTESI: testi in `DataPC.forge`, apribili con AnvilToolkit). Gli eventi Wwise sono hash, quindi non si può mappare per nome.
6. Su GitHub si registra solo: codice clip privato (es. `ITA_P01_M01_007`), durata, personaggio, scena PRO-xxx, stato. **Mai** il file o il testo.

## 2. Banchi vocali rilevanti (nomi dalla lista X360 di wwiser-utils)
Il significato dei prefissi è un'**IPOTESI** basata sulla struttura del gioco: `P` = presente (Desmond 2012), `SQ` = sequenza, `AI`/`ONO` = battute di sistema o di ambiente, `BM` = missioni del database o secondarie.

| Banco | Contenuto ipotizzato | Uso nel film | Stato |
|---|---|---|---|
| `BNK_VO_Previously_On` | Narrazione del riepilogo iniziale (`Previously_On.bik`) | Solo riferimento: il monologo d'apertura del film è **originale** (P-04) | IPOTESI |
| `BNK_VO_P01_M01`, `BNK_VO_P01_M02`, `BNK_VO_P01_M04` | Presente, blocco 1: Abstergo, fuga e arrivo al rifugio (manca M03 nella lista) | PRO-002…PRO-013 | IPOTESI |
| `BNK_VO_P02_M01`…`M06` | Presente, interludi successivi nel rifugio | Intermezzi di Desmond nelle Seq. 2–14 | IPOTESI |
| `BNK_VO_P03_M01` | Presente, blocco finale | Dopo la Seq. 14 | IPOTESI |
| `BNK_VO_SQ01_M01`…`M12` | Sequenza 1, dalla memoria 1 alla 12 (nascita, Firenze 1476–1478) | PRO-005/006/014 e Seq. 1 | IPOTESI |
| `BNK_VO_SQ02`…`SQ14_*` | Sequenze successive, comprese `SQ12_M01…M11` e `SQ13_M01…M12` | Seq. 2–14 (S-01: le Seq. 12–13 esistono come banchi X360; **presenza su PC DA VERIFICARE**) | IPOTESI |
| `BNK_VO_AI_and_ONO_Desmond_Miles` | Battute di sistema di Desmond | Solo se diegetiche e coerenti con la regola film/non gameplay | IPOTESI |
| `BNK_VO_AI_and_ONO_Lucy` | Battute di sistema di Lucy | Come sopra | IPOTESI |
| `BNK_VO_AI_and_ONO_Ezio`, `BNK_VO_ONO_Federico_Auditore`, `BNK_VO_AI_Vieri_De_Pazzi`, `BNK_VO_AI_Maria_Auditore`, `BNK_VO_AI_Federico_Auditore` | Voci di personaggi del 1476 | PRO-014 e Seq. 1 | IPOTESI |
| `BNK_VO_Tutorial_*` | Battute dei tutorial | **Escluse**: non ci sono tutorial nel film (regola di adattamento) | IPOTESI |

**Nota sui DLC:** la lista X360 contiene i banchi `SQ12_*` e `SQ13_*`. Nell'elenco Steam 2011 il pacchetto `sounds_ita.pck` è uno solo; se le voci dei DLC su PC stiano in quel pacchetto o in un altro è **DA VERIFICARE**.

## 3. Tabella PERSONAGGIO → CLIP ORIGINALE → SCENA (prologo)
Le colonne CLIP e DURATA restano **vuote** finché la clip non è stata ascoltata in privato. Le battute non si trascrivono.

| Scena | Personaggio | Banco ipotizzato | CLIP ORIGINALE (codice privato) | Durata | Stato | Note |
|---|---|---|---|---|---|---|
| PRO-001 Monologo d'apertura | Voce narrante (da decidere) | — | — | — | `AUDIO_ORIGINALE_ASSENTE` (previsto) | P-04: monologo **originale** del film. Non esiste una registrazione italiana corrispondente, e non si sintetizza. **Proposta di revisione:** apertura senza voce (cartelli muti o solo suono) oppure riuso di una clip di `BNK_VO_P01_*` se esiste e si adatta. Decisione utente. |
| PRO-002 La stanza di Desmond | Desmond | `P01_M01` | | | DA VERIFICARE | |
| PRO-002 | Lucy | `P01_M01` | | | DA VERIFICARE | |
| PRO-003 Lucy | Lucy | `P01_M01` | | | DA VERIFICARE | Scena dell'anteprima: Lucy entra, Desmond si volta. |
| PRO-003 | Desmond | `P01_M01` | | | DA VERIFICARE | |
| PRO-004 Ingresso nella memoria | Lucy | `P01_M01`/`M02` | | | DA VERIFICARE | |
| PRO-005 La nascita di Ezio | Giovanni | `SQ01_M01` | | | DA VERIFICARE | |
| PRO-005 | Maria / domestiche | `SQ01_M01` | | | DA VERIFICARE | |
| PRO-006 Visione di Ezio adulto | — | `SQ01_M01` | | | DA VERIFICARE | Possibile assenza di voce. |
| PRO-007 Estrazione e memory core | Lucy | `P01_M02` | | | DA VERIFICARE | |
| PRO-007 | Desmond | `P01_M02` | | | DA VERIFICARE | |
| PRO-008 Corridoi di vetro | Lucy / Desmond | `P01_M02` | | | DA VERIFICARE | Escludere le battute di istruzione da gameplay. |
| PRO-009 La sala degli Animi | Lucy / Desmond | `P01_M02` | | | DA VERIFICARE | |
| PRO-010 Parcheggio | Lucy / Desmond / guardie | `P01_M02`, `AI_*` | | | DA VERIFICARE | |
| PRO-011 Arrivo e scelta | Lucy / Desmond | `P01_M04` (IPOTESI) | | | DA VERIFICARE | |
| PRO-012 La squadra | Rebecca, Shaun, Lucy, Desmond | `P01_M04` | | | DA VERIFICARE | Le voci di Rebecca e Shaun non hanno un banco `AI_` dedicato nella lista: presenza nei banchi `P01` DA VERIFICARE. |
| PRO-013 Animus 2.0 | Rebecca / Lucy / Desmond | `P01_M04` | | | DA VERIFICARE | |
| PRO-014 Ponte Vecchio | Ezio, Federico, Vieri, comparse | `SQ01_M02` (IPOTESI) | | | DA VERIFICARE | |

## 4. Regola `AUDIO_ORIGINALE_ASSENTE`
Quando il copione del film prevede una battuta senza una registrazione italiana originale corrispondente, si sceglie una di queste strade:
- **eliminare** la battuta;
- **sostituirla con un'azione o un silenzio**;
- **sostituirla con una clip originale esistente** dallo stesso personaggio e contesto, purché il senso non cambi e non si alteri la clip.

In ogni caso la modifica si **propone come revisione del copione** e richiede l'approvazione dell'utente. È vietato sintetizzare o clonare la voce.
