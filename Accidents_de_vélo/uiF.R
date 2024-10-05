library(installr)
#updateR()
library(forecast)
library(tseries)
library(shiny)
library(leaflet)
library(leaflet.minicharts)
library(sp)
library(magrittr)
library(readxl)
library(dplyr)
library(DT)
library(shinyjs)
#install.packages("shinyalert")
library(shinyalert)

library(tidyverse)  # Load the tidyverse package

# Charger les données
load("C:/Users/pc/Desktop/M2_Rennes/GIT/PRJ/P2/Projet-analyse-de-donn-es-massive-M2-Data-science/don.RData")
cd <- read_excel("C:/Users/pc/Desktop/M2_Rennes/GIT/PRJ/P2/Projet-analyse-de-donn-es-massive-M2-Data-science/Centre_departement.xlsx", skip = 1)
cd$`ɸ (° ' "")` <- gsub(" ", "", cd$`ɸ (° ' "")`)
cd$`ɸ (° ' "")` <- char2dms(cd$`ɸ (° ' "")`, chd='°', chm="'", chs='"') %>% as.numeric()
cd$`Ʌ (° ' "")` <- char2dms(cd$`Ʌ (° ' "")`, chd='°', chm="'", chs='"') %>% as.numeric()
names(cd)[1] <- "dep"
names(cd)[5] <- "lat"
names(cd)[4] <- "long"
merged_df <- merge(don, cd[, c("dep", "lat", "long")], by = "dep", all.x = TRUE, suffixes = c("_ancien", "_nouveau"))
head(merged_df)
condition <- merged_df$lat_ancien == 0 | is.na(merged_df$lat_ancien)
merged_df$lat_ancien[condition] <- merged_df$lat_nouveau[condition]

condition2 <- merged_df$long_ancien == 0 | is.na(merged_df$long_ancien)
merged_df$long_ancien[condition2] <- merged_df$long_nouveau[condition2]

data <- merged_df %>% select(-lat_nouveau, -long_nouveau)
head(data)
colnames(data)
data$dep <- as.character(data$dep)
unique(data$dep)

# Préparation des données pour les cartes de gravité
lat_long <- data %>%
  group_by(dep) %>%
  summarise(
    lat = mean(lat_ancien, na.rm = TRUE),  # Moyenne de la latitude
    long = mean(long_ancien, na.rm = TRUE),
    n_observations = n()# Moyenne de la longitude
  )
mois_levels <- c("janvier", "février", "mars", "avril", "mai", "juin", 
                 "juillet", "août", "septembre", "octobre", "novembre", "décembre")
mois_labels <- c("janvier", "février", "mars", "avril", "mai", "juin", 
                 "juillet", "août", "septembre", "octobre", "novembre", "décembre")

# Vérifier si la colonne est déjà un facteur
if (!is.factor(don$mois)) {
  don$mois <- factor(don$mois, levels = mois_levels, labels = mois_labels, ordered = TRUE)
}

# Créer un tableau avec le nombre d'accidents par année
accidents_by_year <- as.data.frame(table(don$an))
colnames(accidents_by_year) <- c("year", "number_of_accidents")
accidents_by_year$year <- as.numeric(as.character(accidents_by_year$year))

accidents_ts <- ts(accidents_by_year$number_of_accidents, 
                   start = as.numeric(min(accidents_by_year$year)), 
                   end = as.numeric(max(accidents_by_year$year)), 
                   frequency = 1)
head(lat_long)




