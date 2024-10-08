data_global <- data %>%
  group_by(dep) %>%
  summarise(
    lat = mean(lat_ancien, na.rm = TRUE),
    long = mean(long_ancien, na.rm = TRUE),
    nombre_lignes = n(),
    tués = sum(grav == "Tué", na.rm = TRUE),
    hospi = sum(grav == "Blessé hospitalisé", na.rm = TRUE),
    léger = sum(grav == "Blessé léger", na.rm = TRUE),
    indem = sum(grav == "Indemne", na.rm = TRUE)
    
  ) %>%
  mutate(
    pourc_t = round((tués / nombre_lignes) * 100),
    pourc_h = round((hospi / nombre_lignes) * 100),
    pourc_l = round((léger / nombre_lignes) * 100),
    pourc_i = round((indem / nombre_lignes) * 100)
  ) %>%
  select(dep, nombre_lignes, pourc_t, pourc_h, pourc_l, pourc_i, lat, long) %>%
  dplyr::rename(Tués = pourc_t, Hospitalisés = pourc_h,
                `Blessés légers` = pourc_l, Indemnes = pourc_i)

# Initialiser la carte `map_sexe` au démarrage
output$map_sexe <- renderLeaflet({
  tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
  
  leaflet(width = "100%", height = "400px") %>%
    addTiles(tilesURL) %>%
    addMinicharts(
      data_global$long,
      data_global$lat,
      chartdata = data_global[, c("Tués", "Hospitalisés", "Blessés légers", "Indemnes")],
      type = "pie",
      width = 20,
      height = 20,
      showLabels = TRUE
    )
})

# Réaction au bouton 'param_sexe'
observeEvent(input$param_sexe, {
  result_sexe_filtered <- data %>%
    filter(dep == input$selected_dep, an == input$selected_year) %>%
    group_by(dep) %>%
    summarise(
      lat = mean(lat_ancien, na.rm = TRUE),
      long = mean(long_ancien, na.rm = TRUE),
      nombre_lignes = n(),
      femmes = sum(sexe == "Feminin", na.rm = TRUE),
      hommes = sum(sexe == "Masculin", na.rm = TRUE)
    ) %>%
    mutate(
      pourcentage_femmes = (femmes / nombre_lignes) * 100,
      pourcentage_hommes = (hommes / nombre_lignes) * 100
    ) %>%
    select(dep, nombre_lignes, pourcentage_femmes, pourcentage_hommes, lat, long)
  
  if (nrow(result_sexe_filtered) > 0) {
    output$map_sexe <- renderLeaflet({
      tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
      
      leaflet() %>%
        addTiles(tilesURL) %>%
        addMinicharts(
          result_sexe_filtered$long,
          result_sexe_filtered$lat, 
          chartdata = result_sexe_filtered[, c("pourcentage_hommes", "pourcentage_femmes")],
          type = "pie",
          colorPalette = c("blue", "pink"),
          width = 15, 
          height = 15,
          showLabels = TRUE
        )
    })
  } else {
    showNotification("Pas de données disponibles pour les filtres sélectionnés", type = "warning")
  }
})

# Observer pour le second bouton
# Add reset functionality for the sexe parameters
observeEvent(input$param_sexe_2, {
  updateSelectInput(session, "selected_dep", selected = "")
  updateSelectInput(session, "selected_year", selected = "")
  
  output$map_sexe <- renderLeaflet({
    tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
    
    leaflet(width = "100%", height = "400px") %>%
      addTiles(tilesURL) %>%
      addMinicharts(
        data_global$long,
        data_global$lat,
        chartdata = data_global[, c("pourcentage_hommes", "pourcentage_femmes")],
        type = "pie",
        colorPalette = c("blue", "pink"),
        width = 20,
        height = 20,
        showLabels = TRUE
      )
  })
})

result_ds <- data %>%
  group_by(dep, an, grav) %>%
  summarise(count = n(), .groups = 'drop') %>%
  spread(key = grav, value = count, fill = 0) %>% # Spread severity levels into columns
  left_join(lat_long, by = "dep")
severity_colors <- c("green", "yellow", "orange", "red")

