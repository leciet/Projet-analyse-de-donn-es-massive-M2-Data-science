tabPanel(title = "Description",
         HTML("<h1> Contexte </h1>
                          <body> Selon l'Observatoire national interministériel de la sécurité routière (ONISR), le risque pour un cycliste d’être victime d’un accident est <b>trois fois plus élevé</b> que pour un automobiliste. Le risque d’être gravement blessé est quant à lui <b>seize fois plus élevé</b>.<br/>
                          Pour lutter contre ce phénomène, le gouvernement a mis en place plusieurs règles de sécurité routière.Ainsi, le port d'un gilet réfléchissant et la présence d'un système d'éclairage et sonore est obligatoire et le port du casque est vivement recommandé. 
                          A ces mesures s'ajoute le développement de pistes cyclabes dans les agglomérations françaises et de nombreuses campagnes sur la sécurité routière. En 2018 notamment, la vitesse sur les routes départementales a été diminué à 80km/h. Mais ces mesures sont-elles suffisantes ?</body><br/>
                          <h4>Observe-t-on un changement dans le nombre et la gravité des accidents et/ou de l'usage d'équipement ces dernières années ?</h4>
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
                                       selectInput(inputId = "coldt13",
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
                             DTOutput("donnees")
                             )
           ))
))
