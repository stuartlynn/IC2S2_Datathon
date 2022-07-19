cases <- read.csv("rawdata/msa_cumulative_cases.csv")
cases <- cases %>% 
  filter(X == 1 | X == 3)
for (i in 2:ncol(cases)) {
  colnames(cases)[i] -> date
  if (i == 2) {
    cases$x <- cases$X2020.01.27 - cases$X2020.01.21  
  } else if (i %% 7 == 1){
    cases$x <- cases[,i+7] - cases[,i]  
  }
    names(cases)[names(cases) == "x"] <- paste("wk",substring(date, 2),sep = "")
}
cases <- cases %>% 
  select(starts_with("wk"), "X")
cases$wk2022.07.11 <- NULL
cases$MSA = ifelse(cases$X == 1, "NY", "Chicago")
write.csv(cases, "data/wkcases.csv", row.names = F)
