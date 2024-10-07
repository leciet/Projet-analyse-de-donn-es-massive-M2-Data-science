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
      setView( lng = 2, lat = 46.5, zoom = 6 ) %>% 
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
                                      dta$sexe , dta$age , "<BR>",
                                      "<B>Casque</B>: ", dta$casque, "<BR>",
                                      "<B>Gilet réfléchissant</B>: ", dta$gilet, "<BR>",
                                      "<B>Autre</B>: ", dta$equipement_autre, "<BR>"))
        } 
    m
  })
})

output$donnees1 <- renderDT({
  input$parametres13
  isolate({don[,input$colDt1] %>% 
      filter(date<=input$dateDt1[2]) %>%
      filter(date >=input$dateDt1[1])
    })
  })


output$graph12 <- renderPlotly({
  input$parametres12
  isolate({
    if (input$typegraph12=='Total') {
    graph12 <- don %>% 
      ggplot()+
      aes(x=an)+
      geom_density(aes(y=after_stat(count)),position = 'stack',fill='grey')+
      ylab("Nombre d'accidents")+
      xlab("Année")
  } else {
    graph12 <- don %>% 
      ggplot()+
      aes(x=an,fill = grav)+
      geom_density(aes(y=after_stat(count)),position = 'stack')+
      ylab("Nombre d'accidents")+
      xlab("Année")
  }
    ggplotly(graph12,tooltip = 'text')})
  
})



