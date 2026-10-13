# PILOTA PROLOGO — Prova audiovisiva locale (20 secondi)

**Autorizzazione attuale (2026-10-13):** l'utente vuole **iniziare una prova del prologo per decidere se proseguire**. Questa richiesta nuova è un'**eccezione limitata** al precedente blocco della produzione, **solo per il test pilota**. Non autorizza la produzione integrale, il download massivo di asset Ubisoft, l'esportazione/publicazione, le spese o la sostituzione delle scelte narrative già approvate. La branch non va unita automaticamente a `main`.

## Cosa facciamo, e cosa NON promettiamo

**Obiettivo del test:** 4 clip locali di circa 5 secondi (20 secondi totali), ambientati nel blocco Abstergo dell'apertura: ambiente credibile, movimenti umani, identità Desmond/Lucy, tessuti, pelle e capelli. **Niente gameplay/HUD.**

**Non è ancora un video creato.** In questa sessione posso predisporre su GitHub il progetto e i programmi, **ma non ho accesso alla GPU locale dell'utente** e non posso inviare job alla sua istanza ComfyUI Windows. Il test si produrrà solo quando il workflow verrà avviato sul suo computer.

**Limiti reali:** i generatori video possono cambiare volto fra clip, deformare mani e oggetti, sbagliare costumi e movimenti. Testare a risoluzione moderata **non equivale a garantire fotorealismo 4K nativo**. Un file 3840×2160 ottenuto per interpolazione da un video più piccolo *non* possiede i dettagli di un film realmente renderizzato in 4K.

## Archivio esteso del prologo (ambienti, personaggi, oggetti)
- [Catalogo completo delle fonti e delle lacune](CATALOGO_COMPLETO_PROLOGO_ACII_2009_2010.md): **14 ambienti**, cast del 2012/1459/1476, props e matrice dei master non ancora costruiti.
- [Indice immagini nominate e shot list completa](INDICE_IMMAGINI_ACII_E_SHOTLIST_PROLOGO.md): nomi file verificabili nelle gallerie, **14 gruppi di scene da documentare** con reference e limiti di visibilità.
- [Primo dossier Abstergo/Desmond/Lucy](REFERENCE_ONLINE_AC2_ABSTERGO_DESMOND_LUCY.md): ricerca iniziale, ora integrata dai due indici sopra.

