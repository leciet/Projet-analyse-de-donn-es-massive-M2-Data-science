#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(leaflet)

load("don.RData")

# Define UI for application that draws a histogram
navbarPage(title = "Accidents de vélo en France",
           # 1er onglet description ============================================
           tabPanel(title = "Description",
                    HTML("<h1> Contexte </h1>
                          <body> Petite description ici</body>
                          <hr>"),
                    fluidRow(
                      tabsetPanel(
                        # Carte générale -- -- -- -- -- -- -- -- -- -- -- -- --
                        tabPanel("Carte",
                                 column(width = 4,
                                        wellPanel("Paramètres",
                                                  style = "background : skyblue"),
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
                                        dataTableOutput("donnees")
                                        )
                                 )
                             ))
                    ),
           # 2ème onglet analyse stats =========================================
           navbarMenu("Analyse",
                      tabPanel("Analyse univariée",
                               fluidRow(column(3,
                                               'Param'),
                                        column(9,
                                               'Output'))),
                      tabPanel("Analyse bivariée"),
                      tabPanel("Analyse multivariée")
                      ),
           # 3ème onglet analyse spatio-temp ===================================
           tabPanel("Analyse spatio-temporelle"
                    )
           )
