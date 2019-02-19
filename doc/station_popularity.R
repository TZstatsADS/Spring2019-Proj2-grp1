library(dplyr)
nycdata <- read.csv("/Users/yujiewang/Google Drive (yw3285@columbia.edu)/Spring2019-Proj2-grp1/data/201901-citibike-tripdata.csv", stringsAsFactors = FALSE)
jcdata <- read.csv("/Users/yujiewang/Google Drive (yw3285@columbia.edu)/Spring2019-Proj2-grp1/data/JC-201901-citibike-tripdata.csv", stringsAsFactors = FALSE)
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

write_csv(popularity_data)