
# Initialiser la carte `map_sexe` au démarrage
result_sexe_filtered <- data_global

# Réaction au bouton 'param_sexe'
observeEvent(input$param_sexe, {
  dta_f <- dta
  
  if (input$selected_dep != "Tous") dta_f <- dta %>% filter(dep == input$selected_dep)
  if (input$selected_year != "Toutes") dta_f <- dta %>% filter(an == input$selected_year)
  
  result_sexe_filtered <- dta_f %>%
    group_by(dep) %>%
    summarise(
      lat = mean(lat_nouveau, na.rm = TRUE),
      long = mean(long_nouveau, na.rm = TRUE),
      nombre_lignes = n(),
      femmes = sum(sexe == "Feminin", na.rm = TRUE),
      hommes = sum(sexe == "Masculin", na.rm = TRUE)
    ) %>%
    mutate(
      pourcentage_femmes = round((femmes / nombre_lignes) * 100),
      pourcentage_hommes = round((hommes / nombre_lignes) * 100)
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

result_ds <- dta %>%
  mutate(dep = as.factor(dep), an = as.factor(an)) %>%
  group_by(dep, an, grav, .drop = FALSE) %>%
  summarise(count = n(), .groups = 'drop') %>%
  spread(key = grav, value = count, fill = 0) %>% # Spread severity levels into columns
  left_join(unique(lat_long), by = "dep")

# Carte d'évolution par gravité
output$map_gravite <- renderLeaflet({
  tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
  basemap <- leaflet(width = "100%", height = "400px") %>%
    addTiles(tilesURL)
  
  basemap %>% 
    addMinicharts(
      lng = result_ds$long, 
      lat = result_ds$lat, 
      chartdata = as.data.frame(result_ds[, c("Indemne", "Blessé léger", "Blessé hospitalisé", "Tué")]),
      type = "pie",
      time = result_ds$an,  # Définir l'année ici
      colorPalette = c("royalblue", 'skyblue', "tomato", "darkred"),
      width = 20, height = 20
    )})



# Afficher les données dans un tableau
output$donnees <- DT::renderDT({
  datatable(dta)
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
    filtered_df <- dta
    
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
      if (is.character(dta$lum) || is.factor(dta$lum)) {
        filtered_df <- filtered_df %>% filter(as.character(lum) %in% input$selected_lum)
      }
    }
    
    if (!is.null(input$selected_atm)) {
      if (is.character(dta$atm) || is.factor(dta$atm)) {
        filtered_df <- filtered_df %>% filter(as.character(atm) %in% input$selected_atm)
      }
    }
    
    if (!is.null(input$selected_catr)) {
      if (is.character(dta$catr) || is.factor(dta$catr)) {
        filtered_df <- filtered_df %>% filter(as.character(catr) %in% input$selected_catr)
      }
    }
    
    # Répétez pour les autres variables, en vérifiant si elles sont des caractères ou des facteurs
    if (!is.null(input$selected_grav)) {
      if (is.character(dta$grav) || is.factor(dta$grav)) {
        filtered_df <- filtered_df %>% filter(as.character(grav) %in% input$selected_grav)
      }
    }
    
    if (!is.null(input$selected_surf)) {
      if (is.character(dta$surf) || is.factor(dta$surf)) {
        filtered_df <- filtered_df %>% filter(as.character(surf) %in% input$selected_surf)
      }
    }
    
    if (!is.null(input$selected_sexe)) {
      if (is.character(dta$sexe) || is.factor(dta$sexe)) {
        filtered_df <- filtered_df %>% filter(as.character(sexe) %in% input$selected_sexe)
      }
    }
    
    if (!is.null(input$selected_age)) {
      if (is.character(dta$age) || is.factor(dta$age)) {
        filtered_df <- filtered_df %>% filter(as.character(age) %in% input$selected_age)
      }
    }
    
    if (!is.null(input$selected_trajet)) {
      if (is.character(dta$trajet) || is.factor(dta$trajet)) {
        filtered_df <- filtered_df %>% filter(as.character(trajet) %in% input$selected_trajet)
      }
    }
    
    if (!is.null(input$selected_equipement)) {
      if (is.character(dta$equipement) || is.factor(dta$equipement)) {
        filtered_df <- filtered_df %>% filter(as.character(equipement) %in% input$selected_equipement)
      }
    }
    
    if (!is.null(input$selected_casque)) {
      if (is.character(dta$casque) || is.factor(dta$casque)) {
        filtered_df <- filtered_df %>% filter(as.character(casque) %in% input$selected_casque)
      }
    }
    
    if (!is.null(input$selected_git)) {
      if (is.character(dta$git) || is.factor(dta$git)) {
        filtered_df <- filtered_df %>% filter(as.character(git) %in% input$selected_git)
      }
    }
    
    if (!is.null(input$selected_equipement_autre)) {
      if (is.character(dta$equipement_autre) || is.factor(dta$equipement_autre)) {
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


# Réactif pour récupérer les valeurs de la sélection du département et de l'année
selected_data <- reactive({
  req(input$selected_depp, input$selected_yearr)
  dta %>% 
    filter(dep == input$selected_depp, an == input$selected_yearr)
})


# Modèle ARIMA : prédiction du nombre d'accidents
prediction_arima <- reactive({
  req(input$param_pred)  # Attend que le bouton soit cliqué
  
  # Filtrage des données pour le département sélectionné
  dep_data <- dta %>% 
    filter(dep == input$selected_depp) %>%
    group_by(an, mois) |>
    summarise(Accidents = n()) |>
    rename(Année = an, Mois = mois)
  
  # Créer une série temporelle à partir des données agrégées
  accidents_ts <- ts(dep_data$Accidents)
  
  # Ajuster le modèle ARIMA
  t = 1:length(accidents_ts)
  x = outer(t, 1:6)*(pi/6)
  df = data.frame(acc = accidents_ts, t = t, cos = cos(x), sin = sin(x))
  df <- df[-ncol(df)]
  
  mod <- Arima(accidents_ts, c(2,1,2), xreg = as.matrix(df[,-1])) # ordre (2,1,2) par sécurité
  
  nb_periodes = 12*(as.numeric(input$selected_yearr) - 2021)
  
  t <- (length(accidents_ts) + 1):(length(accidents_ts) + nb_periodes)
  x <- outer(t, 1:6)*(pi/6)
  df <- data.frame(t = t, cos = cos(x), sin = sin(x))
  df <- df[-ncol(df)]
  
  c <- generics::forecast(mod, h = nb_periodes, xreg = as.matrix(df))
  
  pred_acc <- c$mean %>%
    ifelse(. > 0, ., 0) |>
    tail(12) |>
    sum() |>
    round()
  
  return(pred_acc)
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