# Carte d'évolution par gravité
output$map_gravite <- renderLeaflet({
  tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
  basemap <- leaflet(width = "100%", height = "400px") %>%
    addTiles(tilesURL)
  
  basemap %>% 
    addMinicharts(
      lng = result_ds$long, 
      lat = result_ds$lat, 
      chartdata = as.data.frame(result_ds[, c("Indemne", "Blessé léger", "Blessé hospitalisé", "Tué")]), # Vérifiez les noms de colonnes ici
      type = "bar",
      time = result_ds$an,  # Définir l'année ici
      colorPalette = severity_colors, # Utiliser la palette de couleurs définie
      width = 70, height = 70
    )})



# Afficher les données dans un tableau
output$donnees <- DT::renderDT({
  datatable(data)
})

pal <- colorBin(
  palette = "YlOrRd",  # Palette de couleurs (du jaune au rouge)
  domain = lat_long$n_observations,  # Variable à utiliser pour la palette
  bins = 5,  # Nombre d'intervalles de couleurs
  pretty = TRUE  # Génère des intervalles "jolis" (ronds)
)
#pal <- colorBin("Reds", domain = lat_long$n_observations, bins = 5)
####################3AJOUT DE CARTE AVEC TOUT OBSERVATION 
# Créer la carte avec Leaflet
output$map <- renderLeaflet({
  leaflet(lat_long) %>%
    addTiles() %>%  # Ajoute une carte de fond (OpenStreetMap par défaut)
    addCircleMarkers(
      lng = ~long,  # Longitude pour chaque département
      lat = ~lat,   # Latitude pour chaque département
      radius = ~sqrt(n_observations) / 4,  # Taille du cercle proportionnelle au nombre d'observations
      popup = ~paste("Département:", dep, "<br>Nombre d'observations:", n_observations),  # Info bulle
      color = ~pal(n_observations), # Couleur des cercles
      fillColor = ~pal(n_observations),
      fillOpacity = 0.7,
      stroke = TRUE
    ) %>%
    addLegend(
      position = "bottomright",
      pal = pal,  # Utilisation de la palette définie
      title = "Nombre d'observations",
      values = ~n_observations,
      
      opacity = 0.7,
      labFormat = labelFormat(digits = 0)  # Formater les labels sans décimales
      
    )
})

