# Packages and functions are all in "Global.R"

#setwd("../") # set file path

server <- function(input, output,session) { 
  
  
  # Home Page
  dynamicdata = fread("Final.V.csv", header = TRUE, stringsAsFactors=F)

  observeEvent(input$bu,{
    updateNavbarPage(session = session,"nav", selected = "b")
  })
  observeEvent(input$invest,{
    updateNavbarPage(session = session,"nav", selected = "c")
  })

  output$map_home<- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.DarkMatter,options = providerTileOptions(minZoom = 10, maxZoom = 15))%>%
      setView(lat=40.75, lng=-73.9759, zoom=12)
  })
  
  drawvalue <- reactive({
    t <- filter(dynamicdata, pickup_hour == input$hours)
    return(t)
  })
  
  col_pal<-colorNumeric(
    palette = 'YlOrRd',
    domain = c(log(1),log(142))
  )
  
  observe({
    
    radius <-  100
    t <- filter(dynamicdata, pickup_hour == input$hours)
    
    leafletProxy("map_home", data = t) %>%
      clearShapes() %>%
      addCircles(~lon, ~lat, radius=radius,
                 stroke=FALSE, fillOpacity=0.9,fillColor = ~col_pal(log(N)))
  })
  
  
  
  # Bike user
  
  # Add dots to map for the first time
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
  
  # The base map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        ## urlTemplate = "https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiZnJhcG9sZW9uIiwiYSI6ImNpa3Q0cXB5bTAwMXh2Zm0zczY1YTNkd2IifQ.rjnjTyXhXymaeYG6r2pclQ",
        options = providerTileOptions(minZoom = 8, maxZoom = 15),
        urlTemplate = "https://api.mapbox.com/styles/v1/zy2327/cjs9914pc2grv1fphffp1vt85/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoienkyMzI3IiwiYSI6ImNqczk4ejQxejB0ZnE0NGxvZnAwMHZyMzQifQ.rut7SSkplUDV2URP5nItrw",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      addCircleMarkers(data=real.time.data$station,
                       lng=real.time.data$station$lon,
                       lat=real.time.data$station$lat,
                       color = real.time.data$station$available_status,
                       radius = ~2.75,
                       #radius = ~(real.time.data$station$num_bikes_available/10),
                       stroke = FALSE, 
                       fillOpacity = 0.8,
                       label = lapply(station_popup_info, HTML)
      )%>%
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
    # Last_update_time <- reactiveValues(update_time = real.time.data$update_time)
    # output$update_time_Box <-renderText({
    #   Last_update_time$update_time })
    
    output$update_time_Box <-renderText({
      as.character(Sys.time()) })
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
                   
                   ## Email
                   ## email<-data.frame(address=input$enter_email)
                   ## write_csv(email,"/Users/mac/Documents/GitHub/Spring2019-Proj2-grp1/data/Users_email.csv",append = TRUE)
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
  
  #for business
  #nearly empty station
    ## Refresh the data
    real_time_station_few <- real_time_data()$station %>%
      filter(available_bike_percentage <= 0.1)
    
    
    #a list of stations which is nearly empty
    near_empty_stat_list <- real_time_station_few %>% 
      arrange(available_bike_percentage) %>% 
      select(station_id, name, num_bikes_available, available_bike_percentage)
    
    pal <- colorNumeric(
      palette = "RdYlBu",
      domain = c(0, 10)
    )
    
    ## Popup content
    empty_station_popup_info <- real_time_station_few %>%
      transmute(popup_info=paste0(
        "<font size=\"3.5\" color=\"#0f6dc4\"><b>",name,"</b></font><br/>",
        "<font size=\"2.5\" color=\"#2b3442\">Avail Bike: ",as.character(num_bikes_available),"</font><br/>",
        "<font size=\"2.5\" color=\"#2b3442\">Station ID: ",as.character(station_id),"</font><br/>"
      ))
    empty_station_popup_info <- lapply(seq(nrow(empty_station_popup_info)), function(i) {
      empty_station_popup_info[i,]
    })
  
  
  output$emptymap <- renderLeaflet({
    leaflet(data = real_time_station_few) %>%
      addTiles(
        ##urlTemplate = "https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiZnJhcG9sZW9uIiwiYSI6ImNpa3Q0cXB5bTAwMXh2Zm0zczY1YTNkd2IifQ.rjnjTyXhXymaeYG6r2pclQ",
        urlTemplate = "https://api.mapbox.com/styles/v1/zy2327/cjs9914pc2grv1fphffp1vt85/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoienkyMzI3IiwiYSI6ImNqczk4ejQxejB0ZnE0NGxvZnAwMHZyMzQifQ.rut7SSkplUDV2URP5nItrw",
        attribution = 'Maps by <a href=" ">Mapbox</a >'
      ) %>%
      setView(lng = -73.9759, lat = 40.7410, zoom = 13)%>%
      addCircleMarkers(~lon, ~lat,
                       popup = ~paste0("ID: ", station_id, '<br>', "Name: ", name, '<br>', "Bike Left: ", num_bikes_available), 
                       color = ~pal(num_bikes_available),
                       radius = ~5, 
                       opacity = 0.6,
                       options = popupOptions(closeButton = T),
                       label = lapply(empty_station_popup_info, HTML)
      ) %>%
      addLegend("topleft",pal = pal, values = ~num_bikes_available,
                title = "Number of bikes avail",
                opacity = 1)
  })
  
  output$emptylist<- DT::renderDataTable({near_empty_stat_list})
  output$text1 <- renderText({
    paste0("This map would help you to figure out station that is running out of bikes.") })
  #popular station by tract
  
  #popup labels
  labs <- lapply(seq(length(df_merged$TRACTCE)), function(i) {
    paste0("Tract No.: ", df_merged$TRACTCE[i],
           "<br> Average Usage/month: ", df_merged$average_usage[i], 
           "<br>", "Number of station: ", df_merged$num_station[i]) 
  })

  
  
  # popular station
  output$popstation <- renderLeaflet({
    leaflet(df_merged) %>%
      addTiles() %>%
      setView(lng = -73.9759, lat = 40.7410, zoom = 13) %>%
      addPolygons(fillColor = ~pal2(average_usage), 
                  opacity = 0.1, 
                  weight = 1,
                  label = lapply(labs, HTML)
      )%>%
      addLegend("topleft", pal = pal2, values = ~average_usage,
                title = "Station Popularity by Tract",
                opacity = 1)
  })
  
  output$text2 <- renderText({
    paste0("You may think of making advertisement at popular stations or invest in establishing a new station. This map would help you to figure out station popularity in each census tract.") })
  
  output$poplist <- DT::renderDataTable({
    data = list
    if (input$state != "All") {
      data <- data[data$state == input$state,]
    }
    if (input$county != "All") {
      data <- data[data$county == input$county,]
    }
    if (input$num_station != "All") {
      data <- data[data$num_station == input$num_station,]
    }
    data
  })
  
  
  
}