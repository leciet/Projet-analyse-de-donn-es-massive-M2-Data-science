tabPanel(title = "Description",
         HTML("<h1> Contexte </h1>
                          <body> Petite description ici</body>
                          <hr>"),
         fluidRow(
           tabsetPanel(
             # Carte générale -- -- -- -- -- -- -- -- -- -- -- -- --
             tabPanel("Carte",
                      column(width = 4,
                             wellPanel(h2("Paramètres"),
                                       style = "background : skyblue",
                                       # clustering 
                                       checkboxInput(inputId = 'clusterMap1',
                                                     label = "Détailler la carte",
                                                     value = FALSE),
                                       # choix de la gravité à afficher
                                       selectInput(inputId = "gravMap1",
                                                   label = "Gravité de l'accident *",
                                                   selected = "Indemne",
                                                   choices = c("Indemne", 
                                                               "Blessé léger",
                                                               "Blessé hospitalisé",
                                                               "Tué"),
                                                   multiple = TRUE
                                                          ),
                                       
                                       # choix des dates 
                                       dateRangeInput(inputId = "dateMap1", 
                                                      label = NULL,
                                                      start = "2005-01-01", 
                                                      end = "2021-12-31", 
                                                      format = "dd/mm/yyyy",
                                                      language = "fr", 
                                                      separator = " à ")
                                       ),
                             actionButton('parametres11','Valider',disabled = TRUE),
                             HTML("<h5 style = 'color:red'>* Sélectionner au moins 1 argument</h5>")
                      ),
                      column(width = 8,
                             leafletOutput("leaflet")
                      )
             ),
             
             # Graphiques de base -- -- -- -- -- -- -- -- -- -- -- --
             tabPanel("Graphiques",
                      column(width = 4,
                             wellPanel("Paramètres",
                                       style = "background : lightgreen"),
                             actionButton('parametres12','Valider')
                      ),
                      column(width = 8
                      )
             ),
             
             # Table de données -- -- -- -- -- -- -- -- -- -- -- -- 
             tabPanel("Données",
                      column(width = 4,
                             wellPanel(h2("Paramètres"),
                                       style = "background : khaki",
                                       selectInput(inputId = "coldt",
                                                   label = "Sélection des colonnes",
                                                   multiple = TRUE,
                                                   choices = colnames(don),
                                                   selected = c('date',
                                                                'dep',
                                                                'sexe',
                                                                'age',
                                                                'trajet',
                                                                'casque',
                                                                'gilet',
                                                                'equipement_autre',
                                                                'grav')
                                                   )
                                       ),
                             actionButton('parametres13','Valider')
                      ),
                      column(width = 7,
                             DTOutput("donnees")
                             )
           ))
))
