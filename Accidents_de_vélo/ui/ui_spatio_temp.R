
navbarMenu(
  "Analyse spatio-temporelle",
  tabPanel(
    "Analyse spatiale",
    fluidPage(
      h2('Analyse spatiale'),
      p("Vous pouvez ici explorer directement la répartition spatiale des accidents selon leur gravité."),
      p("Les accidents sont regroupés par département et peuvent être visualisés sur la carte de la France ci-dessous."),
      p(em("Remarque : les valeurs sur la représentation spatiale sont en pourcentage")),
      tabsetPanel(
        tabPanel(
          "Représentation spatiale",
          fluidRow(
            column(
              width = 4,
              wellPanel(h2("Paramètres"),
                        selectInput("selected_dep", "Sélectionnez un département", 
                                    choices = unique(data$dep)),
                        selectInput("selected_year", "Sélectionnez une année", choices = 2005:2021)),
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
          "Représentation temporelle",
          fluidRow(
            column(
              width = 2
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
              wellPanel(h2("Paramètres"),
                        selectInput("selected_dep2", "Département*", choices = unique(data$dep), multiple = TRUE,
                                    tags$select(class = "custom-select")),
                        selectInput("selected_an", "Année*", choices = unique(data$an), multiple = TRUE,
                                    tags$select(class = "custom-select")),
                        selectInput("selected_mois", "Mois*", choices = unique(data$mois), multiple = TRUE,
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
                                    tags$select(class = "custom-select"))),
              actionButton('val_frm', 'Valider'),
              HTML("<i style = 'color:red'>* Champs obligatoires</i>")
            ),
            column(
              width = 8,
              leafletOutput("map")  # Carte à afficher ici
            )
            
          )
          #textInput("input_text", "Entrez vos commentaires ici"),
          # actionButton('submit_form', 'Soumettre')
          
        )
      ))
  ),
  tabPanel(
    "Étude de la saisonnalité",
    fluidPage(
      h2("Étude de la saisonnalité"),
      p("Visualisez l'évolution du nombre d'accidents sur les années, puis sur les mois."),
      p("La saisonnalité est cruciale à prendre en compte dans l'évaluation du modèle prédictif."),
    tabsetPanel(
      tabPanel(
        "Évolution anuelle",
        plotlyOutput("serieTemporellePlot")),
      tabPanel("Évolution mensuelle",
               plotlyOutput("saisonalitePlot")),
      tabPanel("Serie temporelle", 
               sidebarLayout(
                 sidebarPanel(
                   h2("Paramètres"),
                   selectInput('type_ts', choices = levels(don$grav),label = 'Gravité des blessures'),
                   selectInput('annee_pred', choices = c(as.character(2022:2040)),label = 'Année de prévision'),
                   actionButton('parametres_serie_temp',label = 'Valider')
                 ),
                 
                 mainPanel(
                   plotlyOutput("graph_ts")))
      )))),
  tabPanel(
    "Prédiction",
    fluidRow(
      column(
        width = 12,
        wellPanel(h1("Modèle de prédiction"),
                  h2("Paramètres"),
                  selectInput("selected_depp", "Sélectionnez un département", choices = unique(data$dep)),
                  selectInput("selected_yearr", "Sélectionnez une année", choices = unique(seq(max(data$an) + 1, max(data$an) + 30))),
                  actionButton('param_pred', 'Afficher la prédiction'))
        #textOutput("prediction_result"),
        
        # Carte de gravité ici
      )
    )
  )
  
)


