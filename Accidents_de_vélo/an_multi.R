
library(FactoMineR)

output$plot_CA <- renderPlot({
  don$age <- case_when(
    don$age < 20 ~ "13-19 ans",
    don$age < 40 ~ "20-39 ans",
    don$age < 60 ~ "40-59 ans",
    .default = "60-80 ans")
  
  don$hrmn <- paste(
    substr(don$hrmn, 1, 3),
    "00",
    sep = '')
  
  tab <- table(don$grav, don[,input$varmulti])
  
  res_CA <- CA(tab, graph = F)
  plot(res_CA)
})