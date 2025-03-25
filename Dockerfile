FROM rocker/shiny:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    liblzma-dev \
    zlib1g-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN install2.r dplyr shinythemes BiocManager
RUN R -e 'if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager"); BiocManager::install("karyoploteR", ask = FALSE, Ncpus = parallel::detectCores())'WORKDIR /home/teloview
WORKDIR /home/teloview

COPY app.R app.R 
COPY deploy.R deploy.R
CMD Rscript deploy.R
