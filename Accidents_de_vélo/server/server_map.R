
output$leaflet <- renderLeaflet({
  input$parametres11
  isolate({
    Palette <- colorFactor(palette = c("orange2",'yellow2',"lightgreen", "red2"),
                           domain = c('Indemne','Blessé léger','Blessé hospitalisé','Tué'))
    dta <- don %>% 
      filter(date<=input$dateMap1[2]) %>% 
      filter(date >=input$dateMap1[1])
    if( !is.null(input$gravMap1) ){
      (dta <- filter(dta,grav == input$gravMap1))
      } 
    m <- leaflet(data = dta) %>% 
      addTiles()%>%
      setView( lng = 2, lat = 46, zoom = 5 ) %>% 
      addCircleMarkers(~long,~lat,
                       color = ~Palette(grav))
      
    m
  })
})
output$donnees <- renderDT({don})



don %>% filter(date<='2005-1-19') %>% 
  filter(date >= '2005-1-19')
