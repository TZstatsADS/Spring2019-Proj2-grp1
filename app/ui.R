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