FROM rocker/shiny:4.2.1
RUN install2.r dplyr BiocManager devtools rsconnect
RUN R -e 'update.packages("rsconnect")'
RUN R -e 'BiocManager::install(ask = F)' && R -e 'BiocManager::install(c("karyoploteR", "rtracklayer"))'
WORKDIR /home/teloview
COPY teloview.R teloview.R 
COPY deploy.R deploy.R
CMD Rscript deploy.R
