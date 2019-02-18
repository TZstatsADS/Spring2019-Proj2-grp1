# Define UI for app that draws a histogram ----
library(leaflet)
ui <- fluidPage(
  leafletOutput("map", width="100%", height=750),
  infoBoxOutput("update_time_Box"),
  textInput("input_start_point",label="start"),
  textInput("input_end_point",label="end"),
  actionButton("submit",label="submit")
)