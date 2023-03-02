
# User Interface ----------------------------------------------------------

ui <- navbarPage(
  tags$body(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  shinyjs::useShinyjs(),
  
  
  title = "Small Business Innovation Research", # fn_navbar(),
  theme = fn_custom_theme(primary = "#E41C38", secondary = "#E41C38"),
  windowTitle = "Small Business Innovation Research",
  
  
  # modules -----------------------------------------------------------------
  map_UI("main"),
  plots_UI("main")
  
)