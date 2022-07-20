library(tidyverse)
library(ggplot2)
library(grid)

data = read_csv("~/R/IC2S2_Datathon/socio_tract/data/all_by_week_chicago10parks.csv")

colors = c("Cases (wkly)" = "red", 
           "Trips (wkly)" = "forestgreen")

data %>% 
  group_by(date) %>% 
  summarise(
    trips = sum(total_trips, na.rm=T), 
    cases =mean(wkcases, na.rm=T)) %>% 
  mutate(
    trips=scale_this(trips), 
    cases = scale_this(cases) ) %>% 
  ggplot(aes(x=date)) + 
  geom_line(aes(y=trips, color="Trips (wkly)")) + 
  geom_line(aes(y=cases,color="Cases (wkly)" )) + 
  theme(
    legend.position = "bottom",
    panel.background = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 8)
  ) +
  geom_vline(xintercept = as.Date("2020-01-20"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2020-12-30"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-05-31"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-11-01"), alpha = 0.4, linetype = 2) + 
  labs(x="Date", 
       y="Std Dev +/- Mean",
       color="Measure") +
  scale_color_manual(values = colors)

socio <- read.csv("~/R/IC2S2_Datathon/socio_tract/data/allwithsociodemo_chicago10parks.csv")
top_tracts = socio$census_tract[socio$top_totaladj==1]



trips = read_csv("~/R/IC2S2_Datathon/socio_tract/data/CHICAGO_10_PARKS.csv")
parks = unique(trips$destination)
trips$time = NA
for (i in 1:length(parks)){
  park = parks[i]
  transit_mat = read_csv(paste0("~/R/IC2S2_Datathon/mobility/data/transit_matrices/CHICAGO/driving/",
                                park,".csv"))
  trips = trips %>% left_join(transit_mat, by=c("origin", "destination" ))
  trips$time = coalesce(trips$time, trips$minutes)
  trips = trips %>% select(-minutes)
}


trips %>% 
  group_by(date) %>% 
  summarise(avg_time = sum(trips *time, na.rm=T) / sum(trips, na.rm=T)) %>% 
  ggplot(aes(x=date, y=avg_time)) + 
  geom_line() + 
  theme(
    legend.position = "bottom",
    panel.background = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 8)
  ) +
  geom_vline(xintercept = as.Date("2020-01-20"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2020-12-30"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-05-31"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-11-01"), alpha = 0.4, linetype = 2) + 
  labs(x="Date", y="Avg. Park Trip Driving Time") 
