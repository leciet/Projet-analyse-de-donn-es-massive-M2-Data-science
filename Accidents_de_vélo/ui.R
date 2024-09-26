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

# Define UI for application that draws a histogram
navbarPage(title = "Accidents de vélo en France",
           # 1er onglet description ============================================
           tabPanel(title = "Description",
                    HTML("<h1> Contexte </h1>
                          <body> Petite description ici</body>
                         <hr>"),
                    fluidRow(
                      tabsetPanel(
                        tabPanel("Carte",
                                 column(width = 4,
                                        wellPanel("Paramètres",
                                                  style = "background : skyblue")
                                        ),
                                 column(width = 8,
                                        leafletOutput("leaflet")
                                        )
                                 ),
                        tabPanel("Graphiques"),
                        tabPanel("Données",
                                 dataTableOutput("donnees"))
                             ))
                    ),
           # 2ème onglet analyse stats =========================================
           navbarMenu("Analyse",
                      tabPanel("Analyse univariée"),
                      tabPanel("Analyse bivariée"),
                      tabPanel("Analyse multivariée")
                      ),
           # 3ème onglet analyse spatio-temp ===================================
           tabPanel("Analyse spatio-temporelle"
                    )
           )
