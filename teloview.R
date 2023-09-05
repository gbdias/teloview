#!/usr/bin/env Rscript

library(shiny)
library(shinythemes)

# Define UI
ui <- fluidPage(
  titlePanel("Plot Hi-C scaffolds and telomere annotation"),
  theme = shinytheme("cosmo"),
  sidebarLayout(
    sidebarPanel(
      selectInput("filetype", "Which input file do you have for your genome?", choices = c("AGP","BED")),

      # AGP file input
      conditionalPanel(
        condition = "input.filetype == 'AGP'",
        fileInput("agpFile", "Select AGP file", multiple = F),
        verbatimTextOutput("agpFileInstructions")
      ),
      # BED file input
      conditionalPanel(
        condition = "input.filetype == 'BED'",
        fileInput("bedFile", "Select BED file", multiple = F),
        verbatimTextOutput("bedFileInstructions")
      ),
      fileInput("bedgraphFile", "Select tidk bedgraph file", multiple = F),
      verbatimTextOutput("bedgraphFileInstructions"),
      sliderInput("maxScaffolds", "Longest 'n' scaffolds to be plotted. Default is 10.", value = 10, 
        min = 1,
        max = 100
      ),
      textInput("main_title", label = "Enter main title for the plot.", value = "Genomic scaffolds")
    ),
    mainPanel(
      plotOutput("genomePlot"),
      downloadLink("downloadPlot")
    )
  )
)

# Define server
server <- function(input, output) {
  library(dplyr)
  library(karyoploteR)
  library(rtracklayer)
  options(shiny.maxRequestSize=100*1024^2)
  
  # Render instructions for agpFile
  output$agpFileInstructions <- renderText({
    "Please select an AGP file describing how the contigs were joined together into scaffolds."
  })
  # Render instructions for bedFile
  output$bedFileInstructions <- renderText({
    "Please select a BED file describing the name and length of your contigs. e.g. contig1    0    1500000"
  })
  # Render instructions for bedgraphFile
  output$bedgraphFileInstructions <- renderText({
    paste("Run tidk like so:\ntidk search --string $MOTIF -e bedgraph --dir $PWD -w 10000 --output $PREFIX scaffolds.fa")
  })

  # Read genome file
  scaffolds <- reactive({
    if (input$filetype == "AGP") {
    req(input$agpFile,input$maxScaffolds)
    scaffolds <- read.delim(input$agpFile$datapath, header = FALSE, sep = "\t", stringsAsFactors = FALSE, comment.char = "#")
    head(scaffolds)
    scaffolds <- 
      toGRanges(
        scaffolds %>%
          filter(V5=="W") %>%
          group_by(V1) %>%
          summarise(V2 = min(V2), V3 = max(V3)) %>%
          arrange(-V3) %>% 
          as.data.frame()
      )
    scaffolds <- scaffolds[1:input$maxScaffolds,]
    scaffolds
    } else if (input$filetype == "BED") {
      req(input$bedFile,input$maxScaffolds)
      scaffolds <- read.delim(input$bedFile$datapath, header = FALSE, stringsAsFactors = FALSE)
      scaffolds <- 
        toGRanges(
          scaffolds %>%
            arrange(-V3) %>% 
            as.data.frame()
        )
      scaffolds <- scaffolds[1:input$maxScaffolds,]
      scaffolds
    }
    })
  
  contigs <- reactive({
    if (input$filetype == "AGP") {
    req(input$agpFile)
    contigs <- read.delim(input$agpFile$datapath, header = FALSE, stringsAsFactors = FALSE)
    contigs <- 
      toGRanges(
        contigs %>%
          filter(V5=="W") %>%
          select(1:3) %>%
          as.data.frame()
      )
    contigs
    }
  })
  
  # Read bedgraph file
  telomeres <- reactive({
    req(input$bedgraphFile)
    telomeres <- import.bedGraph(input$bedgraphFile$datapath)
    telomeres
  })

  # Create genome plot
  output$genomePlot <- renderPlot({
    pp <- getDefaultPlotParams(1)
    pp$data1height <- 1000
    pp$topmargin <- 1200
    kp <- plotKaryotype(genome = scaffolds(), plot.type = 1, plot.params = pp, labels.plotter = NULL, main = input$main_title)
    kpAddChromosomeNames(kp, yoffset = 300, cex = 0.7)
    kpBars(kp, data = telomeres(), y1 = telomeres()$score, ymax = max(telomeres()$score), border="red", r0 = 0.35, r1 = 0.9)
    if (input$filetype == "AGP") {
    kpPlotRegions(kp, data = contigs(), data.panel = 1, col = c("lemonchiffon","grey75"), r0 = 0, r1 = 0.3)
    }
    })
  
  # Save genome plot
  output$downloadPlot <- downloadHandler(
    filename = function() { "genomeplot.pdf" },
    content = function(file) {
      pdf(file, width = 12, 
          height = sqrt(input$maxScaffolds)*2)
      pp <- getDefaultPlotParams(1)
      pp$data1height <- 1000
      pp$topmargin <- 1200
      kp <- plotKaryotype(genome = scaffolds(), plot.type = 1, plot.params = pp, labels.plotter = NULL, main = input$main_title)
      kpAddChromosomeNames(kp, yoffset = 300, cex = 0.7)
      kpBars(kp, data = telomeres(), y1 = telomeres()$score, ymax = max(telomeres()$score), border="red", r0 = 0.35, r1 = 0.9)
      if (input$filetype == "AGP") {
      kpPlotRegions(kp, data = contigs(), data.panel = 1, col = c("lemonchiffon","grey75"), r0 = 0, r1 = 0.3)
      }
      dev.off()
    }
  )
  
}
  
# Run the Shiny app
shinyApp(ui = ui, server = server)

