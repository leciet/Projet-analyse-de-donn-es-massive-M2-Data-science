
library(FactoMineR)

don$age <- case_when(
  don$age < 20 ~ "13-19 ans",
  don$age < 40 ~ "20-39 ans",
  don$age < 60 ~ "40-59 ans",
  .default = "60-80 ans")

don$hrmn <- paste(
  substr(don$hrmn, 1, 3),
  "00",
  sep = '')

levels(don$casque) = c('Non', 'Oui')
levels(don$gilet) = c('Non', 'Oui')


output$plot_CA <- renderPlot({
  don$an <- as.factor(don$an)
  
  tab <- table(don$grav, don[,input$var_ac])
  
  res_CA <- CA(tab, graph = F)
  plot(res_CA)
})


output$plot_MCA_ind <- renderPlot({
  
  input$constr_acm
  
  isolate({
    don$an <- as.factor(don$an)
    
    ind_actif <- which(names(don) %in% input$var_acm)
    ind_illus <- which(names(don) == 'grav')
    
    res_MCA <- MCA(don[,c(ind_actif, ind_illus)], quali.sup = length(ind_actif) + 1, graph = F)
    plot(res_MCA, choix = "ind", invisible = 'ind', xlim = c(-4,4))
  })
})

output$plot_MCA_var <- renderPlot({
  
  observe({
    shinyjs::toggleState("constr_acm", condition = length(input$var_acm) > 2)
  })
  
  input$constr_acm
  
  isolate({
    don$an <- as.factor(don$an)
    
    ind_actif <- which(names(don) %in% input$var_acm)
    ind_illus <- which(names(don) == 'grav')
    
    res_MCA <- MCA(don[,c(ind_actif, ind_illus)], quali.sup = length(ind_actif) + 1, graph = F)
    plot(res_MCA, choix = "var")
  })
})