# Réaction au bouton 'param_s'
observeEvent(input$val_frm, {
  # Reactive data based on user inputs
  filtered_data <- reactive({
    req(input$selected_dep2, input$selected_an, input$selected_mois) # Require at least these three filters
    
    # Commencez par le DataFrame complet
    filtered_df <- data
    
    # Appliquer les filtres selon les choix de l'utilisateur
    if (!is.null(input$selected_dep2)) {
      filtered_df <- filtered_df %>% filter(dep %in% input$selected_dep)
    }
    
    if (!is.null(input$selected_an)) {
      filtered_df <- filtered_df %>% filter(an %in% input$selected_an)
    }
    
    if (!is.null(input$selected_mois)) {
      filtered_df <- filtered_df %>% filter(mois %in% input$selected_mois)
    }
    
    # Assurez-vous de vérifier que les entrées utilisateur sont de type correct
    if (!is.null(input$selected_lum)) {
      if (is.character(data$lum) || is.factor(data$lum)) {
        filtered_df <- filtered_df %>% filter(as.character(lum) %in% input$selected_lum)
      }
    }
    
    if (!is.null(input$selected_atm)) {
      if (is.character(data$atm) || is.factor(data$atm)) {
        filtered_df <- filtered_df %>% filter(as.character(atm) %in% input$selected_atm)
      }
    }
    
    if (!is.null(input$selected_catr)) {
      if (is.character(data$catr) || is.factor(data$catr)) {
        filtered_df <- filtered_df %>% filter(as.character(catr) %in% input$selected_catr)
      }
    }
    
    # Répétez pour les autres variables, en vérifiant si elles sont des caractères ou des facteurs
    if (!is.null(input$selected_grav)) {
      if (is.character(data$grav) || is.factor(data$grav)) {
        filtered_df <- filtered_df %>% filter(as.character(grav) %in% input$selected_grav)
      }
    }
    
    if (!is.null(input$selected_surf)) {
      if (is.character(data$surf) || is.factor(data$surf)) {
        filtered_df <- filtered_df %>% filter(as.character(surf) %in% input$selected_surf)
      }
    }
    
    if (!is.null(input$selected_sexe)) {
      if (is.character(data$sexe) || is.factor(data$sexe)) {
        filtered_df <- filtered_df %>% filter(as.character(sexe) %in% input$selected_sexe)
      }
    }
    
    if (!is.null(input$selected_age)) {
      if (is.character(data$age) || is.factor(data$age)) {
        filtered_df <- filtered_df %>% filter(as.character(age) %in% input$selected_age)
      }
    }
    
    if (!is.null(input$selected_trajet)) {
      if (is.character(data$trajet) || is.factor(data$trajet)) {
        filtered_df <- filtered_df %>% filter(as.character(trajet) %in% input$selected_trajet)
      }
    }
    
    if (!is.null(input$selected_equipement)) {
      if (is.character(data$equipement) || is.factor(data$equipement)) {
        filtered_df <- filtered_df %>% filter(as.character(equipement) %in% input$selected_equipement)
      }
    }
    
    if (!is.null(input$selected_casque)) {
      if (is.character(data$casque) || is.factor(data$casque)) {
        filtered_df <- filtered_df %>% filter(as.character(casque) %in% input$selected_casque)
      }
    }
    
    if (!is.null(input$selected_git)) {
      if (is.character(data$git) || is.factor(data$git)) {
        filtered_df <- filtered_df %>% filter(as.character(git) %in% input$selected_git)
      }
    }
    
    if (!is.null(input$selected_equipement_autre)) {
      if (is.character(data$equipement_autre) || is.factor(data$equipement_autre)) {
        filtered_df <- filtered_df %>% filter(as.character(equipement_autre) %in% input$selected_equipement_autre)
      }
    }
    
    # Retourner le DataFrame filtré
    return(filtered_df)
  })
  
  # Get the filtered data correctly
  filtered <- filtered_data()  # Call the reactive function
  lat_long_fil <- filtered %>%
    group_by(dep) %>%
    summarise(
      lat = mean(lat_ancien, na.rm = TRUE),  # Moyenne de la latitude
      long = mean(long_ancien, na.rm = TRUE),
      n_observations = n()# Moyenne de la longitude
    )  %>%
    select(dep,lat,long,n_observations)
  #req(filtered_data())
  #print(str(filtered_data()))
  
  
  if (nrow(lat_long_fil) > 0) {
    # Get the filtered data
    
    output$map <- renderLeaflet({
      leaflet(lat_long_fil) %>%
        addTiles() %>%  # Ajoute une carte de fond (OpenStreetMap par défaut)
        addCircleMarkers(
          lng = ~long,  # Longitude pour chaque département
          lat = ~lat,   # Latitude pour chaque département
          radius = ~sqrt(n_observations) *5,  # Taille du cercle proportionnelle au nombre d'observations
          popup = ~paste("Département:", dep, "<br>Nombre d'observations:", n_observations),  # Info bulle
          color = ~pal(n_observations), # Couleur des cercles
          fillColor = ~pal(n_observations),
          fillOpacity = 0.7,
          stroke = TRUE
        ) %>%
        addLegend(
          position = "bottomright",
          pal = pal,  # Utilisation de la palette définie
          title = "Nombre d'observations",
          values = ~n_observations,
          
          opacity = 0.7,
          labFormat = labelFormat(digits = 0)  # Formater les labels sans décimales
          
        )
    })
  } else {
    showNotification("Pas de données disponibles pour les filtres sélectionnés", type = "warning")
  }
})



# Render the data table
output$data_table <- renderDT({
  req(filtered) # Require filtered data to be available
  datatable(filtered)
})

output$saisonalitePlot <- renderPlotly({
  gpl <- ggplot(don) + aes(x = mois, text = after_stat(paste("Mois : ", levels(don$mois)[x], "<br>Accidents : ", count, sep = ''))) +
    geom_bar(alpha = 0.8, fill = 'lightblue') +
    labs(title = "Nombre d'accidents de vélo par mois (saisonnalité)", 
         x = "Mois", 
         y = "Nombre d'accidents") +
    theme_minimal()
  
  plotly::ggplotly(gpl, tooltip = 'text')
})

