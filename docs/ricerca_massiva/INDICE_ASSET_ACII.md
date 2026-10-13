# INDICE_ASSET_ACII — archivi del gioco e loro uso previsto

**Stato:** DA VERIFICARE · tutte le righe sono **DOCUMENTATO** o **IPOTESI**; **nessuna TESTATA**.
**Avvertenza:** questo indice elenca soltanto **nomi e dimensioni di file** pubblicati da terzi. Non contiene né contenuti né estratti del gioco. Gli asset restano sul PC dell'utente, in spazio privato, e non vanno mai caricati su GitHub ([LIMITI_E_DIRITTI.md](LIMITI_E_DIRITTI.md)).

## 1. Fonte dell'elenco file
| Fonte | URL | Stato | Note |
|---|---|---|---|
| Report GameSaveInfo, installazione **Steam** Windows del 22/06/2011 | https://raw.githubusercontent.com/GameSaveInfo/Reports/master/AssassinsCreed2.Windows.txt | DOCUMENTATO | Una sola installazione, su Steam e non su Ubisoft Connect, con patch del 2011. **La copia dell'utente (D1, Ubisoft Connect) può avere nomi, dimensioni ed eseguibile diversi**: verificare prima la disponibilità degli archivi tramite [staging controllato](scripts/prepara_copia_privata_acii.ps1) e poi inventariare **solo la copia privata**, non il gioco, con lo [script in sola lettura](scripts/inventario_acii_readonly.ps1). |
| Liste file AnvilToolkit (`AC2.fgfl`, *Full File Lists*) | https://github.com/Kamzik123/AnvilToolkit-Resources (cartella `Full File Lists`) — repository verificato con `git ls-remote` | DOCUMENTATO (esistenza) / non leggibile | Formato compresso: si decodifica soltanto con AnvilToolkit («Export FGFL»), che non è eseguibile in questa sessione. |
| Lista nomi Wwise di AC II per **X360** | https://github.com/bnnm/wwiser-utils (`wwnames/Assassin's Creed II (X360).txt`) | DOCUMENTATO | Nomi dei banchi; usata nel [catalogo voci](VOCE_ITALIANA_ORIGINALE_CATALOGO.md). I nomi su PC potrebbero differire: **IPOTESI** che coincidano. |

## 2. Archivi `.forge` (geometria, texture, entità, testo)
I nomi seguono lo schema `DataPC_<area>.forge`. L'associazione area → scena è un'**IPOTESI basata sul nome** finché non si apre l'archivio con AnvilToolkit.

| Archivio (Steam 2011) | Byte | Uso ipotizzato per il film | Priorità prologo | Stato |
|---|---:|---|---|---|
| `DataPC_Abstergo.forge` | 83.492.864 | ENV-001…007: laboratorio, camera di Desmond, corridoi, sala Animi, garage | **ALTA** (anteprima) | IPOTESI |
| `DataPC_Hideout.forge` | 95.846.400 | ENV-008…010: rifugio 2012 e magazzino | ALTA | IPOTESI |
| `DataPC_WhiteRoom.forge` | 95.813.632 | ENV-014: spazio bianco o di caricamento dell'Animus | MEDIA | IPOTESI |
| `DataPC.forge` | 88.997.888 | Dati comuni: personaggi condivisi, interfaccia, **testi e sottotitoli** | ALTA (sottotitoli ITA per mappare le voci) | IPOTESI |
| `DataPC_Firenze.forge` | 790.888.448 | ENV-011…013: Firenze 1476 (Ponte Vecchio, Santa Trinita) ed eventualmente palazzo Auditore | ALTA | IPOTESI |
| `DataPC_Villa.forge` | 262.045.696 | Monteriggioni / Villa Auditore (Seq. 3 e seguenti) | dopo il prologo | IPOTESI |
| `DataPC_Toscana.forge` | 303.136.768 | San Gimignano e campagna toscana | dopo il prologo | IPOTESI |
| `DataPC_Wetlands.forge` | 390.987.776 | Forlì / Romagna | dopo il prologo | IPOTESI |
| `DataPC_Mountains.forge` | 120.061.952 | Appennini | dopo il prologo | IPOTESI |
| `DataPC_Venezia.forge` | 698.089.472 | Venezia | dopo il prologo | IPOTESI |
| `DataPC_Roma.forge` | 158.695.424 | Roma e Vaticano (Seq. 14) | dopo il prologo | IPOTESI |
| `DataPC_Altair_Memory.forge` | 118.849.536 | Memoria di Altaïr nel Codice | dopo il prologo | IPOTESI |
| `DataPC_LGS01_Duomo` … `LGS10_Visitazione` (10 file) | 33–89 MB ciascuno | Tombe degli Assassini (sigilli, D2/S-03) | dopo il prologo | IPOTESI |
| `DataPC_extra.forge`, `DataPC_extra_dlc.forge` | 91.619.328 ciascuno | Contenuti extra; **non** è accertato che contengano i DLC Seq. 12–13 | DA VERIFICARE | IPOTESI |
| `DataPC_TitleScreen.forge` | 2.031.616 | Schermata del titolo (non utile al film: R-TITOLO prevede un titolo originale del film) | nessuna | IPOTESI |

