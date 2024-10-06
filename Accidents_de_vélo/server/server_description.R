# Carte ========================================================================
observe(
# Verification que la gravite est selectionne pour la carte -- -- -- -- -- -- --
if (is.null(input$gravMap1)) {
  #Enable the run button
  shinyjs::disable("parametres11")
  } else {
    #Disable the run button
    shinyjs::enable("parametres11")
  })

# Let's read the downloaded geoJson file with the sf library:
library(sf)
# dep <- read_sf('Accidents_de_vélo/server/departements.geojson')

output$leaflet <- renderLeaflet({
  input$parametres11
  isolate({
    Palette <- colorFactor(palette = c("tomato",'skyblue2',"royalblue", "red3"),
                           domain = c('Indemne','Blessé léger','Blessé hospitalisé','Tué'))
    dta <- don %>% 
      filter(date<=input$dateMap1[2]) %>% 
      filter(date >=input$dateMap1[1])
    dta <- filter(dta,grav == input$gravMap1)
    m <- leaflet(data = dta) %>% 
      addTiles()%>%
      setView( lng = 2, lat = 46, zoom = 5 ) %>% 
      addLegend(values = ~grav,
                    pal = Palette,
                    position = 'bottomright',
                    title = "Gravité des blessures")
    if(input$clusterMap1==FALSE){
      m <- m %>% addCircleMarkers(~long,~lat,
                                  color = ~Palette(grav),
                                  clusterOptions = markerClusterOptions())
      }else{
        m <- m %>% addCircleMarkers(~long,~lat,
                                    color = ~Palette(grav),
                                    popup = paste(
                                      dta$sexe , dta$age , " ans<BR>",
                                      "<B>Casque</B>: ", dta$casque, "<BR>",
                                      "<B>Gilet réfléchissant</B>: ", dta$gilet, "<BR>",
                                      "<B>Autre</B>: ", dta$equipement_autre, "<BR>"))
        } 
    m
  })
})


output$donnees <- renderDT({
  input$parametres13
  isolate({datatable(don[,input$coldt] %>% 
                                        filter(date<=input$dateDt1[2]) %>% 
                                        filter(date >=input$dateDt1[1]) )
    })
  })



don %>% filter(date<='2005-1-19') %>% 
  filter(date >= '2005-1-19')
