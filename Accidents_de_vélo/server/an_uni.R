
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
  
  don$an <- as.factor(don$an)
  
  don$age <- case_when(
    don$age < 20 ~ "13-19 ans",
    don$age < 40 ~ "20-39 ans",
    don$age < 60 ~ "40-59 ans",
    .default = "60-80 ans") |>
    as.factor()
  
  don$hrmn <- paste(
    substr(don$hrmn, 1, 3),
    "00",
    sep = '') |>
    as.factor()
  
  levels(don$casque) = c('Non', 'Oui')
  levels(don$gilet) = c('Non', 'Oui')
  
  if (input$by_grav == 'Total'){
  ggp <- ggplot(don) + aes(x = .data[[input$varuni]], 
                           text = after_stat(paste(noms_vars[input$varuni],
                                                   ':',
                                                   levels(don[,input$varuni])[x],
                                                   '<br>Total :',
                                                   count))) +
    geom_bar(fill = 'skyblue', alpha = 0.8) +
    labs(x = noms_vars[input$varuni],
         y = "Nombre d'accidents",
         title = paste("Accidents de",
                       input$annee[1],
                       "à",
                       input$annee[2]))
  } else {
    don2 <- don |>
      count(get(input$varuni), grav, name = 'n')
    names(don2)[1] <- input$varuni
    
    if (names(don2)[1] == names(don2)[2]) don2 <- don2[-1]
    
    don_tot <- don2 |>
      group_by(get(input$varuni)) |>
      summarise(N = sum(n))
    names(don_tot)[1] <- input$varuni
    
    don2 <- inner_join(don2,don_tot, by = input$varuni) |>
      mutate(prop = 100*n/N)
    
    names(don2)[names(don2) == 'grav'] = 'Gravité'
    choix_x <- ifelse(input$varuni == 'grav', 'Gravité', input$varuni)
    
    ggp <- ggplot(don2) + aes(x = .data[[choix_x]],
                              fill = Gravité,
                              y = n,
                              text = paste('Gravité :',
                                          Gravité,
                                          '<br>Proportion :',
                                          round(prop,1),
                                          '%')) +
      geom_col(alpha = 0.8, position = 'fill') +
      labs(x = noms_vars[input$varuni],
           y = "Proportion des accidents",
           title = paste("Accidents de",
                         input$annee[1],
                         "à",
                         input$annee[2]))
  }
  
  if (nlevels(don[,input$varuni]) > 5){
    ggp <- ggp +
      theme(axis.text.x = element_text(angle = 30, vjust = 0.5, hjust=1))
  }
  
  ggplotly(ggp, tooltip = 'text')
})