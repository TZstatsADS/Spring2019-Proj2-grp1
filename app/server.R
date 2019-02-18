# Packages and functions are all in "Global.R"

server <- function(input, output) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiZnJhcG9sZW9uIiwiYSI6ImNpa3Q0cXB5bTAwMXh2Zm0zczY1YTNkd2IifQ.rjnjTyXhXymaeYG6r2pclQ",
        # Limited using for url in next line
        # urlTemplate = "https://api.mapbox.com/styles/v1/zy2327/cjs9914pc2grv1fphffp1vt85/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoienkyMzI3IiwiYSI6ImNqczk4ejQxejB0ZnE0NGxvZnAwMHZyMzQifQ.rut7SSkplUDV2URP5nItrw",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -73.9759, lat = 40.7410, zoom = 13)
  }) 
  
  real.time.data <- real_time_data()
  station_color <- colorFactor(c("#eb3323","#ffad47","#4ec42b"), domain = c("Few", "Plenty","Abundant"))
  
  leafletProxy("map")%>%
    addCircleMarkers(data=real.time.data$station,
                     lng=real.time.data$station$lon,
                     lat=real.time.data$station$lat,
                     color = ~station_color(real.time.data$station$available_status),
                     radius = ~4,
                     #radius = ~(real.time.data$station$num_bikes_available/10),
                     stroke = FALSE, fillOpacity = 0.8)
    #addMarkers(data=real.time.data$station,lng=real.time.data$station$lon,lat=real.time.data$station$lat)
  
  Last_update_time <- reactiveValues(update_time = real.time.data$update_time)
  
  observe({
  output$update_time_Box <- renderInfoBox({
    infoBox("Last updated time: ", Last_update_time$update_time)})
  })
  
}