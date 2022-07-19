library(tidyverse)
NY <- read.csv("rawdata/New York-Newark-Jersey City, NY-NJ-PA Metro Area.csv")
NY$X <- NULL
NY <- NY %>% 
  mutate(femaleP = female_population/population*100,
         childP = (X0_to_9_years_old + X10_to_19_years_old)/population*100,
         Ov70P = (X70_to_79_years_old + X80_years_old_and_older)/population*100,
         IncomeBl10KP = households_whose_annual_income_less_than_10000_dollars/total_households*100,
         Income50K200KP = households_whose_annual_income_between_50000_and_200000_dollars/total_households*100,
         IncomeOv200KP = households_whose_annual_income_greater_than_200000_dollars/total_households*100,
         InLaborP = workforce_in_labor/total_workforce*100,
         ByCarP = commuting_by_car_or_truck_or_van/total_workforce*100,
         ByCabMotorBicycle = commuting_by_taxicab_or_motorcycle_or_bicycle_or_other_means/total_workforce*100,
         CommuteOv20minP = (commuting_time_between_20_and_60_minutes + commuting_time_over_60_minutes)/total_workforce*100,
         NHwhiteP = non_hispanic_white/population*100,
         blackP = black_or_african_american/population*100,
         AmInd = american_indian_and_alaska_native/population*100,
         asianP = asian/population*100,
         hisP = hispanic_or_latino/population*100) %>% 
  select(census_tract, ends_with("P"))

Access02 <- read.csv("rawdata/Access02_T.csv")
NY <- left_join(NY, Access02, by = c("census_tract" = "GEOID"))
NY <- NY %>% 
  mutate(FQHCdrivetime = timeDrive,
         FQHCcount = countDrive) %>% 
  select(census_tract, ends_with("P"), starts_with("FQHC"))

Access03 <- read.csv("rawdata/Access03_T.csv")
NY <- left_join(NY, Access03, by = c("census_tract" = "GEOID"))
NY <- NY %>% 
  mutate(Hospdrivetime = timeDrive,
         Hospcount = countDrive) %>% 
  select(census_tract, ends_with("P"), starts_with("FQHC"), starts_with("Hosp"))

Access04 <- read.csv("rawdata/Access04_T.csv")
NY <- left_join(NY, Access04, by = c("census_tract" = "GEOID"))
NY <- NY %>% 
  mutate(Rxdrivetime = timeDrive,
         Rxcount = countDrive) %>% 
  select(census_tract, ends_with("P"), starts_with("FQHC"), starts_with("Hosp"), starts_with("Rx"))

Access05 <- read.csv("rawdata/Access05_T.csv")
NY <- left_join(NY, Access05, by = c("census_tract" = "GEOID"))
NY <- NY %>% 
  mutate(MHdrivetime = timeDrive,
         MHcount = countDrive) %>% 
  select(census_tract, ends_with("P"), starts_with("FQHC"), starts_with("Hosp"), starts_with("Rx"), starts_with("MH"))

DS01 <- read.csv("rawdata/DS01_T.csv")
DS01 <- DS01 %>% 
  select(GEOID, noHSP, disbP) 
NY <- left_join(NY, DS01, by = c("census_tract" = "GEOID"))

DS02 <- read.csv("rawdata/DS02_T.csv")
NY <- left_join(NY, DS02, by = c("census_tract" = "GEOID"))

EC03 <- read.csv("rawdata/EC03_T.csv") %>% 
  select(GEOID, unempP, povP, pciE)
NY <- left_join(NY, EC03, by = c("census_tract" = "GEOID"))

EC05 <- read.csv("rawdata/EC05_T.csv") %>% 
  select(GEOID, NoIntPct)
NY <- left_join(NY, EC05, by = c("census_tract" = "GEOID"))

EC02 <- read.csv("rawdata/EC02_T.csv") %>% 
  select(GEOID, essnWrkP)
NY <- left_join(NY, EC02, by = c("census_tract" = "GEOID"))

BE01 <- read.csv("rawdata/BE01_T.csv") %>% 
  select(GEOID, vacantP, mobileP)
NY <- left_join(NY, BE01, by = c("census_tract" = "GEOID"))

write.csv(NY, "data/NewYork_Sociodemographics.csv", row.names = F)
