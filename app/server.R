# Packages and functions are all in "Global.R"

server <- function(input, output) {
  # The base map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiZnJhcG9sZW9uIiwiYSI6ImNpa3Q0cXB5bTAwMXh2Zm0zczY1YTNkd2IifQ.rjnjTyXhXymaeYG6r2pclQ",
        ## Limited using for url in next line
        ## urlTemplate = "https://api.mapbox.com/styles/v1/zy2327/cjs9914pc2grv1fphffp1vt85/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoienkyMzI3IiwiYSI6ImNqczk4ejQxejB0ZnE0NGxvZnAwMHZyMzQifQ.rut7SSkplUDV2URP5nItrw",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -73.9759, lat = 40.7410, zoom = 13)
      
  }) 

  # Add dots to map
  observe({
    ## Re-execute this reactive expression after 1 minute
    invalidateLater(60000, session = getDefaultReactiveDomain())
    
    ## Refresh the data
    real.time.data <- real_time_data()
    
    ## Popup content
    station_popup_info <- real.time.data$station %>%
      transmute(popup_info=paste0(
        "<font size=\"3.5\" color=\"#0f6dc4\"><b>",name,"</b></font><br/>",
        "<font size=\"2.5\" color=\"#2b3442\">Avail Bike: ",as.character(num_bikes_available),"</font><br/>",
        "<font size=\"2.5\" color=\"#2b3442\">Avail Dock: ",as.character(num_docks_available),"</font><br/>"
      ))
    station_popup_info <- lapply(seq(nrow(station_popup_info)), function(i) {
      station_popup_info[i,]
    })
    
    ## Adding dots and popup
    leafletProxy("map")%>%
      clearMarkers()%>%
      addCircleMarkers(data=real.time.data$station,
                       lng=real.time.data$station$lon,
                       lat=real.time.data$station$lat,
                       color = real.time.data$station$available_status,
                       radius = ~2.5,
                       #radius = ~(real.time.data$station$num_bikes_available/10),
                       stroke = FALSE, 
                       fillOpacity = 0.8,
                       label = lapply(station_popup_info, HTML)
                       )
    #addMarkers(data=real.time.data$station,lng=real.time.data$station$lon,lat=real.time.data$station$lat)
    
    ## Add text of last updated time
    Last_update_time <- reactiveValues(update_time = real.time.data$update_time)
    output$update_time_Box <-renderText({
      Last_update_time$update_time })
  })
  
  # Return nearest available stations
  ## Text input id: input_start_point,input_end_point
  observeEvent(input$input_go,
               {
                 ## Use function to get available stations
                 nearest.available.stations <- nearest_available_stations(input$input_start_point,input$input_end_point)
                 
                 ## If there's no avilable station, prompt a message
                 if(nrow(nearest.available.stations$start)==0)
                  {
                    session = getDefaultReactiveDomain()
                    session$sendCustomMessage(type = 'testmessage',
                                              message = 'No avilable station near start location. Please change the start location.')
                  }
                 else if((nrow(nearest.available.stations$end)+nrow(nearest.available.stations$bonus))==0)
                  {
                   session = getDefaultReactiveDomain()
                   session$sendCustomMessage(type = 'testmessage',
                                             message = 'No avilable station near end location. Please change the end location.')
                  }
                 else
                  {
                    ## Build icons
                    icon.start <- makeAwesomeIcon(icon = "home", markerColor = "green",
                                                library = "ion")
                    icon.end <- makeAwesomeIcon(icon = "flag", markerColor = "blue", library = "fa",
                                                  iconColor = "#ffffff")
                    icon.bonus <- makeAwesomeIcon(icon = "flag", markerColor = "blue", library = "fa",
                                                iconColor = "#ff9400")
                    
                    ## Plot the icons to the map
                    leafletProxy("map")%>%
                      addAwesomeMarkers(lng=nearest.available.stations$start$lon,
                                        lat=nearest.available.stations$start$lat,
                                        label=nearest.available.stations$start$name,
                                        icon=icon.start)%>%
                      addAwesomeMarkers(lng=nearest.available.stations$end$lon,
                                        lat=nearest.available.stations$end$lat,
                                        label=nearest.available.stations$end$name,
                                        icon=icon.end)%>%
                      addAwesomeMarkers(lng=nearest.available.stations$bonus$lon,
                                        lat=nearest.available.stations$bonus$lat,
                                        label=nearest.available.stations$bonus$name,
                                        icon=icon.bonus)
                  }
               },
               ignoreNULL = TRUE)

}