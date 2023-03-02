FROM rocker/shiny-verse:latest

RUN apt-get update
RUN apt-get install -y libudunits2-dev 
RUN apt-get install -y libgdal-dev

# RUN R -e 'install.packages("devtools");'

# RUN R -e 'library("devtools"); install_github("LHaferkamp/httpuv")'

#RUN R -e 'remotes::install_github("r-quantities/units")'
RUN apt-get update && apt-get install -y \ 
    libssl-dev \
    ## clean up
    && apt-get clean \ 
    && rm -rf /var/lib/apt/lists/ \ 
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN install2.r tidyverse sf shiny shinyWidgets shinythemes scales shinyjs bslib leaflet plotly janitor\
    ## clean up
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Make directories and copy files to the image
RUN mkdir {helpers,modules,www}
COPY helpers/* helpers/
COPY modules/* modules/
COPY data/* data/
COPY sf_files/* sf_files/
COPY www/* www/
COPY global.R /
COPY server.R /
COPY ui.R /

# expose port
EXPOSE 3838

# run app on container start
# CMD ["R", "-e", "shiny::runApp('/', host = '0.0.0.0', port = 3838)"]

USER shiny