FROM rocker/shiny:latest
RUN apt-get update && apt-get install -y \
    liblzma-dev \
    zlib1g-dev \
    libbz2-dev \
    libcurl4-openssl-dev
RUN install2.r dplyr BiocManager devtools remotes
RUN R -e 'remotes::install_version("rsconnect", "1.1.0")'
RUN R -e 'install.packages("shinythemes")'
RUN R -e 'BiocManager::install(ask = F)' && R -e 'BiocManager::install(c("karyoploteR", "rtracklayer","regioneR", "Rsamtools", "biovizBase", "GenomicFeatures", "bamsignals", "VariantAnnotation"))'
WORKDIR /home/teloview
COPY app.R app.R 
COPY deploy.R deploy.R
CMD Rscript deploy.R
