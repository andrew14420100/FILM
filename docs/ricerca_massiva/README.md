# Ricerca massiva — Incarico #12 (Fase A) · stato e indice

**Stato complessivo:** DA VERIFICARE · BOZZA DI RICERCA · nessuna approvazione implicita.
**Data:** 2026-10-13 · **Ordine:** issue #12 + documenti della PR #13 (`docs/claude/ORDINE_OPERATIVO_MASSIVO_PROLOGO_FOTOREALISTICO.md`, `SORGENTI_E_STRUMENTI_DA_VERIFICARE.md`, `ACCETTAZIONE_ANTEPRIMA_E_VOCI.md`).
**Perimetro rispettato:** solo Markdown e uno script PowerShell originale in sola lettura. Nessun asset, audio, mesh, texture, filmato o testo di dialogo del gioco nel repository. Nessun servizio a pagamento. Nessun download o esecuzione di tool sul PC dell'utente da parte di Claude.

## Legenda degli stati delle fonti (usata in tutti i file)
| Stato | Significato |
|---|---|
| **TESTATO** | Eseguito davvero sui file AC II dell'utente e risultato osservato. **In questa sessione: nessuna voce è TESTATA** (Claude non ha accesso al PC né ai file del gioco). |
| **DOCUMENTATO** | Letto in una fonte primaria raggiungibile (repository/wiki dell'autore, sito ufficiale), con URL controllato il 2026-10-13. Non prova che funzioni sulla copia Ubisoft Connect. |
| **IPOTESI** | Deduzione ragionevole da fonti indirette (altre piattaforme, altri giochi, nomi file); da confermare. |
| **NON RAGGIUNGIBILE** | Pagina che restituisce 403/timeout dalla sessione cloud (es. Nexus, ModDB, SteamDB, documentazione Omniverse). Non usata come prova. |

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
| [scripts/avvia_claude_locale.ps1](scripts/avvia_claude_locale.ps1) | Launcher: controlli in sola lettura (separazione dal gioco, junction/symlink, sessione non elevata), poi, solo con conferma, copia del capitolato con manifest, configurazione in `D:\FILM_PRIVATO` e avvio in modalità `plan`. **Non eseguito né testato.** |
| [scripts/inventario_acii_readonly.ps1](scripts/inventario_acii_readonly.ps1) | Inventario facoltativo in sola lettura (nomi, dimensioni, hash). Rifiuta `OutDir` uguale o interna al gioco e i percorsi con junction/symlink; segnala gli errori di lettura come inventario INCOMPLETO. Da eseguire solo se e quando l'utente lo decide. **Non eseguito né testato** (nella sessione cloud non c'è PowerShell): rileggerlo prima dell'uso. |

## Esito sintetico
1. **Fase A:** completata come ricerca documentale (nessun test sui file reali).
2. **Fase B:** pipeline progettata ma **non verificata** (nessun test eseguito).
3. **Fase C:** `FILM_PREVIEW_01_ABSTERGO.png` **NON generata**. Motivo e percorso manuale in [PIPELINE_E_STATO_ANTEPRIMA.md](PIPELINE_E_STATO_ANTEPRIMA.md).
4. **Fase D (primi 15 minuti):** non avviata, non autorizzata.
