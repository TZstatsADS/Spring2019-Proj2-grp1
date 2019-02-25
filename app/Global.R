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
library(shinyBS)
library(data.table)
library(shiny)
library(rgdal)
library(tigris)
library(dplyr)
library(tidyr)
library(DT)

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
    ))%>%
    mutate(available_bike_percentage=num_bikes_available/(num_docks_available+num_bikes_available))

  return_data$station <- station_joint_data
  return_data$update_time <- Last_updated_time
  return(return_data)
}

# The following function returns the nearest available stations
# The return value is a list of two elements: start, end
# Each elements contains 5 columns: name, lat, lon, dist, num
nearest_available_stations <- function(input_start,input_end,data)
{
  result <- list()
  ## !!! limited using google account api
  register_google(key = "AIzaSyC2rGN5ZbV-21zklpgVGnsV-WfdQnNALjk")
  
  ## Get geo_coding
  if(substr(input_start,ifelse(nchar(input_start)-19>0,nchar(input_start)-19,1),nchar(input_start)) != ", New York, NY, USA")
  {
    input_start <- paste0(input_start,", New York, NY, USA")
  }
  
  if(substr(input_end,ifelse(nchar(input_end)-19>0,nchar(input_end)-19,1),nchar(input_end)) != ", New York, NY, USA")
  {
    input_end <- paste0(input_end,", New York, NY, USA")
  }
  
  start_point <- geocode(input_start)
  end_point <- geocode(input_end)
  
  result$input_start <- start_point
  result$input_end <- end_point
  
  # Determine whether there are avilable station that within 1 km from the start point and end point
  available_start_point <- data$station %>%
    filter(num_bikes_available>0)%>% # Filter stations that have avilable bikes
    mutate(dist=as.vector(distm(cbind(lon,lat), start_point, fun =distGeo)))%>%
    filter(dist<=1000)%>%
    select(name,lat,lon,dist,num_bikes_available)%>%
    arrange((dist))%>%
    head(1)
  
  available_end_point <- data$station %>%
    filter(num_docks_available>0)%>% # Filter stations that have avilable bikes
    mutate(dist=as.vector(distm(cbind(lon,lat), end_point, fun =distGeo)))%>%
    filter(dist<=1000)%>%
    arrange((dist))%>%
    select(name,lat,lon,dist,num_bikes_available)

  
  result$start <- available_start_point
  result$end <- available_end_point
  return(result)
}

# 
#download the shapefile of related counties in NY and NJ
county <- c("New York","Kings", "Queens")
state <- c(rep("NY", 3), "NJ")
nj_shapefile <- tracts("NJ", "Hudson", cb = TRUE)
ny_shapefile = lapply(county, function(x) tracts(state = 'NY', county = county, cb = T))
nynj_shapefile = rbind_tigris(append(ny_shapefile, nj_shapefile))

#convert coordinates to geocode
#geocode <- apply(station_popularity, 1, function(row) call_geolocator_latlon(row['station.latitude'], row['station.longitude']))
#tract <- substr(geocode, 1, 11) #find the 6-digit tract code

#match station with tract
#station_popularity_tract <- cbind(station_popularity, tract = tract)

station_popularity_tract <- read.csv("popularity_data_tract.csv")
#calculate the average usage for stations in each tract
tract_ave <- station_popularity_tract %>% 
  group_by(tract) %>% 
  summarise(average_usage = round(mean(total_count),0), num_station = n()) %>% 
  mutate(geocode = tract) %>% 
  separate(tract, into = c('state', 'county', 'tract'), sep = c(2,5)) 

#merge the station by tract data frame with the shapefile
df_merged <- geo_join(nynj_shapefile, tract_ave, "GEOID", "geocode")
df_merged$average_usage = ifelse(is.na(df_merged$average_usage), 0, df_merged$average_usage)
df_merged$num_station = ifelse(is.na(df_merged$num_station), 0, df_merged$num_station)

#choose the palette
pal2 <- colorNumeric(
  palette = "RdYlBu",
  domain = c(min(df_merged$average_usage,na.rm = T), max(df_merged$average_usage,na.rm = T)),reverse = T
)

#show a list of station 
tract_ave$state <- ifelse(tract_ave$state == 34, "NJ", "NY")
tract_ave$county <- as.factor(tract_ave$county)
levels(tract_ave$county) <- c("Bronx", "Hudson", "Brooklyn", "Manhattan", "Queens")
list <- tract_ave[, -6] %>% arrange(desc(average_usage))

