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
                                       # choix de la gravité à afficher
                                       checkboxGroupInput(inputId = "gravMap1", 
                                                          label = "Gravité de l'accident", 
                                                          selected = "Indemne",
                                                          choices = c("Indemne", 
                                                                      "Blessé léger", 
                                                                      "Blessé hospitalisé",
                                                                      "Tué")
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
                             actionButton('parametres11','Valider')
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
                             wellPanel("Paramètres",
                                       style = "background : khaki"),
                             actionButton('parametres13','Valider')
                      ),
                      column(width = 8,
                             DTOutput("donnees")
                      )
             )
           ))
)