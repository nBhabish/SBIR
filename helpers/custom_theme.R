# custom theme ------------------------------------------------------------

# NORC = "#ec712e"
# BBR  = "#E41C38"


fn_custom_theme <- function(primary, secondary){
  my_theme <- bslib::bs_theme(
    version    = 4,
    bootswatch = "united",
    fg         = "black",
    bg         = "white",
    primary    = primary,
    secondary  = secondary,
    base_font  = font_google("Harmattan"),
    heading_font = font_google("Harmattan"),
    font_scale  = 0.95
  )
}




