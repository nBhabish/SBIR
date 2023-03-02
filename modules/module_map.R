
map_UI <- function(id) {
  ns <- NS(id)
  tabPanel(
    title = "State Analysis",
    
    div(
      class = "container",
      id    = "header",
      h1(
        class = "page-header",
        "Federal Research and Development",
        tags$small("Spending Dashboard")
      )
    ),
    
    div(class = "container",
        id    = "application_ui",
        fluidRow(
          column(
            width = 3,
            wellPanel(
              # * Input Buttons ---------------------------------------------------------
              
              
              div(
                id = "main_input",
                pickerInput(
                  inputId = ns("picker_year_1"),
                  label   = "Year",
                  choices = unique(military_tbl_formatted$date),
                  multiple = FALSE,
                  selected = 2010,
                  option   = pickerOptions(
                    actionsBox = FALSE,
                    liveSearch = TRUE,
                    size       = 5
                  )
                ),
                pickerInput(
                  inputId = ns("picker_organization_1"),
                  label   = "Organizations",
                  choices = unique(military_tbl_formatted$organization),
                  selected = "Department of Agriculture",
                  multiple = FALSE,
                  options = pickerOptions(
                    actionsBox = FALSE,
                    liveSearch = TRUE,
                    size       = 5
                  )
                )
              ),
              
              
              # * Apply and Reset Buttons -----------------------------------------------
              
              
              div(
                id = "input_buttons",
                actionButton(
                  inputId = ns("apply"),
                  label = "Apply",
                  icon = icon("play")
                ),
                div(
                  class = "pull-right",
                  actionButton(
                    inputId = ns("reset"),
                    label = "Reset",
                    icon = icon("sync")
                  )
                )
              )
            ),
            
            br(),
            br(),
            
            div(
              class = "well",
              h4("About the SBIR"),
              id = "lorem_ipsum",
              p(
                tags$small(
                  "The Small Business Innovation Research (SBIR) programs is a competitive program that encourages small
                 businesses to engage in Federal Research/Research and Development (R/R&D) with the
                 potential for commercialization. Through a competitive awards-based program, SBIR awards
                 enable small businesses to explore their technological potential and provide the incentive to profit from its commercialization.",
                  a(
                    class = "btn btn-primary btn-sm",
                    href = "https://www.sbir.gov/about",
                    target = "_blank",
                    "Learn More"
                  )
                )
              )
            )
            
          ),
          column(width = 9,
                 div(
                   class = "panel",
                   div(
                     class = "panel-header",
                     style = "padding: 20px;",
                     h3("Spending Across States")
                   ),
                   div(
                     class = "panel-body",
                     style = "padding: 20px;",
                     leafletOutput(outputId = ns("us_map"))
                   )
                 ))
        ))
  )
}

map_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      # * Reset btn functionality -----------------------------------------------
      
      
      
      observeEvent(eventExpr = input$reset, handlerExpr = {
        
        updatePickerInput(
          session = session,
          inputId = "picker_year_1",
          selected = c("2010")
        )
        
        
        updatePickerInput(session = session,
                          inputId = "picker_organization_1",
                          selected = "Department of Agriculture")
        
        shinyjs::delay(ms = 300, expr = {
          shinyjs::click(id = "apply")
        })
        
      })
      
      
      
      
      # * Reactive output tbl after input filters -------------------------------
      
      
      
      military_reactive_tbl <-
        eventReactive(
          eventExpr = input$apply,
          valueExpr = {
            military_tbl_formatted %>%
              
              filter(date %in% input$picker_year_1) %>%
              
              filter(organization %in% input$picker_organization_1)
            
          },
          ignoreNULL = FALSE
        )
      
      # Leaflet starts here -----------------------------------------------------
      
      
      
      
      military_tbl_fitered <- eventReactive(
        eventExpr = input$apply,
        valueExpr = {
          military_tbl_formatted %>%
            filter(organization %in% input$picker_organization_1,
                   date %in% input$picker_year_1)
          
        },
        ignoreNULL = FALSE
      )
      
      
      # dataset for leaflet -----------------------------------------------------
      
      us_shp_1 <- reactive({
        us_shp_file %>%
          left_join(military_tbl_fitered(),
                    by = c("stusps" = "state")) %>%
          mutate(total_obligation_label = scales::dollar(total_obligation))
      }) 
      
      
      
      # leaflet popup -----------------------------------------------------------
      
      mappopup <- reactive({
        paste(
          "State:",
          us_shp_1()$stusps,
          "<br>",
          "Obligation",
          ":",
          us_shp_1()$total_obligation_label,
          "<br>"
        ) 
      })
      
      
      # leaflet server ----------------------------------------------------------
      
      output$us_map <- renderLeaflet({
        req(us_shp_1())
        
        pal <- colorNumeric(palette = "Reds",
                            us_shp_1()$total_obligation,
                            na.color = "#bdbdbd")
        
        leaflet(us_shp_file) %>%
          setView(-96, 37.8, 4) %>%
          addProviderTiles(providers$CartoDB.DarkMatter) %>% 
          addPolygons(
            data = us_shp_1(),
            weight = 1,
            smoothFactor = 0.5,
            color = "black",
            fillColor = pal(us_shp_1()$total_obligation),
            # opacity = 1.0,
            fillOpacity = 1.5,
            highlight = highlightOptions(
              weight = 2,
              color = "#666",
              fillOpacity = 0.7,
              bringToFront = TRUE
            ),
            # popup = mappopup(),
            label = lapply(mappopup(), HTML), 
            labelOptions = labelOptions(
              style = list("font-weight" = "normal"
                           , padding = "8px"
                           , textsize = "15px"
                           , direction = "auto")
            )
          ) %>% 
          addLegend("bottomright", 
                    pal = pal,
                    values = ~ us_shp_1()$total_obligation,
                    opacity = 1,
                    title = "Total Obligation",
                    labFormat = labelFormat(prefix = "$"))
      })
      
      
      
      # Observing leafletProxy --------------------------------------------------
      
      
      # observe({
      #   
      #   mappopup_1 <- mappopup()
      #   
      #   pal_1 <- pal_reactive()
      #   
      #   leafletProxy("us_map") %>%s
      #       data = us_shp_1(),
      #       weight = 1,
      #       smoothFactor = 0.5,
      #       color = "white",
      #       fillColor = pal_1(),
      #       # opacity = 1.0,
      #       fillOpacity = 1.5,
      #       highlight = highlightOptions(
      #         weight = 2,
      #         color = "#666",
      #         fillOpacity = 0.7,
      #         bringToFront = TRUE
      #       ),
      #       popup = mappopup()
      #     ) 
      # })
      # 
      # leaflet ends here -------------------------------------------------------

    }
  )
}










### Server