# Définition de l'interface utilisateur (UI)
ui <- navbarPage(
  title = "Accidents de vélo en France",
  # Ajout de CSS pour forcer l'occupation de la hauteur complète
  tags$head(
    tags$style(
      HTML("
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      .navbar {
        margin-bottom: 0;
      }
      .tab-content {
        height: 100%;
      }
      #leaflet, #map_sexe, #map_gravite {
        height: 100vh !important;
      }
       .custom-select {
      width: 100%;  /* ou une autre largeur selon vos besoins */
      padding: 2px;  /* réduire l'espace autour du texte */
      height: 30px;
      margin-bottom: 5px;
      font-size: 8px;  /* diminuer la taille de la police */
    }
      ")
    )
  ),
  # 1er onglet: Description
  tabPanel(
    title = "Description",
    HTML("<h1> Contexte </h1>
          <body> Petite description ici</body>
          <hr>"),
    fluidRow(
      tabsetPanel(
        # Carte générale
        tabPanel(
          "Carte",
          column(
            width = 4,
            wellPanel("Paramètres", style = "background : skyblue"),
            actionButton('parametres11', 'Valider')
          ),
          column(width = 8, leafletOutput("leaflet"))
        ),
        
        # Graphiques de base
        tabPanel(
          "Graphiques",
          column(
            width = 4,
            wellPanel("Paramètres", style = "background : lightgreen"),
            actionButton('parametres12', 'Valider')
          ),
          column(width = 8)
        ),
        
        # Table de données
        tabPanel(
          "Données",
          column(
            width = 4,
            wellPanel("Paramètres", style = "background : khaki"),
            actionButton('parametres13', 'Valider')
          ),
          column(
            width = 8,
            DT::DTOutput("donnees")
          )
        )
      )
    )
  ),
  
  # 2ème onglet: Analyse statistique
  navbarMenu(
    "Analyse",
    tabPanel("Analyse univariée"),
    tabPanel("Analyse bivariée"),
    tabPanel("Analyse multivariée")
  ),
  
  # 3ème onglet: Analyse spatio-temporelle
  navbarMenu(
    "Analyse spatio-temporelle",
    tabPanel(
      "Analyse spatiale",
      tabsetPanel(
        tabPanel(
          "Évolution en fonction du sexe",
          fluidRow(
            column(
              width = 4,
              wellPanel("Chiffres par sexe", style = "background: lightblue"),
              selectInput("selected_dep", "Sélectionnez un département", choices = unique(data$dep)),
              selectInput("selected_year", "Sélectionnez une année", choices = unique(data$an)),
              actionButton('param_sexe', 'Valider'),
              actionButton('param_sexe_2', 'réinitialiser')  # Nouveau bouton ici
              
            ),
            column(
              width = 5,
              leafletOutput("map_sexe")  # Carte à afficher ici
            )
          )
        ),
        tabPanel(
          "Évolution par gravité",
          fluidRow(
            column(
              width = 2,
              wellPanel("Evolution en fonction de la gravité", style = "background: lightcoral")
              #actionButton('param_gravite', 'Valider')
            ),
            column(
              width = 8,
              leafletOutput("map_gravite")  # Carte de gravité ici
            )
          )
        ),
        tabPanel(
          "Formulaire ouvert",
          fluidRow(
            column(
              width = 3,
              wellPanel("Formulaire", style = "background: lightgreen"),
              selectInput("selected_dep", "Département", choices = unique(data$dep), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_an", "Année", choices = unique(data$an), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_mois", "Mois", choices = unique(data$mois), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_lum", "Luminosité", choices = unique(data$lum), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_atm", "Atmosphère", choices = unique(data$atm), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_catr", "Catégorie", choices = unique(data$catr), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_grav", "Gravité", choices = unique(data$grav), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_surf", "Surface", choices = unique(data$surf), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_sexe", "Sexe", choices = unique(data$sexe), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_age", "Âge", choices = unique(data$age), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_trajet", "Trajet", choices = unique(data$trajet), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_equipement", "Équipement", choices = unique(data$equipement), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_casque", "Casque", choices = unique(data$casque), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_git", "Git", choices = unique(data$git), multiple = TRUE,
                          tags$select(class = "custom-select")),
              selectInput("selected_equipement_autre", "Équipement Autre", choices = unique(data$equipement_autre), multiple = TRUE,
                          tags$select(class = "custom-select")),
              actionButton('val_frm', 'Valider')
            ),
            column(
              width = 8,
              leafletOutput("map")  # Carte à afficher ici
            )
            
          )
          #textInput("input_text", "Entrez vos commentaires ici"),
          # actionButton('submit_form', 'Soumettre')
          
        )
      )
    ),
    tabPanel(
      "Étude de la saisonnalité",
      tabsetPanel(
        tabPanel(
          "Évolution anuelle",
          
      plotOutput("serieTemporellePlot")),
    tabPanel("Évolution mensuelle",
             plotOutput("saisonalitePlot")),
    tabPanel("Serie temporelle", 
             sidebarLayout(
               sidebarPanel(
                 sliderInput("yearInput", 
                             "Choisissez une année pour la prévision :", 
                             min = min(accidents_by_year$year), 
                             max = max(accidents_by_year$year) + 24, # Allow forecasting into the future
                             value = max(accidents_by_year$year))
               ),
               
               mainPanel(
             plotOutput("forecastPlot")))
    
      
    ))),
    tabPanel(
      "Prédiction",
      fluidRow(
        column(
          width = 12,
          wellPanel("Modèle de prédiction", style = "background: lightyellow"),
          selectInput("selected_depp", "Sélectionnez un département", choices = unique(data$dep)),
          selectInput("selected_yearr", "Sélectionnez une année", choices = unique(seq(max(data$an) + 1, max(data$an) + 30))),
          actionButton('param_pred', 'Afficher la prédiction')
          #textOutput("prediction_result"),
          
            # Carte de gravité ici
          )
        )
      )
    
  )
)




server <- function(input, output, session) {
  data_global <- data %>%
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
  
  # Initialiser la carte `map_sexe` au démarrage
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
      req(input$selected_dep, input$selected_an, input$selected_mois) # Require at least these three filters
      
      # Commencez par le DataFrame complet
      filtered_df <- data
      
      # Appliquer les filtres selon les choix de l'utilisateur
      if (!is.null(input$selected_dep)) {
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

 output$saisonalitePlot <- renderPlot({
  ggplot(don, aes(x = mois)) +
    geom_bar() +
    labs(title = "Nombre d'accidents de vélo par mois (saisonnalité)", 
         x = "Mois", 
         y = "Nombre d'accidents") +
    theme_minimal()
})

 output$serieTemporellePlot <- renderPlot({
  accidents_ts <- ts(accidents_by_year$number_of_accidents, 
                     start = min(accidents_by_year$year), 
                     end = max(accidents_by_year$year), 
                     frequency = 1)
  plot(accidents_ts, 
       main = "Nombre d'accidents de vélo par année", 
       xlab = "Année", 
       ylab = "Nombre d'accidents")
}) 
 # Prévisions ARIMA
 output$forecastPlot <- renderPlot({
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
 
 
 
}
# Lancer l'application Shiny
shinyApp(ui = ui, server = server)


