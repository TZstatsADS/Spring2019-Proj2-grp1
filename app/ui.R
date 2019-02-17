# Define UI for app that draws a histogram ----
library(leaflet)
ui <- fluidPage(
  leafletOutput("map", width="100%", height=800)
  
)