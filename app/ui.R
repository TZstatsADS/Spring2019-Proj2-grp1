<<<<<<< HEAD
# Define UI for app that draws a histogram ----
library(leaflet)
ui <- bootstrapPage(
  tags$style(type="text/css","html,body{width:100%;height:100%}"),
  leafletOutput("map", width="100%", height="100%"),
  absolutePanel(bottom=10,left=10,width="25%",
  tags$h6("Last Update Time:"),             
  textOutput("update_time_Box")                  
  )
)
=======
# Define UI for app

ui <- bootstrapPage(
  tags$style(type="text/css","html,body{width:100%;height:100%}"),
  leafletOutput("map", width="100%", height=750),
  infoBoxOutput("update_time_Box"),
  includeCSS("styles.css"),
  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                draggable = TRUE, top = 60, left = "auto", right = 18, bottom = "auto",
                width = 300, height = 300, 
                h4("Citi Bike Route",align = "center"),
                
                fluidRow(
                  column(10, offset = 1,
                         textInput(inputId = "input_start_point", label = "Start Point", value = "Enter your location"),
                         textInput(inputId = "input_end_point", label = "End Point", value = "Enter your destination"),
                         checkboxInput(inputId="input_checkbox",label = "Could you please do us a favor?", value = FALSE),
                         actionButton(inputId = "input_go", label = "Let's Go!")
))))
>>>>>>> c28939cd955bee6f4a8ed1145fadf980c141fd5d