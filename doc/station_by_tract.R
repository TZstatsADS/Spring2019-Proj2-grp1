library(tigris)
library(leaflet)
library(dplyr)
library(tidyr)

setwd("/Users/yujiewang/Google Drive (yw3285@columbia.edu)/Spring2019-Proj2-grp1/doc")
nycdata <- read.csv("../data/201901-citibike-tripdata.csv", stringsAsFactors = FALSE)
jcdata <- read.csv("../data/JC-201901-citibike-tripdata.csv", stringsAsFactors = FALSE)
data <- rbind(nycdata, jcdata)
start_count = data %>% 
  group_by(start.station.name) %>%
  summarise(s.count = n()) %>% 
  arrange(desc(s.count))
end_count = data %>% group_by(end.station.name) %>% 
  summarise(e.count = n()) %>% 
  arrange(desc(e.count))

total_count = start_count %>% 
  inner_join(end_count, by = c("start.station.name" = "end.station.name")) %>%
  mutate(total_count = s.count + e.count) %>% 
  arrange(desc(total_count)) %>% select(start.station.name, total_count)

popularity_data = data %>%
  select(start.station.id, start.station.name, start.station.latitude, start.station.longitude)%>%
  distinct(start.station.name, .keep_all = TRUE) %>% 
  right_join(total_count, by = "start.station.name")                       

colnames(popularity_data) <- c("station.id", "station.name", "station.latitude", "station.longitude", "total_count")

#write_csv(popularity_data, path = "../output/popularity_data.csv")

#download the shapefile of related counties in NY and NJ
county <- c("New York","Kings", "Queens")
state <- c(rep("NY", 3), "NJ")
nj_shapefile <- tracts("NJ", "Hudson", cb = TRUE)
ny_shapefile = lapply(county, function(x) tracts(state = 'NY', county = county, cb = T))
nynj_shapefile = rbind_tigris(append(ny_shapefile, nj_shapefile))

#convert coordinates to geocode
read.csv("station_popularity.csv")
geocode <- apply(station_popularity, 1, function(row) call_geolocator_latlon(row['station.latitude'], row['station.longitude']))
tract <- substr(geocode, 1, 11) #find the 6-digit tract code

#match station with tract
station_popularity_tract <- cbind(station_popularity, tract = tract)
#write.csv(station_popularity_tract, "/Users/yujiewang/Google Drive (yw3285@columbia.edu)/Spring2019-Proj2-grp1/output/popularity_data_tract.csv")

#calculate the average usage for stations in each tract
tract_ave <- station_popularity_tract %>% 
  group_by(tract) %>% 
  summarise(ave_count = round(mean(total_count),0), num_station = n()) %>% 
  mutate(geocode = tract) %>% 
  separate(tract, into = c('state', 'county', 'tract'), sep = c(2,5)) 

#merge the station by tract data frame with the shapefile
df_merged <- geo_join(nynj_shapefile, tract_ave, "GEOID", "geocode")
df_merged$ave_count = ifelse(is.na(df_merged$ave_count), 0, df_merged$ave_count)
df_merged$num_station = ifelse(is.na(df_merged$num_station), 0, df_merged$num_station)

#choose the palette
pal2 <- colorNumeric(
  palette = "RdYlBu",
  domain = c(min(df_merged$ave_count,na.rm = T), max(df_merged$ave_count,na.rm = T)),reverse = T
)

#plot the graph
leaflet(df_merged) %>%
  addTiles() %>%
  setView(lng = -73.9759, lat = 40.7410, zoom = 13) %>%
  addPolygons(fillColor = ~pal2(ave_count), 
              opacity = 0.1, 
              weight = 1,
              popup = ~paste0("Average Usage/month: ", ave_count, "<br>", "Number of station: ", num_station),
              popupOptions = popupOptions(autoPan = TRUE, keepInView = FALSE, closeButton = FALSE,
                           zoomAnimation = NULL, closeOnClick = NULL))%>%
  addLegend("topleft",pal = pal2, values = ~ave_count,
            title = "Station Popularity by Tract",
            opacity = 1)

#show a list of station 
tract_ave$state <- ifelse(tract_ave$state == 34, "NJ", "NY")
tract_ave$county <- as.factor(tract_ave$county)
levels(tract_ave$county) <- c("Bronx", "Hudson", "Brooklyn", "Manhattan", "Queens")
list <- tract_ave[, -6] %>% arrange(desc(ave_count))
