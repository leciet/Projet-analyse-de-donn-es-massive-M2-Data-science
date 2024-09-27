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

# Define UI for application that draws a histogram
shinyUI(
  navbarPage(title = "Accidents de vélo en France",
             # 1er onglet description ==========================================
             source("ui/ui_description.R",local = TRUE)$value,
             
             # 2ème onglet analyse stats =======================================
             navbarMenu("Analyse",
                        tabPanel("Analyse univariée"),
                        tabPanel("Analyse bivariée"),
                        tabPanel("Analyse multivariée")
                        ),
           # 3ème onglet analyse spatio-temp ===================================
           tabPanel("Analyse spatio-temporelle"
                    )
           )
)
