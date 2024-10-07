
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
            selectInput("selected_dep2", "Département", choices = unique(data$dep), multiple = TRUE,
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


