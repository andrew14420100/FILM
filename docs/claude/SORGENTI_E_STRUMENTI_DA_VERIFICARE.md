# Fonti iniziali verificate — Claude deve espandere la ricerca massiva

**2026-10-13 · Registro di partenza, NON conclusione della ricerca.** Sono link realmente esistenti verificati online. Nessuna compatibilità con la copia Ubisoft Connect dell'utente è stata misurata. Non procedere a tool rischiosi o a download di asset di terzi.

## 1. File originali, archivi e audio

| Sorgente | Riscontro attualmente verificabile | Cosa DEVE controllare Claude |
| --- | --- | --- |
| [SteamDB, Depot PC AC II](https://steamdb.info/depot/33231/) | Nel catalogo di distribuzione PC di AC II appaiono diversi **`.forge`**, compresi `DataPC_WhiteRoom.forge` e archivi per altre regioni, oltre a `SoundData/pc/sounds_ita.pck`, `sounds_eng.pck` e `sounds_sfx.pck`. | Elencare i nomi effettivamente presenti nella **versione Ubisoft Connect** dell'utente e le differenze dalla distribuzione Steam. Non assumere che `WhiteRoom` contenga la stanza Abstergo: ispezionare l'indice della copia lecita. |
| [GameSaveInfo, lista file AC II Windows](https://github.com/GameSaveInfo/Reports/blob/master/AssassinsCreed2.Windows.txt) | File `sounds_ita.pck` e altri soundbank della distribuzione storica Windows risultano elencati. | Quale file contiene **dialoghi originali italiani del prologo**, quali dati effetti/musica; nomi effettivi e identificativi, senza dare per scontato che siano separati per personaggio. |
| [Forum Steam — posizione language sound files](https://steamcommunity.com/app/33230/discussions/0/4695657408658839704/) | Utenti indicano `SoundData/pc` per soundbank e lingua italiana, ma è una testimonianza di community. | Verificare file e codec **nella copia dell'utente**, modalità lecita e sola lettura. **NON seguire consigli dei forum per rinominare/sostituire archivi**: non è necessario per l'inventario e potrebbe danneggiare l'installazione. |

## 2. Tool di estrazione/modifica potenzialmente utili: nessuno ancora testato qui

| Sorgente | Funzionalità dichiarata dalla fonte | Cosa verificare |
| --- | --- | --- |
| [Turfster .forge extractor / Animus / Lucy — ModDB](https://www.moddb.com/downloads/forge-extractorreplacer-by-turfster) | La scheda del vecchio tool `Lucy v0.70` per AC II dichiara estrazione di blocchi, texture e **alcune** mesh 3D in OBJ, oltre a **gran parte** dei file sonori contenuti nei `.pck`. | Stato manutenzione, licenza, checksum, malware scan, compatibilità Windows 2026, integrità e completezza di mesh **ambientali** AC II, rig/UV/materiali; non assumere 100% supporto. Non scaricare binari incerti automaticamente. |
| [AnvilToolkit resources](https://github.com/Kamzik123/AnvilToolkit-Resources) e [Wiki Lesson 1](https://github-wiki-see.page/m/Kamzik123/AnvilToolkit-Resources/wiki/Lesson-1) | Esempi che aprono `DataPC_extra.forge` ed elementi di AC II; guide anche su modding di file di font/localizzazione. | Versione del toolkit, release ufficiale, licenze, **lettura non distruttiva**, estrazione ambiente, texture, modelli e animazioni compatibili con AC II. Nessuna necessità di patchare i file del gioco. |
| [AnvilToolkit Lesson 3](https://github-wiki-see.page/m/Kamzik123/AnvilToolkit-Resources/wiki/Lesson-3) | Tutorial su animazioni/mesh di AC II; include nomi `.AnimSet`. | Possibilità di recuperare personaggi, rig e retarget per uno studio privato; la pagina si autodefinisce obsoleta in parti: **non applicare manipolazioni binarie senza verifiche**. |
| [AC2 RTX Remix compatibility — Kamzik123/ac2-rtx](https://github.com/Kamzik123/ac2-rtx) | Progetto WIP: geometrie statiche e camera fedeli e materiali al renderer path-traced; dichiara problematiche aperte con **luci originali non viste, materiali piatti**. | Valutare cattura **di sola ricerca** dei livelli originali come riferimento di geometria e camera, fattibilità su RTX 5070 Ti, limiti; **RTX Remix da solo NON equivale a un film live-action**. |
| [AC2 PCK tool — Nexus](https://www.nexusmods.com/assassinscreedii/mods/206) | Mod descritto per ispezionare PCK/BNK e convertire WEM→WAV; la pagina include limitazioni di redistribuzione. | Provenienza del codice, disponibilità GitHub ufficiale, scanner, metodo read-only, output privato, tracciabilità dei file e uso compatibile con permessi/licenze. |
| [Blender](https://www.blender.org/) | Software libero per set 3D, PBR e render. | Quale add-on/importer funziona veramente con i dati estratti, profondità dei materiali, formato di consegna modificabile, misure reali. |
| [ComfyUI](https://github.com/Comfy-Org/ComfyUI) | Framework locale di generazione e trasformazione immagini/video. | Usarlo solo se utile come supporto e **se non causa mutazioni di identità e geometria**. Non usarlo come unico sostituto di set/character lock. |

## 3. Reference e continuità artistica AC II
- [FILM — PR #11: cataloghi referenze prologo](https://github.com/andrew14420100/FILM/pull/11), [catalogo esteso](https://github.com/andrew14420100/FILM/blob/pilot/prologo-abstergo-20s-20261013/pilota_prologo/CATALOGO_COMPLETO_PROLOGO_ACII_2009_2010.md), [indice con immagini nominate](https://github.com/andrew14420100/FILM/blob/pilot/prologo-abstergo-20s-20261013/pilota_prologo/INDICE_IMMAGINI_ACII_E_SHOTLIST_PROLOGO.md).
- [Animus Project laboratory](https://assassinscreed.fandom.com/wiki/Animus_Project_laboratory) — galleria e descrizione laboratorio.
- [Rome hideout](https://assassinscreed.fandom.com/wiki/Rome_hideout) — rifugio con Animus 2.0; non fonderlo col laboratorio.
- [Desmond Gallery](https://assassinscreed.fandom.com/wiki/Desmond_Miles/Gallery) · [Lucy Gallery](https://assassinscreed.fandom.com/wiki/Lucy_Stillman/Gallery) · [Animus Gallery](https://assassinscreed.fandom.com/wiki/Animus/Gallery).
- [Cronologia del prologo 2012](https://assassinscreed.fandom.com/wiki/21st_century_conversations), [The Birth of an Assassin](https://assassinscreed.fandom.com/wiki/The_Birth_of_an_Assassin).
- [Prologo V3 FILM (main)](https://github.com/andrew14420100/FILM/blob/main/docs/preproduzione/PROLOGO_TRATTAMENTO_V1.md) — non cambiare fatti e approvazioni silenziosamente.

## 4. Piano di verifica dell'esattezza senza rischiare il PC
1. Richiedere il percorso installazione Ubisoft Connect **solo quando Claude ha davvero accesso al PC**. Se usa soltanto GitHub Cloud, preparare uno script read-only che enumeri **nomi file, dimensioni, hash facoltativi**; evitare di chiedere upload dei file originali perché il repo è pubblico.
2. Separare `ARCHIVIO ESISTE` da `ASSET ESTRATTO` da `ASSET IMPORTATO` da `SET IDENTICO`: sono **quattro livelli di prova diversi**.
3. Non installare tool con bassa reputazione o binari non controllati. Preferire release ufficiali verificabili e codice open source leggibile, sempre offline quando possibile.
4. Ogni eventuale copia di lavoro va mantenuta **privata** sul computer dell'utente, mai esposta tramite issue, PR, LFS o release pubblica.
5. Per le voci: usare solo originale **italiano** come richiesto. Non sostituire con archivi inglesi per riempire frasi mancanti. Non clonarli con una AI.

**Obiettivo di questa scheda:** facilitare la ricerca di Claude, **non simulare un test già avvenuto**.
