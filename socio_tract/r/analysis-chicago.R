chicagoparkvisits <- read.csv("data/CHICAGO_10_PARKS.csv") %>% 
  distinct()
prepandemic <- chicagoparkvisits %>% 
  filter(chicagoparkvisits$date < "2020-01-20") 
prevaccine <- chicagoparkvisits %>% 
  filter(chicagoparkvisits$date >= "2020-01-20" &
    chicagoparkvisits$date < "2020-12-30") 
postvaccine <- chicagoparkvisits %>% 
  filter(chicagoparkvisits$date >= "2020-12-30" & 
           chicagoparkvisits$date < "2021-05-31")
delta <- chicagoparkvisits %>% 
  filter(chicagoparkvisits$date >= "2021-05-31" & 
           chicagoparkvisits$date < "2021-11-01")
omicron <- chicagoparkvisits %>% 
  filter(chicagoparkvisits$date >= "2021-11-01") 

nrow(prepandemic) + nrow(prevaccine) + nrow(postvaccine) + nrow(delta) + nrow(omicron) == nrow(chicagoparkvisits)

all_origin <- chicagoparkvisits %>% 
  group_by(origin, date) %>% 
  summarise(total_trips = sum(trips))
write.csv(all_origin, "data/all_by_week_chicago10parks.csv", row.names = F)

library(ggplot2)
library(hrbrthemes)
library(viridis)

all_origin %>% 
  ggplot(aes(x = date, y = total_trips, group = origin, color = origin)) + 
  geom_line() + 
  scale_color_viridis(discrete = TRUE)

prepandemic_origin <- prepandemic %>% 
  group_by(origin) %>% 
  summarise(total_trips = sum(trips))
colnames(prepandemic_origin) <- c("census_tract", "ttrips_prepandemic")
chicago_park <- left_join(chicago, prepandemic_origin, by="census_tract")
chicago_park$ttrips_prepandemic <- ifelse(is.na(chicago_park$ttrips_prepandemic), 0,
                                         chicago_park$ttrips_prepandemic)
prepandemic_thr = quantile(chicago_park$ttrips_prepandemic, 0.95)
chicago_park$top_prepandemic <- ifelse(chicago_park$ttrips_prepandemic >= prepandemic_thr,
                                 1, 0)

prevaccine_origin <- prevaccine %>% 
  group_by(origin) %>% 
  summarise(total_trips = sum(trips))
colnames(prevaccine_origin) <- c("census_tract", "ttrips_prevaccine")
chicago_park <- left_join(chicago_park, prevaccine_origin, by="census_tract")
chicago_park$ttrips_prevaccine <- ifelse(is.na(chicago_park$ttrips_prevaccine), 0,
                                          chicago_park$ttrips_prevaccine)
prevaccine_thr = quantile(chicago_park$ttrips_prevaccine, 0.95)
chicago_park$top_prevaccine <- ifelse(chicago_park$ttrips_prevaccine >= prevaccine_thr,
                                 1, 0)

postvaccine_origin <- postvaccine %>% 
  group_by(origin) %>% 
  summarise(total_trips = sum(trips))
colnames(postvaccine_origin) <- c("census_tract", "ttrips_postvaccine")
chicago_park <- left_join(chicago_park, postvaccine_origin, by="census_tract")
chicago_park$ttrips_postvaccine <- ifelse(is.na(chicago_park$ttrips_postvaccine), 0,
                                         chicago_park$ttrips_postvaccine)
postvaccine_thr = quantile(chicago_park$ttrips_postvaccine, 0.95)
chicago_park$top_postvaccine <- ifelse(chicago_park$ttrips_postvaccine >= postvaccine_thr,
                                      1, 0)

delta_origin <- delta %>% 
  group_by(origin) %>% 
  summarise(total_trips = sum(trips))
colnames(delta_origin) <- c("census_tract", "ttrips_delta")
chicago_park <- left_join(chicago_park, delta_origin, by="census_tract")
chicago_park$ttrips_delta <- ifelse(is.na(chicago_park$ttrips_delta), 0,
                                          chicago_park$ttrips_delta)
delta_thr = quantile(chicago_park$ttrips_delta, 0.95)
chicago_park$top_delta <- ifelse(chicago_park$ttrips_delta >= delta_thr,
                                       1, 0)

omicron_origin <- omicron %>% 
  group_by(origin) %>% 
  summarise(total_trips = sum(trips))
colnames(omicron_origin) <- c("census_tract", "ttrips_omicron")
chicago_park <- left_join(chicago_park, omicron_origin, by="census_tract")
chicago_park$ttrips_omicron <- ifelse(is.na(chicago_park$ttrips_omicron), 0,
                                          chicago_park$ttrips_omicron)
omicron_thr = quantile(chicago_park$ttrips_omicron, 0.95)
chicago_park$top_omicron <- ifelse(chicago_park$ttrips_omicron >= omicron_thr,
                                       1, 0)

write.csv(chicago_park, "data/allwithsociodemo_chicago10parks.csv", row.names = F)


