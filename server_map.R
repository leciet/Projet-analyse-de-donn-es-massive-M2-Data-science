library(leaflet)


Palette <- colorFactor(palette = c("lightgreen",'yellow2',"orange1", "red2"),
                               domain = c('Indemne','Blessé léger','Blessé hospitalisé','Tué'))


m <- leaflet(data = don) %>% 
  addTiles()%>% 
  setView( lng = 2, lat = 46, zoom = 5 ) %>% 
  addCircleMarkers(~long,~lat,
                   color = ~Palette(grav))
m

1: runApp
Error in file(filename, "r", encoding = encoding) : 
  impossible d'ouvrir la connexion
