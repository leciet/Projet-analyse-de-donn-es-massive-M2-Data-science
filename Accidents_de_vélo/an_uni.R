
library(plotly)

var_analyse <- names(don)[c(2:5,10:18,20,21)]
noms_vars <- setNames(c("Année", "Mois", "Jour", "Heure",
                        "Agglomération", "Luminosité", "Météo", 
                        "Type de route", "Type de surface", 
                        "Gravité", "Sexe", "Âge", "Type de trajet", 
                        "Port de casque", "Port de gilet"),
                      var_analyse)

output$graph_uni <- renderPlotly({
  don <- don |>
    filter(an >= input$annee[1] & an <= input$annee[2])
  
  don$age <- case_when(
    don$age < 20 ~ "13-19 ans",
    don$age < 40 ~ "20-39 ans",
    don$age < 60 ~ "40-59 ans",
    .default = "60-80 ans")
  
  don$hrmn <- paste(
    substr(don$hrmn, 1, 3),
    "00",
    sep = '')
  
  ggp <- ggplot(don) + aes(x = .data[[input$varuni]]) +
    geom_bar(fill = 'skyblue', alpha = 0.8) +
    labs(x = noms_vars[input$varuni],
         y = "Nombre d'accidents",
         title = paste("Accidents de",
                       input$annee[1],
                       "à",
                       input$annee[2]))
  
  ggplotly(ggp)
})