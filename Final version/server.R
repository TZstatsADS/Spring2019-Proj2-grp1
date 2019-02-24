# Packages and functions are all in "Global.R"

#setwd("../") # set file path

server <- function(input, output,session) { 
  
  
  # Home Page
  dynamicdata = fread("pickupDropoff date_hour.csv", header = TRUE, stringsAsFactors=F)

  observeEvent(input$bu,{
    updateNavbarPage(session = session,"nav", selected = "b")
  })
  observeEvent(input$invest,{
    updateNavbarPage(session = session,"nav", selected = "c")
  })

  output$map_home<- renderLeaflet({
    leaflet() %>%
      setView(lat=40.7128, lng=-73.9759, zoom=13) %>%
      addProviderTiles('CartoDB.Positron',options = providerTileOptions(minZoom = 13, maxZoom = 15))
  })

  drawvalue <- reactive({
    t <- filter(dynamicdata, pickup_hour == input$hours)
    return(t)
  })

  observe({
    radius <-  100
    t <- filter(dynamicdata, pickup_hour == input$hours)
    leafletProxy("map_home", data = t) %>%
      clearShapes() %>%
      addCircles(~pickup_longitude, ~pickup_latitude, radius=radius,
                 stroke=FALSE, fillOpacity=0.5,fillColor = "#DE90F1")
  })

  
  
  
  
  # Bike uer page
  # The base map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiZnJhcG9sZW9uIiwiYSI6ImNpa3Q0cXB5bTAwMXh2Zm0zczY1YTNkd2IifQ.rjnjTyXhXymaeYG6r2pclQ",
        options = providerTileOptions(minZoom = 13, maxZoom = 15),
        ## Limited using for url in next line
        ## urlTemplate = "https://api.mapbox.com/styles/v1/zy2327/cjs9914pc2grv1fphffp1vt85/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoienkyMzI3IiwiYSI6ImNqczk4ejQxejB0ZnE0NGxvZnAwMHZyMzQifQ.rut7SSkplUDV2URP5nItrw",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -73.9759, lat = 40.7410,zoom=13)
  }) 
  
  # Weather condition
  current_nyc_weather <- readLines("https://api.openweathermap.org/data/2.5/weather?id=5128581&APPID=b466e19b342ce7053c55554701fd0d86")%>%
    RJSONIO::fromJSON(nullValue = NA)
  
  output$temperature <- renderText({
    paste0("Current temperature: ",as.character(round(current_nyc_weather$main[1]-273.15))," °C") })
  
  output$weather_condition <- renderText({
    paste0("Current weather condition: ",current_nyc_weather[["weather"]][[1]][["description"]])
  })
  
  
  # Add dots to map
  observe({
    ## Re-execute this reactive expression every minute
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
                       radius = ~2.75,
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
                 
                 ## Get refreshed data
                 real.time.data <- real_time_data()
                 
                 ## Use function to get available stations
                 nearest.available.stations <- nearest_available_stations(input$input_start_point,input$input_end_point,real.time.data)
                 ## If there's no avilable station, prompt a message
                 if(nrow(nearest.available.stations$start)==0)
                 {
                   session = getDefaultReactiveDomain()
                   session$sendCustomMessage(type = 'testmessage',
                                             message = 'No avilable station near start location. Please change the start location.')
                 }
                 else if(nrow(nearest.available.stations$end)==0)
                 {
                   session = getDefaultReactiveDomain()
                   session$sendCustomMessage(type = 'testmessage',
                                             message = 'No available station near end location. Please change the end location.')
                 }
                 ## Mark start/end station on the map
                 ## Define the final_start_point and final_end_point for drawing the routes
                 else
                 {
                   
                   ## This is a vector containing two elements: lng and lat
                   final_start_point <- c(nearest.available.stations$start$lon,nearest.available.stations$start$lat)
                   
                   ## Build icons
                   icon.start <- makeAwesomeIcon(icon = "home", markerColor = "green",
                                                 library = "ion")
                   icon.end <- makeAwesomeIcon(icon = "flag", markerColor = "blue", library = "fa",
                                               iconColor = "#ffffff")
                   
                   ## Plot the icons to the map
                   leafletProxy("map")%>%
                     removeMarker(layerId = "a")%>%
                     ### start station
                     addAwesomeMarkers(lng=nearest.available.stations$start$lon,
                                       lat=nearest.available.stations$start$lat,
                                       label=nearest.available.stations$start$name,
                                       icon=icon.start,
                                       layerId = "a")
                   
                   if(input$input_checkbox == TRUE)
                   {
                     nearest.available.stations$end <- nearest.available.stations$end%>%
                       arrange(num_bikes_available)%>%
                       head(1)
                   }
                   else
                   {
                     nearest.available.stations$end <- nearest.available.stations$end%>%
                       head(1)
                   }
                   output$nrows <- reactive({
                     min(nrow(nearest.available.stations$start),nrow(nearest.available.stations$end))
                   })
                   outputOptions(output, "nrows", suspendWhenHidden=FALSE)
                   ## This is a vector containing two elements: lng and lat
                   final_end_point <- c(nearest.available.stations$end$lon,nearest.available.stations$end$lat)
                   ### End station
                   leafletProxy("map")%>%
                     removeMarker(layerId = "b")%>%
                     addAwesomeMarkers(lng=nearest.available.stations$end$lon,
                                       lat=nearest.available.stations$end$lat,
                                       label=nearest.available.stations$end$name,
                                       icon=icon.end,
                                       layerId = "b")
                   ## add the nearest route to the map from the start point to the end 
                   
                   key <-"AIzaSyC2rGN5ZbV-21zklpgVGnsV-WfdQnNALjk"
                   wed_add<-sprintf("https://maps.googleapis.com/maps/api/distancematrix/json?origins=%s,%s&destinations=%s,%s&mode=bicycling&key=%s",nearest.available.stations$start$lat,nearest.available.stations$start$lon,nearest.available.stations$end$lat,nearest.available.stations$end$lon,key)
                   Route<-fromJSON(wed_add,simplify = FALSE)
                   Distances<-Route$rows[[1]]$elements[[1]]$distance$text
                   Times<-Route$rows[[1]]$elements[[1]]$duration$text
                   output$distances<-renderText({
                     paste0("Distance: ",Distances)})
                   output$times<-renderText({
                     paste0("Estimated Time: ",Times)})
                 }
               },
               ignoreNULL = TRUE)
  
}


