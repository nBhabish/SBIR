
# UI ----------------------------------------------------------------------



plots_UI <- function(id) {
  ns <- NS(id)
  # Tab Panel 2 -------------------------------------------------------------
  
  
  tabPanel(
    div(
      class = "container",
      id    = "header",
      h1(
        class = "page-header",
        "Federal Research and Development",
        tags$small("Spending Dashboard")
      )
    ),
    
    title = "Insights on Phase Awards",
    
    
    
    # * Input Buttons ---------------------------------------------------------
    
    
    div(class = "container",
        id    = "application_ui",
        fluidRow(
          column(
            width = 3,
            wellPanel(div(
              id = "main_input",
              pickerInput(
                inputId = ns("picker_year_2"),
                label   = "Year",
                choices = unique(military_tbl_formatted$date),
                multiple = TRUE,
                selected = 2010,
                option   = pickerOptions(
                  actionsBox = FALSE,
                  liveSearch = TRUE,
                  size       = 5
                )
              ),
              
              
              # * Apply and Reset Buttons -----------------------------------------------
              
              
              div(
                actionButton(
                  inputId = ns("apply_1"),
                  label = "Apply",
                  icon = icon("play")
                ),
                div(
                  class = "pull-right",
                  actionButton(
                    inputId = ns("reset_1"),
                    label = "Reset",
                    icon = icon("sync")
                  )
                )
              )
            )),
            
            
            
            # * Line Breaks -----------------------------------------------------------
            
            
            
            
            br(),
            br(),
            
            
            
            # * About The Project Panel-Box -------------------------------------------
            
            
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
                     class = "panel-body",
                     style = "padding: 20px;",
                     tabsetPanel(
                       type = "pills",
                       
                       tabPanel(title = "Phase One Awards",
                                plotlyOutput(outputId = ns("plotly_phase_1"))),
                       
                       tabPanel(title = "Phase Two Awards",
                                plotlyOutput(outputId = ns("plotly_phase_2")))
                     )
                   )
                   
                 ))
        ))
  )
}

plots_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      # * Reset btn functionality -----------------------------------------------
      
      observeEvent(eventExpr = input$reset_1, handlerExpr = {
        updatePickerInput(session = session,
                          inputId = "picker_year_2",
                          selected = 2010)
        
        shinyjs::delay(ms = 100, expr = {
          shinyjs::click(id = "apply_1")
        })
        
      })
      
      
      # * Reactive output for phase plots ---------------------------------------
      
      
      
      military_phase_plots <-
        eventReactive(
          eventExpr = input$apply_1,
          valueExpr = {
            military_tbl_formatted %>%
              mutate(date = as.factor(date)) %>%
              filter(date %in% input$picker_year_2)
            
          },
          ignoreNULL = FALSE
        ) 
      
      
      # * Phase Plot 1 ----------------------------------------------------------
      
      
      
      output$plotly_phase_1 <- renderPlotly({
        g1 <- military_phase_plots() %>%
          group_by(date, organization) %>%
          summarise(total_phase_one_obligation = sum(total_phase_one_obligation)) %>%
          ungroup() %>%
          mutate(
            label_text = str_glue(
              "Year: {date}
                                Organization: {organization}
                                Awards: {scales::dollar(total_phase_one_obligation)}"
            )
          ) %>%
          ggplot(aes(organization, total_phase_one_obligation, fill = date)) +
          geom_col(position = position_dodge(preserve = "single"), aes(text = label_text)) +
          coord_flip() +
          theme_minimal() +
          labs(x = "",
               y = "",
               fill = "") +
          scale_y_continuous(labels = scales::dollar_format(
            scale = 1e-6,
            accuracy = 1,
            prefix = "$",
            suffix = "M"
          ))
        
        
        ggplotly(g1, tooltip = "text") %>%
          reverse_legend_labels()
        
      })
      
      
      # * Phase Plot 2 ----------------------------------------------------------
      
      
      
      output$plotly_phase_2 <- renderPlotly({
        g2 <- military_phase_plots() %>%
          group_by(date, organization) %>%
          summarise(total_phase_two_obligation = sum(total_phase_two_obligation)) %>%
          ungroup() %>%
          mutate(
            label_text = str_glue(
              "Year: {date}
                               Organization: {organization}
                               Awards: {scales::dollar(total_phase_two_obligation)}"
            )
          ) %>%
          ggplot(aes(organization, total_phase_two_obligation, fill = date)) +
          geom_col(position = position_dodge(preserve = "single"), aes(text = label_text)) +
          coord_flip() +
          theme_minimal() +
          labs(x = "",
               y = "",
               fill = "") +
          scale_y_continuous(labels = scales::dollar_format(
            scale = 1e-6,
            accuracy = 1,
            prefix = "$",
            suffix = "M"
          ))
        
        ggplotly(g2, tooltip = "text") %>%
          reverse_legend_labels()
        
      })
    }
  )
}








