library(shiny) # Web Application Framework for R
library(shinyWidgets) # Custom Inputs Widgets for Shiny
library(shinythemes) # Themes for Shiny
library(shinyjs) # Easily Improve the User Experience of Your Shiny Apps in Seconds
library(plotly) # Create Interactive Web Graphics via 'plotly.js'
library(tidyverse) # Easily Install and Load the 'Tidyverse'


library(bslib) # Custom 'Bootstrap' 'Sass' Themes for 'shiny' and 'rmarkdown'


library(leaflet) # Create Interactive Web Maps with the JavaScript 'Leaflet' Library
library(sf) # Simple Features for R

# Loading Data ------------------------------------------------------------

military_tbl_formatted <-
  read_csv("data/military_spending_formatted.csv")
us_shp_file <-
  read_sf("sf_files/cb_2018_us_state_20m.shp") %>%
  janitor::clean_names()

file_paths <- fs::dir_ls(c("modules", "helpers"))
map(file_paths, function(x){source(x)})

source("ui.R")
source("server.R")


# profvis::profvis(runApp(shinyApp(ui, server)))