output$serieTemporellePlot <- renderPlotly({
  accidents_ts <- ts(accidents_by_year$number_of_accidents, 
                     start = min(accidents_by_year$year), 
                     end = max(accidents_by_year$year), 
                     frequency = 1)
  
  gpl <- ggplot(accidents_by_year) + 
    aes(x = year, y = number_of_accidents, group = 1,
        text = paste("Année : ", year, "<br>Accidents : ", number_of_accidents, sep = '')) +
    geom_point() +
    geom_line() +
    labs(title = "Nombre d'accidents de vélo par année", 
         x = "Année",
         y = "Nombre d'accidents")
  
  plotly::ggplotly(gpl, tooltip = 'text')
}) 
# Prévisions ARIMA
output$forecastPlot <- renderPlotly({
  # Ajuster le modèle ARIMA
  accidents_ts <- ts(accidents_by_year$number_of_accidents, 
                     start = min(accidents_by_year$year), 
                     end = max(accidents_by_year$year), 
                     frequency = 1)
  model <- auto.arima(accidents_ts, seasonal = TRUE)
  #print(summay(model))
  checkresiduals(model)
  # Prévisions sur les 5 prochaines années
  #forecast <- predict(model, h = 24)
  # Forecast horizon based on user-selected year
  last_year <- max(accidents_by_year$year)
  forecast_horizon <- input$yearInput - last_year
  
  # Make sure the forecast horizon is valid
  if (forecast_horizon > 0) {
    fcast <- forecast(model, h = forecast_horizon)
    
    # Plot the forecast from the model
    autoplot(fcast) +
      ggtitle("Prévision du nombre d'accidents de vélo") +
      xlab("Année") + ylab("Nombre d'accidents") +
      theme_minimal()
  } else {
    # If the selected year is within the data range, just show a message or existing data
    plot(accidents_ts, 
         main = "Aucune prévision disponible avant la dernière année", 
         xlab = "Année", ylab = "Nombre d'accidents")
  }
})
# Réactif pour récupérer les valeurs de la sélection du département et de l'année
selected_data <- reactive({
  req(input$selected_depp, input$selected_yearr)
  data %>% 
    filter(dep == input$selected_depp, an == input$selected_yearr)
})


accidents_ts <- ts(accidents_by_year$number_of_accidents, 
                   start = min(accidents_by_year$year), 
                   end = max(accidents_by_year$year), 
                   frequency = 1)
model <- auto.arima(accidents_ts, seasonal = TRUE)
#print(summay(model))
checkresiduals(model)

# Modèle ARIMA : prédiction du nombre d'accidents
prediction_arima <- reactive({
  req(input$param_pred)  # Attend que le bouton soit cliqué
  
  # Filtrage des données pour le département sélectionné
  dep_data <- data %>% filter(dep == input$selected_depp)
  
  # Agrégation des accidents par année
  ts_data <- dep_data %>%
    group_by(an) %>%
    summarise(
      lat = mean(lat_ancien, na.rm = TRUE),  # Moyenne de la latitude
      long = mean(long_ancien, na.rm = TRUE),
      n_observations = n()# Moyenne de la longitude
    )
  
  
  # Créer une série temporelle à partir des données agrégées
  accidents_ts <- ts(ts_data$n_observations, start = min(ts_data$an), frequency = 1)
  
  # Ajuster le modèle ARIMA
  fit <- auto.arima(accidents_ts)
  
  # Prédire pour l'année sélectionnée
  year_to_predict <- as.numeric(input$selected_yearr)
  years_ahead <- year_to_predict - max(ts_data$an)  # Calcul du nombre d'années à prévoir
  
  if (years_ahead > 0) {
    forecast_result <- forecast(fit, h = years_ahead)
    predicted_value <- forecast_result$mean[years_ahead]
  } else {
    # Si l'année est dans la plage historique, renvoyer la valeur réelle
    predicted_value <- ts_data$n_observations[ts_data$an == year_to_predict]
  }
  
  return(predicted_value)
})

# Afficher le résultat de la prédiction
prediction_text  <- reactive({
  req(input$param_pred)
  req(prediction_arima())
  paste("Le nombre d'accidents prédits pour le département", input$selected_depp, "en", input$selected_yearr, "est :", round(prediction_arima()))
})

# Afficher le résultat dans une pop-up quand on clique sur le bouton
observeEvent(input$param_pred, {
  # Récupérer le texte actuel du résultat
  #result <- output$prediction_result()
  
  # Utiliser shinyjs pour afficher une alerte avec le résultat
  #shinyjs::alert(prediction_text())
  shinyalert(prediction_text())
})

# Afficher un graphique des accidents prédits
output$predPlot <- renderPlot({
  req(selected_data())
  dep_data <- selected_data()
  
  ggplot(dep_data, aes(x = an, y = accidents)) +
    geom_line() +
    geom_point() +
    labs(title = paste("Nombre d'accidents prédits pour le département", input$selected_depp),
         x = "Année", y = "Nombre d'accidents") +
    theme_minimal()
})

