# Ricerca massiva — Incarico #12 (Fase A) · stato e indice

**Stato complessivo:** DA VERIFICARE · BOZZA DI RICERCA · nessuna approvazione implicita.
**Data:** 2026-10-13 · **Ordine:** issue #12 + documenti della PR #13 (`docs/claude/ORDINE_OPERATIVO_MASSIVO_PROLOGO_FOTOREALISTICO.md`, `SORGENTI_E_STRUMENTI_DA_VERIFICARE.md`, `ACCETTAZIONE_ANTEPRIMA_E_VOCI.md`).
**Perimetro rispettato:** solo Markdown e script PowerShell originali di staging, inventario e launcher. Sono non testati su Windows e non hanno eseguito alcuna operazione sul PC dell'utente. Nessun asset, audio, mesh, texture, filmato o testo di dialogo del gioco nel repository. Nessun servizio a pagamento. Nessun download o esecuzione di tool sul PC dell'utente da parte di Claude.

## Legenda degli stati delle fonti (usata in tutti i file)
| Stato | Significato |
|---|---|
| **TESTATO** | Eseguito davvero sui file AC II dell'utente e risultato osservato. **In questa sessione: nessuna voce è TESTATA** (Claude non ha accesso al PC né ai file del gioco). |
| **DOCUMENTATO** | Letto in una fonte primaria raggiungibile (repository/wiki dell'autore, sito ufficiale), con URL controllato il 2026-10-13. Non prova che funzioni sulla copia Ubisoft Connect. |
| **IPOTESI** | Deduzione ragionevole da fonti indirette (altre piattaforme, altri giochi, nomi file); da confermare. |
| **NON RAGGIUNGIBILE** | Pagina che restituisce 403/timeout dalla sessione cloud (es. Nexus, ModDB, SteamDB, documentazione Omniverse). Non usata come prova. |

## Aggiornamento operativo — opzione 2 approvata dall'utente
Il nuovo percorso è [OPZIONE2_ARCHIVI_COPIATI.md](OPZIONE2_ARCHIVI_COPIATI.md). La preparazione iniziale **copia solo DataPC_Abstergo.forge** dalla cartella Ubisoft Connect `D:\Games\Assassin's Creed II` verso `D:\FILM_ARCHIVI_RO`, **con controllo SHA256**, prima di avviare Claude. Claude usa una **seconda utenza Windows standard** con accesso **soltanto in lettura** a questi file e lavora in `D:\FILM_PRIVATO`. Le ACL della **sola copia** sono configurate **automaticamente** dallo script di staging (`-ProtectCopyForUser`, conferme separate `COPIA` e poi `PROTEGGI`, verifica AuthZ, ripristino `-RipristinaAcl`), mai sul gioco originale. Test previsti: [TEST_WINDOWS_OPZIONE2.md](TEST_WINDOWS_OPZIONE2.md). Nessuna esecuzione su Windows è stata verificata in questa sessione; la protezione delle altre cartelle del PC non è garantita dal solo launcher.

Script nuovi/aggiornati: [staging](scripts/prepara_copia_privata_acii.ps1), [launcher](scripts/avvia_claude_locale.ps1), [inventario su copia](scripts/inventario_acii_readonly.ps1). **Il launcher non accetta più -GameDir.** I testi storici che descrivono l'accesso diretto al gioco sono superati da questo aggiornamento.

## Documenti
| File | Contenuto |
|---|---|
| [INDICE_ASSET_ACII.md](INDICE_ASSET_ACII.md) | Archivi `.forge`, audio `.pck`, video `.bik`: cosa contengono presumibilmente e come confermarlo. |
| [MATRICE_ENV_E_PERSONAGGI.md](MATRICE_ENV_E_PERSONAGGI.md) | Copertura per ENV-001…014, personaggi, comparse e PROP-001…014. |
| [BENCHMARK_TOOLCHAIN.md](BENCHMARK_TOOLCHAIN.md) | Strumenti per estrazione, ricostruzione e illuminazione; RTX Remix vs Blender; criteri di benchmark sulla RTX 5070 Ti. |
| [LIMITI_E_DIRITTI.md](LIMITI_E_DIRITTI.md) | Vincoli legali/tecnici, cosa non fare, dove tenere i file privati. |
| [VOCE_ITALIANA_ORIGINALE_CATALOGO.md](VOCE_ITALIANA_ORIGINALE_CATALOGO.md) | Banchi vocali, metodo di estrazione privata, tabella PERSONAGGIO → CLIP → SCENA (vuota finché non verificata). |
| [PIPELINE_E_STATO_ANTEPRIMA.md](PIPELINE_E_STATO_ANTEPRIMA.md) | Fase B/C: pipeline proposta, **blocco circostanziato dell'anteprima**, unico percorso manuale. |
| [CLAUDE_CODE_LOCALE_DELEGA.md](CLAUDE_CODE_LOCALE_DELEGA.md) | Proposta per delegare il lavoro a **Claude Code locale** con accesso limitato: permessi, fasi L0–L6 con stop, gate creativi. |
| [scripts/avvia_claude_locale.ps1](scripts/avvia_claude_locale.ps1) | Launcher fail-closed per l'account Claude: manifest V2 (SID dell'account), SHA256 e byte, DACL della copia protetta, accesso **effettivo** (AccessCheck) di sola lettura su ogni elemento della copia, nessun diritto critico sul genitore, account standard non elevato, nessuna configurazione preesistente, capitolato al commit atteso e pulito; poi, solo con conferme, capitolato e avvio in `plan`. **Non eseguito su Windows.** |
| [scripts/prepara_copia_privata_acii.ps1](scripts/prepara_copia_privata_acii.ps1) | Staging con l'account preparatore: copia solo Abstergo con SHA256 e **protezione NTFS automatica della sola copia** solo con `-ProtectCopyForUser` (conferma separata `PROTEGGI` dopo la verifica SHA256; anche su copia esistente), verifica AuthZ, ripristino automatico o `-RipristinaAcl`, `-DryRun` senza modifiche. **Non eseguito su Windows.** |
| [scripts/test/Test-StaticoOpzione2.ps1](scripts/test/Test-StaticoOpzione2.ps1) | Suite di controlli **statici**, per PowerShell 5.1 e 7: parametri, `-DryRun`, gioco mai modificato, ACL solo sulla copia, rifiuti del launcher. Non tocca file né ACL. |
| [TEST_WINDOWS_OPZIONE2.md](TEST_WINDOWS_OPZIONE2.md) | Controlli statici eseguiti e **test reali su Windows da eseguire** (nessuno superato finora). |
| [scripts/inventario_acii_readonly.ps1](scripts/inventario_acii_readonly.ps1) | Inventario facoltativo in sola lettura (nomi, dimensioni, hash). Rifiuta `OutDir` uguale o interna al gioco e i percorsi con junction/symlink; segnala gli errori di lettura come inventario INCOMPLETO. Da eseguire solo se e quando l'utente lo decide. **Non eseguito né testato** (nella sessione cloud non c'è PowerShell): rileggerlo prima dell'uso. |

## Esito sintetico
1. **Fase A:** completata come ricerca documentale (nessun test sui file reali).
2. **Fase B:** pipeline progettata ma **non verificata** (nessun test eseguito).
3. **Fase C:** `FILM_PREVIEW_01_ABSTERGO.png` **NON generata**. Motivo e percorso manuale in [PIPELINE_E_STATO_ANTEPRIMA.md](PIPELINE_E_STATO_ANTEPRIMA.md).
4. **Fase D (primi 15 minuti):** non avviata, non autorizzata.