**Status:** non esiste ancora un \`ABSTERGO_ENV_MASTER\` né un character lock 3D; la raccolta link **non equivale alla configurazione di set/render**. Prima del test definitivo del prologo servono reference multiprospetto o ambiente di riferimento bloccato. Non iniziare l'intero film in automatico.

## Reference originali di AC II recuperate online
Prima di iniziare a rendere definitivo il volto o la scenografia, consultare il [catalogo ABSTERGO / DESMOND / LUCY](REFERENCE_ONLINE_AC2_ABSTERGO_DESMOND_LUCY.md) con screenshot AC II, gallerie dei personaggi e fonti C. **Non sono ancora master 3D**, e nessun fotogramma in GitHub è stato copiato. Sono esclusi da verifica i mod, gli artwork di AC III o i set più recenti di Abstergo Entertainment.

**Correzione di montaggio:** il pilota di quattro inquadrature è un **provino visivo** che prova volti/luci/movimenti; NON rappresenta ancora in ordine il prologo canonico. Tra la visita di Lucy e la fuga nel corridoio ci sono il ritorno nell'Animus e la **nascita di Ezio**. Non montare `02_lucy_ingresso → 04_corridoio` come se fosse l'intera scena originale. Il **titolo** va solo alla gara sui tetti con Federico (R-TITOLO), mai nell'incipit Abstergo.

## Perché Wan 2.2 TI2V 5B

- Modello locale, gratuito, open source (Apache 2.0), senza API a pagamento né crediti per generazione; si usa nel software libero **ComfyUI**.
- Workflow **ufficiale** da ComfyUI: `Workflow → Browse Templates → Video → Wan 2.2 5B Video Generation`, che supporta **Text-to-Video** e **Image-to-Video**.
- Guida ufficiale: https://docs.comfy.org/tutorials/video/wan/wan2_2
- Codice software: https://github.com/Comfy-Org/ComfyUI
- Modelli ufficiali confezionati: https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged
- Iniziare con **5B**, non col 14B, sulla RTX 5070 Ti 16GB. Configurazione orientativa: **832×480**, **81 fotogrammi**, **16 fps** (circa 5,06 s); queste impostazioni sono **proposte di test**, da adattare a limiti di memoria/parametri accettati dal workflow installato. Se appare CUDA out-of-memory, partire da **640×352**, ridurre i frame e chiudere altri modelli caricati in VRAM (JARVIS/LM Studio inclusi).
- Non installare nodi/estensioni non ufficiali per questo test se la template nativa funziona già.

## Procedura per Windows — senza costi

1. **Clona il branch**, da PowerShell, nella cartella che preferisci:
   ```powershell
   git clone --branch pilot/prologo-abstergo-20s-20261013 --single-branch https://github.com/andrew14420100/FILM.git FILM-PILOTA
   cd FILM-PILOTA
   powershell -ExecutionPolicy Bypass -File .\pilota_prologo\scripts\controlla_pc.ps1
   ```
2. Avvia **ComfyUI Desktop** (già noto all'utente) e aggiorna le componenti native dalla sua interfaccia, se necessario. Non occorre Blender per questa prova video. Non usare `uvx`.
3. In ComfyUI apri `Workflow → Browse Templates → Video → Wan 2.2 5B Video Generation`. La prima volta la UI propone di scaricare i pesi: **conferma consapevolmente**, perché possono occupare molti GB. Usa il workflow locale, **non Comfy Cloud** né provider a pagamento.
4. Se richiesto, seleziona i file ufficiali in `ComfyUI-Shared/models/` (cartella condivisa ComfyUI Desktop), come da guida:
   - `diffusion_models/wan2.2_ti2v_5B_fp16.safetensors`
   - `vae/wan2.2_vae.safetensors`
   - `text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors`
   Sulla tua installazione la base potrebbe essere `C:\Users\Msi\AppData\Local\Comfy-Desktop\ComfyUI-Shared\models`, ma la posizione va confermata.
5. Prova **prima una sola clip** con il contenuto di `prompts/01_desmond_cella.txt` (sezione POSITIVE) e `prompts/negative.txt` (sezione NEGATIVE); impostazioni iniziali 832×480, 81 frame, 16 fps. Tieni un **seed fisso** per poter confrontare le modifiche, ma non aspettarti che questo da solo blocchi il volto.
6. Se la prima clip funziona, usa in ordine `02_lucy_ingresso.txt`, `03_incontro.txt` e `04_corridoio.txt`. Mantieni la **stessa descrizione fisica dei personaggi**, costumi, ambiente e luce in tutti i prompt; riutilizza reference private per la variante **Image-to-Video** quando disponibili.
7. Salva i quattro file video generati in **`pilota_prologo/outputs/`**, con i nomi:
   ```text
   01_desmond_cella.mp4
   02_lucy_ingresso.mp4
   03_incontro.mp4
   04_corridoio.mp4
   ```
   Se ComfyUI produce un altro formato (es. WebM), esporta in MP4 con un programma gratuito prima di lanciare il montaggio.
8. Per montare un **MP4 silenzioso 1080p di prova**, installa FFmpeg gratuito se non presente e avvia:
   ```powershell
   py -3 .\pilota_prologo\scripts\monta.py
   ```
   (Se il launcher `py` non è disponibile, prova `python`.) Facoltativo, per un file *upscalato* 3840×2160, non 4K nativo:
   ```powershell
   py -3 .\pilota_prologo\scripts\monta.py --upscale-4k
   ```
9. Apri `pilota_prologo/outputs/PILOTA_ABSTERGO_1080p.mp4` e compila la [scheda di valutazione](VALUTAZIONE.md). Solo se il risultato supera i test, pianifichiamo gli altri blocchi del prologo (nascita di Ezio, fuga, rifugio, Animus 2.0, Firenze). **Non procedere con la produzione del resto automaticamente.**

## Personaggi e reference: punto più difficile

Desmond e Lucy devono mantenere **gli stessi volti e corpi** da un'inquadratura all'altra. I prompt **NON** garantiscono questo da soli. Su PC, conservare in `pilota_prologo/assets_privati/` (esclusi da Git) immagini che si possiedono o si ha diritto di usare come riferimento: vista frontale, 3/4, profilo, costume, sfondo. Devono essere le **stesse** su tutte le clip. Per le inquadrature con due personaggi sarebbe utile una reference della **composizione a due persone**, non soltanto due immagini separate.

Se ancora non abbiamo le reference, una prova **Text-to-Video** può misurare luce/movimento/stabilità, **ma NON può convalidare la fedeltà ai volti originali**. Una singola immagine generata o un clip ottenuto con prompt non costituisce un master definitivo. Non caricare screenshot, mesh, video o musica Ubisoft nel repo, che attualmente è pubblico.

## Soglie per decidere se continuare

**GO:** almeno 3/4 clip senza gravi deformazioni; stesso volto percepibile di Desmond e Lucy nelle inquadrature dove compaiono; cambi di luce naturali, corsa/passi credibili; tempo di generazione e VRAM sostenibili; costo software 0 €.

**NO-GO o RIVEDERE:** volti differenti, mani/superfici che si fondono, cambi di costume fra inquadrature, GPU in OOM/crash, output che sembra gameplay/cartoon oppure tempi per 20 s tali da rendere un film intero insostenibile. Anche superare questa prima prova **non garantisce** la produzione del film completo.

**Voce:** volutamente **esclusa dal primo test**, perché l'utente vuole doppiaggio italiano naturale e gratuito senza cast. L'aggiunta di voci richiede una scelta separata (attori volontari/licenze o soluzione gradita); non usare automaticamente TTS artificiali.

## Repository pubblico / diritti
Solo **testo, prompt e script** sono su GitHub. Tutte le reference del gioco, i volti privati e i video generati restano **sul PC dell'utente**. Non fare commit di file audiovisivi. Lo sviluppo è per uso personale dichiarato; le eventuali questioni di diritti vanno considerate prima di qualsiasi futura pubblicazione.
