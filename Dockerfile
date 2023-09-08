FROM rocker/shiny:4.2.1
RUN install2.r dplyr BiocManager devtools remotes
RUN R -e 'remotes::install_version("rsconnect", "1.1.0")'
RUN R -e 'BiocManager::install(ask = F)' && R -e 'BiocManager::install(c("karyoploteR", "rtracklayer"))'
WORKDIR /home/teloview
COPY teloview.R teloview.R 
COPY deploy.R deploy.R
CMD Rscript deploy.R