**Lacuna:** nell'elenco Steam 2011 **non compaiono archivi con nomi chiaramente riferiti alle Seq. 12 (*Battaglia di Forlì*) e 13 (*Falò delle Vanità*)**. Nella copia Ubisoft Connect potrebbero essere integrati altrove: **DA VERIFICARE** con l'inventario.

## 3. Audio (`SoundData/pc/`, formato Wwise AKPK)
| File | Byte | Contenuto | Stato |
|---|---:|---|---|
| `sounds_ita.pck` | 251.339.055 | **Voci italiane originali** (unica fonte vocale ammessa) | DOCUMENTATO (nome/dimensione) · IPOTESI (contenuto) |
| `sounds_eng.pck` | 245.208.708 | Voci inglesi: **non usare** per il film; utile al massimo per allineare gli eventi | DOCUMENTATO |
| `sounds_sfx.pck` | 554.694.991 | Effetti e musica: uso **DA DECIDERE** (non richiesto da #12) | DOCUMENTATO |

Il metodo di lettura privata è descritto in [VOCE_ITALIANA_ORIGINALE_CATALOGO.md](VOCE_ITALIANA_ORIGINALE_CATALOGO.md).

## 4. Filmati `.bik` (Bink), solo come riferimento privato
| File | Byte | Possibile utilità | Stato |
|---|---:|---|---|
| `Videos/Previously_On.bik` | 83.040.420 | Riepilogo «Nelle puntate precedenti» all'avvio: riferimento per il tono, **non** per il prologo del film | IPOTESI |
| `Videos/TheTruthVideo.bik` / `TheTruthVideoSmall.bik` | 59.670.164 / 10.401.024 | «La Verità» del Soggetto 16 (S-02) | IPOTESI |
| `Videos/ADB_*.bik` | 33–70 MB | Video del database su bersagli e personaggi | IPOTESI |
| `DemoIntro.bik`, `AVTR_DAY_TRAILER.bik` | — | Materiale promozionale | non pertinente |

I `.bik` sono filmati proprietari: si possono soltanto **guardare** in privato come riferimento e non si usano nel film (CLAUDE.md, vincolo 6).

## 5. Eseguibile (rilevante per la compatibilità dei tool)
| File | Byte | Nota | Stato |
|---|---:|---|---|
| `AssassinsCreedIIGame.exe` (Steam 2011) | 35.049.472 | La mod **ac2-rtx** è testata sull'MD5 `2dd4d3c196fa270945826d2faab42007`. Su build diverse le sue patch «no-op» (dalla README dell'autore). Confrontare l'MD5 della copia Ubisoft Connect con lo script, **senza modificare l'exe**. | DOCUMENTATO |

## 6. Come trasformare le IPOTESI in TESTATO (solo quando l'utente vorrà, sul suo PC)
1. **Opzione 2 approvata:** eseguire da account proprietario [scripts/prepara_copia_privata_acii.ps1](scripts/prepara_copia_privata_acii.ps1), prima con `-DryRun`, per copiare **solo** `DataPC_Abstergo.forge` in `D:\FILM_ARCHIVI_RO`. Validare SHA256/manifest e impostare ACL sola lettura **sulla copia** per l'account Claude; nessun cambio all'originale.
2. Solo dopo il controllo permessi: Claude usa [scripts/inventario_acii_readonly.ps1](scripts/inventario_acii_readonly.ps1) con `-ArchiveDir "D:\FILM_ARCHIVI_RO" -OutDir "D:\FILM_PRIVATO\inventario"`; l'estrazione va esclusivamente nel WorkDir. Non accede alla cartella del gioco. Procedura completa: [OPZIONE2_ARCHIVI_COPIATI.md](OPZIONE2_ARCHIVI_COPIATI.md).
3. Aprire `DataPC_Abstergo.forge` (copia) con AnvilToolkit e annotare nomi delle entità e dei mesh **solo nel file privato**. Su GitHub va unicamente lo stato «TROVATO NEL FILE LOCALE».
