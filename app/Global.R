# Loading packages
library(rjson)
library(RJSONIO)
library(tidyverse)
library(sp)


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
  ## avilable_bike:(avilable_bike+avilable_dock) <= 35%       Few
  ##                                             (35%,70%]    Plenty 
  ##                                             >70%         Abundant
  station_joint_data <- station_joint_data%>%
    mutate(available_bike_percentage=num_bikes_available/(num_docks_available+num_bikes_available))%>%
    mutate(available_status=case_when(
      available_bike_percentage <= 0.35 ~ "Few",
      available_bike_percentage > 0.35 & available_bike_percentage <=0.7 ~ "Plenty",
      available_bike_percentage > 0.7 ~ "Abundant"
    ))
  
  
  # write.csv(station_joint_data,file ="./station.csv", row.names=FALSE)
  return_data$station <- station_joint_data
  return(return_data)
}