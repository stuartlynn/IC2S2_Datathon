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
  geom_line() 

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

chicago_park$top_any <- ifelse(chicago_park$top_prepandemic == 1|
                                 chicago_park$top_prevaccine == 1|
                                 chicago_park$top_postvaccine == 1|
                                 chicago_park$top_delta == 1|
                                 chicago_park$top_omicron == 1, 1, 0)

# merge in population 
population <- chicagoraw %>% 
  select(census_tract, population)

chicago_park <- left_join(chicago_park, population, 
                          by = "census_tract")

chicago_park <- chicago_park %>% 
  mutate(ttrips = ttrips_prepandemic + ttrips_prevaccine + ttrips_postvaccine +
           ttrips_delta + ttrips_omicron,
         ttripsadj = ttrips/population*10000)

chicago_park_analysis <- chicago_park %>% 
  filter(population > 0)

totaladj_thr <- quantile(chicago_park_analysis$ttripsadj, 0.95)
chicago_park_analysis$top_totaladj <- ifelse(chicago_park_analysis$ttripsadj > totaladj_thr, 
                                             1, 0) 

### correlation analysis 
chicago_park_analysis_cor <- chicago_park_analysis %>% 
  select(-census_tract, -starts_with("top"), -population)

cor <- cor(chicago_park_analysis_cor, use = "pairwise.complete.obs", method = "spearman")
corrplot.mixed(cor)
corp <- rcorr(as.matrix(chicago_park_analysis_cor), type="spearman") 
corrplot(corp$r, method = "square", 
         p.mat = corp$P, sig.level = 0.001, 
         tl.col = "black",addCoef.col = "black", number.cex= 9/ncol(cor), 
         diag=FALSE, tl.srt = 45,
         insig = "blank", type = "lower", cl.cex = 1,
         cl.lim = c(-1,1), col=colorRampPalette(c("#0571b0","white","#ca0020"))(200))

### tables
library(gtsummary)
theme_set(theme_bw(base_size=12))

tbl_summary(
  chicago_park_analysis,
  by = top_any,
  include = c(2:33, 44),
  type = list(femaleP ~ "continuous2",
              childP ~ "continuous2",
              Ov70P ~ "continuous2",
              IncomeBl10KP ~ "continuous2",
              Income50K200KP ~ "continuous2",
              IncomeOv200KP ~ "continuous2",
              InLaborP ~ "continuous2",
              ByCarP ~ "continuous2",
              CommuteOv20minP ~ "continuous2",
              NHwhiteP ~ "continuous2",
              blackP ~ "continuous2",
              asianP ~ "continuous2",
              hisP ~ "continuous2",
              minDisHosp ~ "continuous2",
              FQHCdrivetime ~ "continuous2",
              FQHCcount ~ "continuous2",
              Hospdrivetime ~ "continuous2",
              Hospcount ~ "continuous2",
              Rxdrivetime ~ "continuous2",
              Rxcount ~ "continuous2",
              MHdrivetime ~ "continuous2",
              SDOH ~ "categorical") 
) %>% 
  add_p() %>% 
  modify_header(label = "**Variable**") %>% # update the column header
  bold_labels()

tbl_summary(
  chicago_park_analysis,
  by = top_totaladj,
  include = c(2:35, 50),
  type = list(femaleP ~ "continuous2",
              childP ~ "continuous2",
              Ov70P ~ "continuous2",
              IncomeBl10KP ~ "continuous2",
              Income50K200KP ~ "continuous2",
              IncomeOv200KP ~ "continuous2",
              InLaborP ~ "continuous2",
              ByCarP ~ "continuous2",
              CommuteOv20minP ~ "continuous2",
              NHwhiteP ~ "continuous2",
              blackP ~ "continuous2",
              asianP ~ "continuous2",
              hisP ~ "continuous2",
              minDisHosp ~ "continuous2",
              FQHCdrivetime ~ "continuous2",
              FQHCcount ~ "continuous2",
              Hospdrivetime ~ "continuous2",
              Hospcount ~ "continuous2",
              Rxdrivetime ~ "continuous2",
              Rxcount ~ "continuous2",
              MHdrivetime ~ "continuous2",
              SDOH ~ "categorical") 
) %>% 
  add_p() %>% 
  modify_header(label = "**Variable**") %>% # update the column header
  bold_labels()

write.csv(chicago_park_analysis, "data/allwithsociodemo_chicago10parks.csv", row.names = F)

