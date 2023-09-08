FROM rocker/shiny:latest
RUN install2.r dplyr BiocManager devtools remotes
RUN R -e 'remotes::install_version("rsconnect", "1.1.0")'
RUN R -e 'BiocManager::install(ask = F)' && R -e 'BiocManager::install(c("karyoploteR", "rtracklayer","regioneR", "Rsamtools", "biovizBase", "GenomicFeatures", "bamsignals", "VariantAnnotation"))'
WORKDIR /home/teloview
COPY app.R app.R 
COPY deploy.R deploy.R
CMD Rscript deploy.R
