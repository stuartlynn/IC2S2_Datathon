library(tidyverse)
library(ggplot2)
library(grid)
library(scales)

chicagocase <- cases %>% 
  filter(cases$MSA == "Chicago") %>% 
  select(-X)

case <- gather(chicagocase, date, wkcases, wk2020.01.21:wk2022.07.04)
case$date <- substring(case$date,3)
case$date <- sub(".", '-', case$date, fixed = T)
case$date <- sub(".", '-', case$date, fixed = T)
case$date <- as.Date(case$date)
case$date[1] <- "2020-01-20"
case$MSA <- NULL

all_origin$date <- as.Date(all_origin$date)
data <- left_join(all_origin, case, by = "date")
data$wkcases <- ifelse(is.na(data$wkcases), 0, data$wkcases)

data <- data %>% 
  filter(population > 0)
  
p1 <- ggplot(data) +
  geom_line(aes(x = date, y = wkcases), 
               alpha = .7, color = "blue") +
  geom_vline(xintercept = as.Date("2020-01-20"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2020-12-30"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-05-31"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-11-01"), alpha = 0.4, linetype = 2) +
  scale_y_continuous(
    name = "Weekly new cases",
    labels = comma
  ) +
  theme(
    legend.position = "none",
    panel.background = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 8)
  )

p2 <- ggplot(data) +
  geom_line(aes(x = date, y = total_trips, 
              group = origin, color = origin), lwd=0.3) +
  geom_vline(xintercept = as.Date("2020-01-20"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2020-12-30"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-05-31"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-11-01"), alpha = 0.4, linetype = 2) +
  scale_y_continuous(
    name = "Total trips",
    labels = comma
  ) + 
  theme(
    legend.position = "none",
    panel.background = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 8)
  )

p3 <- ggplot(data) +
  geom_line(aes(x = date, y = total_trips_adj, 
                group = origin, color = origin), lwd=0.3) +
  geom_vline(xintercept = as.Date("2020-01-20"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2020-12-30"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-05-31"), alpha = 0.4, linetype = 2) +
  geom_vline(xintercept = as.Date("2021-11-01"), alpha = 0.4, linetype = 2) +
  scale_y_continuous(
    name = "Total trips adjusted for pop",
    labels = comma
  ) +
  theme(
    legend.position = "none",
    panel.background = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 8)
  )

grid.newpage()
grid.draw(rbind(ggplotGrob(p1), ggplotGrob(p2), 
                ggplotGrob(p3), size = "last"))
