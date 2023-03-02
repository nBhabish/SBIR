military_tbl_fitered_2010 <- military_tbl_formatted %>%
  filter(organization == "Department of Agriculture",
         date == 2010)

us_shp_1 <- us_shp_file %>%
  left_join(military_tbl_fitered_2010,
            by = c("stusps" = "state")) %>%
  mutate(total_obligation_label = scales::dollar(total_obligation)) 
  # mutate(funding_bin = cut(total_obligation, breaks = c(0, 100000, 300000, 600000, 1000000, 1500000))) 

mappopup <- paste(
  "State:",
  us_shp_1$stusps,
  "<br>",
  "Obligation",
  ":",
  us_shp_1$total_obligation_label,
  "<br>"
)

pal <- colorQuantile("Reds", domain = us_shp_1$total_obligation, na.color = "#bdbdbd")

pal <- colorNumeric(
  palette = "Reds",
  us_shp_1$total_obligation,
  na.color = "#bdbdbd"
)

us_map <- leaflet(us_shp_file) %>%
  setView(-96, 37.8, 4) %>%
  addProviderTiles(providers$CartoDB.DarkMatter)

us_map %>% 
  addPolygons(
    data = us_shp_1,
    weight = 1,
    smoothFactor = 0.5,
    color = "white",
    fillColor = pal(us_shp_1$total_obligation),
    # opacity = 1.0,
    fillOpacity = 1.5,
    highlight = highlightOptions(
      weight = 2,
      color = "#666",
      fillOpacity = 0.7,
      bringToFront = TRUE
    ),
    popup = mappopup
  ) %>% 
  addLegend("bottomright", pal = pal, values = ~ us_shp_1$total_obligation, opacity = 1, title = "Total Obligation")







