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
    Palette <- colorFactor(palette = c("orange2",'yellow2',"lightgreen", "red2"),
                           domain = c('Indemne','Blessé léger','Blessé hospitalisé','Tué'))
    dta <- don %>% 
      filter(date<=input$dateMap1[2]) %>% 
      filter(date >=input$dateMap1[1])
    dta <- filter(dta,grav == input$gravMap1)
    m <- leaflet(data = dta) %>% 
      addTiles()%>%
      setView( lng = 2, lat = 46, zoom = 5 )
    if(input$clusterMap1==FALSE){
      m <- m %>% addCircleMarkers(~long,~lat,
                                  color = ~Palette(grav),
                                  clusterOptions = markerClusterOptions())
      }else{
        m <- m %>% addCircleMarkers(~long,~lat,
                                    color = ~Palette(grav),popup = paste(
                                      dta$sexe , dta$age , "<BR>",
                                      "<B>Casque</B>: ", dta$casque, "<BR>",
                                      "<B>Gilet réfléchissant</B>: ", dta$gilet, "<BR>",
                                      "<B>Autre</B>: ", dta$equipement_autre)) %>% 
          addLegend(values = ~grav,
                    pal = Palette,
                    position = 'bottomright',
                    title = "Gravité des blessures")
        } 
    m
  })
})


output$donnees <- renderDT({datatable(don[,input$coldt])}
                           )



don %>% filter(date<='2005-1-19') %>% 
  filter(date >= '2005-1-19')
