FROM rocker/shiny:4.2.1
RUN install2.r rsconnect shiny shinythemes dplyr karyoploteR rtracklayer
WORKDIR /home/teloview
COPY teloview.R teloview.R 
COPY deploy.R deploy.R
CMD Rscript deploy.R
