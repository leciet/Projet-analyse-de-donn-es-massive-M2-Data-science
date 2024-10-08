tabPanel(title = "Description",
         HTML("<h1> Contexte </h1>
                          <body> Selon l'Observatoire national interministériel de la sécurité routière (ONISR), un cycliste a <b>trois fois plus</b> de risques d’être impliqué dans un accident qu’un automobiliste, et <b>seize fois plus</b> de chances d’être gravement blessé. <br/>
                          Pour réduire ces risques, le gouvernement a mis en place plusieurs mesures : port obligatoire du gilet réfléchissant, système d’éclairage et sonore, et recommandation du port du casque. Le développement des pistes cyclables et les campagnes de sensibilisation accompagnent ces actions. En 2018, la vitesse sur les routes départementales a aussi été réduite à 80 km/h. Mais ces mesures suffisent-elles ? </body><br/>
                          <h4>Le nombre et la gravité des accidents ont-ils diminué, et observe-t-on une meilleure adoption des équipements de sécurité ces dernières années ?</h4>
                          <hr>"),
         fluidRow(
           tabsetPanel(
             # Carte générale -- -- -- -- -- -- -- -- -- -- -- -- --
             tabPanel("Carte",
                      fluidRow(
                        column(width = 4,
                             wellPanel(h2("Paramètres"),
                                       # clustering 
                                       checkboxInput(inputId = 'clusterMap1',
                                                     label = "Détailler la carte",
                                                     value = FALSE),
                                       # choix de la gravité à afficher
                                       selectInput(inputId = "gravMap1",
                                                   label = "Gravité de l'accident *",
                                                   selected = levels(don$grav),
                                                   choices = levels(don$grav),
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
                             HTML("<i style = 'color:red'>* Sélectionner au moins 1 argument</i>")
                      ),
                      column(width = 8,
                             leafletOutput("leaflet")))
             ),
             
             # Graphiques de base -- -- -- -- -- -- -- -- -- -- -- --
             tabPanel("Graphiques",
                      fluidRow(
                        column(width = 4,
                             wellPanel(h2("Paramètres"),
                                       radioButtons('typegraph12',
                                                    label = 'Type de graphique',
                                                    choices = c('Total','Par gravité'),
                                                    selected = 'Total')),
                                       actionButton('parametres12','Valider')
                      ),
                      column(width = 8,
                             plotlyOutput('graph12'))
                      )
             ),
             
             # Table de données -- -- -- -- -- -- -- -- -- -- -- -- 
             tabPanel("Données",
                      fluidRow(
                        column(width = 4,
                             wellPanel(h2("Paramètres"),
                                       selectInput(inputId = "colDt1",
                                                   label = "Sélection des colonnes",
                                                   multiple = TRUE,
                                                   choices = colnames(data),
                                                   selected = c('date',
                                                                'dep',
                                                                'sexe',
                                                                'age',
                                                                'trajet',
                                                                'casque',
                                                                'gilet',
                                                                'equipement_autre',
                                                                'grav')
                                                   ),
                                       # choix des dates 
                                       dateRangeInput(inputId = "dateDt1", 
                                                      label = NULL,
                                                      start = "2005-01-01", 
                                                      end = "2021-12-31", 
                                                      format = "dd/mm/yyyy",
                                                      language = "fr", 
                                                      separator = " à ")
                                       ),
                             actionButton('parametres13','Valider')
                      ),
                      column(width = 7,
                             DTOutput("donnees1")
                             ))
           ))
))
