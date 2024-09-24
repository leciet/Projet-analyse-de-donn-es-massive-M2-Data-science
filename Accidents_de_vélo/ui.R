#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

# Define UI for application that draws a histogram
navbarPage(title = "Accidents de vélo en France",
           
           tabPanel(title = "Description",
                    "Petite description du contexte et des enjeux",
                    fluidRow(
                      column(width = 4, 
                             wellPanel("Paramètres")
                             ),
                      column(width = 8, "Petit schéma")
                    )
                    ),
           
           navbarMenu("Analyse",
                      tabPanel("ACP"),
                      tabPanel("Analyse spatio-temporelle")
                      )
           )
