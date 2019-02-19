# Loading packages
library(leaflet)
library(rjson)
library(RJSONIO)
library(tidyverse)
library(sp)
library(shinydashboard)
library(htmltools)
library(ggmap)
library(geosphere)
library(googleway)

# The following is a function named 'real_time_data' that collects the real time data
# Every time being called, it returns a list of tables
# Data Scource: http://gbfs.citibikenyc.com/gbfs/gbfs.json

real_time_data <- function(){
  # setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
  
  # Create an empty list that returns data
  return_data <- list()
  
  # Station
  ## station_information
  station_information <- readLines("https://gbfs.citibikenyc.com/gbfs/en/station_information.json")%>%
    RJSONIO::fromJSON(nullValue = NA)
  
  Last_updated_time <- station_information$last_updated%>%
    as.POSIXct(origin="1970-01-01")%>%
    as.character.Date()
  
  columns_wanted <- c("station_id","name","lat","lon")
  
  station_information_data <- station_information$data$stations%>%
    sapply(function(x) x[columns_wanted])%>%
    unlist()%>%
    matrix(., nrow=length(columns_wanted))%>%
    t()%>%
    as.data.frame()
  
  colnames(station_information_data) <- columns_wanted
  
  ## station_status
  station_status <- readLines("https://gbfs.citibikenyc.com/gbfs/en/station_status.json")%>%
    RJSONIO::fromJSON(nullValue = NA)
  
  Last_updated_time <- station_status$last_updated%>%
    as.POSIXct(origin="1970-01-01")%>%
    as.character.Date()
  
  columns_wanted <- c("station_id","num_bikes_available","num_docks_available","is_installed","is_renting","is_returning","last_reported")
  
  station_status_data <- station_status$data$stations%>%
    sapply(function(x) x[columns_wanted])%>%
    unlist()%>%
    matrix(., nrow=length(columns_wanted))%>%
    t()%>%
    as.data.frame()
  
  colnames(station_status_data) <- columns_wanted
  
  ## Joint info of stations
  
  station_joint_data <- station_information_data%>%
    inner_join(station_status_data,by = "station_id")
  
  station_joint_data$lat <- as.numeric(as.character(station_joint_data$lat))
  station_joint_data$lon <- as.numeric(as.character(station_joint_data$lon))
  station_joint_data$num_bikes_available <- as.numeric(as.character(station_joint_data$num_bikes_available))
  station_joint_data$num_docks_available <- as.numeric(as.character(station_joint_data$num_docks_available))
  
  ## Add a column "available_status"
  ## num_bikes_available <= 1      Few
  ##                     (1,3]     Plenty 
  ##                     >3        Abundant
  station_joint_data <- station_joint_data%>%
    mutate(available_status=case_when(
      num_bikes_available <= 1 ~ "#eb3323",
      num_bikes_available > 1 & num_bikes_available <=3 ~ "#ffad47",
      num_bikes_available > 3 ~ "#4ec42b"
    ))

  return_data$station <- station_joint_data
  return_data$update_time <- Last_updated_time
  return(return_data)
}

# The following function returns the nearest available stations
# The return value is a list of two elements
# Each elements contains 5 columns: name, lat, lon, dist, bonus
nearest_available_stations <- function(input_start,input_end)
{
  ## !!! limited using google account api
  register_google(key = "AIzaSyC2rGN5ZbV-21zklpgVGnsV-WfdQnNALjk")
  
  ## Get geo_coding
  start_point <- geocode(input$input_start_point)
  end_point <- geocode(input$input_end_point)
  
  # Determine whether there are avilable station that within 1 km from the start point and end point
  available_start_point <- real.time.data$station %>%
    filter(num_bikes_available>0)%>% # Filter stations that have avilable bikes
    mutate(dist=as.vector(distm(cbind(lon,lat), start_point, fun =distGeo)))%>%
    mutate(bonus=0)%>%
    filter(dist<=1000)%>%
    select(name,lat,lon,dist,bonus)%>%
    arrange((dist))%>%
    head(3)
  
  available_end_point <- real.time.data$station %>%
    filter(num_docks_available>0)%>% # Filter stations that have avilable bikes
    mutate(dist=as.vector(distm(cbind(lon,lat), end_point, fun =distGeo)))%>%
    mutate(bonus=case_when(
      num_bikes_available <=3 ~ 1,
      TRUE ~ 0
    ))%>%
    filter(dist<=1000)%>%
    select(name,lat,lon,dist,bonus)%>%
    arrange((dist))%>%
    head(3)
  
  result <- list()
  result$start <- available_start_point
  result$end <- available_end_point
  return(result)
  
}