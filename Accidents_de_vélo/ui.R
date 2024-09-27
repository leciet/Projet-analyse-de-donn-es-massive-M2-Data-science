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
library(DT)
library(plotly)

load("don.RData")
var_analyse <- names(don)[c(2:5,10:18,20,21)]

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
                                        DTOutput("donnees")
                                        )
                                 )
                             ))
                    ),
           # 2ème onglet analyse stats =========================================
           navbarMenu("Analyse",
                      tabPanel("Analyse univariée",
                               fluidRow(column(3,
                                               selectInput('varuni',
                                                           label = 'Variable à représenter',
                                                           choices = setNames(var_analyse,
                                                                              c("Année", "Mois", "Jour", "Heure",
                                                                                "Agglomération", "Luminosité", "Météo", 
                                                                                "Type de route", "Type de surface", 
                                                                                "Gravité", "Sexe", "Âge", "Type de trajet", 
                                                                                "Port de casque", "Port de gilet"))),
                                               sliderInput('annee',
                                                           label = 'Plage temporelle',
                                                           min = 2005,
                                                           max = 2021,
                                                           value = c(2005, 2021),
                                                           sep = '')),
                                        column(9,
                                               plotlyOutput('graph_uni')))),
                
                      tabPanel("Analyse multivariée",
                               fluidRow(column(3,
                                               selectInput('varmulti',
                                                           label = 'Variable à représenter',
                                                           choices = setNames(var_analyse[-c(5,10,11,14:15)],
                                                                              c("Année", "Mois", "Jour", "Heure",
                                                                                "Luminosité", "Météo", "Type de route", 
                                                                                "Type de surface", "Âge", "Type de trajet"))),
                                               "Remarque : les variables à 2 modalités ont été retirées."),
                                        column(9,
                                               plotOutput('plot_CA'))))
                      ),
           # 3ème onglet analyse spatio-temp ===================================
           tabPanel("Analyse spatio-temporelle"
                    )
           )
