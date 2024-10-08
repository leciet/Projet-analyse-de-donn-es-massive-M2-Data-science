#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

source("server/traitement_donnees.R")
shinyServer(function(input, output, session) {
  
  # Charger les données
  source("server/server_description.R", local = TRUE)
  source("server/server_spatio_temp.R", local = TRUE)
  source("server/an_uni.R", local = T)
  source("server/an_multi.R", local = T)
  source("server/pred_ts.R",local = T)
  })

