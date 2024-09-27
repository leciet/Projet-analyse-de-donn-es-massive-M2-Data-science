#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(DT)

load("don.RData")

# Define server logic required to draw a histogram
function(input, output, session) {
    
    output$leaflet <- renderLeaflet({m <- leaflet() %>% 
                                      addTiles()
                                    m
                                    }
                                    )
    output$donnees <- renderDT({dta})
    
    source("an_uni.R", local = T)
    source("an_multi.R", local = T)
}
