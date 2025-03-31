# teloview

A simple R shiny app to visualize contigs, scaffolds, and telomere motifs.

You can test the app here: https://gbdias-teloview.share.connect.posit.cloud

<img width="1339" alt="Screenshot 2025-03-25 at 14 54 39" src="https://github.com/user-attachments/assets/cec8f469-db76-4bab-999d-b19958f4e556" />

> Example of teloview output. Contigs are rendered as segments of alternating colors inside each scaffold. The abundance of the telomere motif is shown in the red line above each scaffold.


>[!TIP]
>The Posit Cloud instance of this app is hosted on a free plan and might take a long time to launch. For more stable/quicker usability try cloning the repository and executing the app.R script locally. You will need to install : shiny, shinythemes, dplyr, karyoploteR, and rtracklayer for it to work.

# Inputs
- Assembly file in AGP/BED format
- Telomere track in bedGraph format

## Assembly file
For a scaffolded assembly, it takes an [AGP](https://www.ncbi.nlm.nih.gov/genbank/genome_agp_specification/) file as input, such as the output of Hi-C scaffolding with tools like [YaHS](https://github.com/c-zhou/yahs).
Alternatively, you can provide scaffold names and start and end coordinates in BED format (e.g. scaffold1  0  12000). In this case, only scaffolds will be drawn and no contig boundaries will be shown.

## Telomere track
For the telomere track, a [bedGraph](https://genome.ucsc.edu/goldenpath/help/bedgraph.html) file must be provided. This can be quickly generated with [tidk](https://github.com/tolkit/telomeric-identifier) as follows:
```{bash}
tidk search --string TTACC --output telo_track --dir ${PWD} --extension bedgraph
```
Make sure to replace the telomere string with the correct sequence for your species. Check [TeloBase](https://shinyapps.biodata.ceitec.cz/TeloBase/) for a compilation of telomere sequences.



