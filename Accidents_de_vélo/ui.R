#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#
library(installr)
#updateR()
library(forecast)
library(tseries)
library(leaflet)
library(leaflet.minicharts)
library(sp)
library(magrittr)
library(readxl)
library(DT)
library(shinyjs)
#install.packages("shinyalert")
library(shinyalert)
library(tidyverse)  # Load the tidyverse package
library(shiny)
library(jsonlite)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage(title = "Accidents de vélo en France",
             # Ajout de CSS pour forcer l'occupation de la hauteur complète
             tags$head(
               tags$style(
               HTML("html, 
               body {
               height: 100%;
               margin: 0;
               padding: 0;
               }
               .navbar {
               margin-bottom: 0;
               }
               .tab-content {
               height: 100%;
               }
               #leaflet, #map_sexe, #map_gravite {
               height: 100vh !important;
               }
               .custom-select {
               width: 100%;  /* ou une autre largeur selon vos besoins */
               padding: 2px;  /* réduire l'espace autour du texte */
               height: 30px;
               margin-bottom: 5px;
               font-size: 8px;  /* diminuer la taille de la police */
               }")
               )
               ),
             useShinyjs(),
             # 1er onglet description ==========================================
             source("ui/ui_description.R",local = TRUE)$value,
             
             # 2ème onglet analyse stats =======================================
             navbarMenu("Analyse",
                        tabPanel("Analyse univariée"),
                        tabPanel("Analyse bivariée"),
                        tabPanel("Analyse multivariée")
                        ),
           # 3ème onglet analyse spatio-temp ===================================
           source("ui/ui_spatio_temp.R",local = TRUE)$value
           )
)
