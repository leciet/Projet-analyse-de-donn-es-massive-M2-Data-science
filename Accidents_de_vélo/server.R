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


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  # Charger les données
  load("server/don.RData")
  cd <- read_excel("server/Centre_departement.xlsx", skip = 1)
  cd$`ɸ (° ' "")` <- gsub(" ", "", cd$`ɸ (° ' "")`)
  cd$`ɸ (° ' "")` <- char2dms(cd$`ɸ (° ' "")`, chd='°', chm="'", chs='"') %>% as.numeric()
  cd$`Ʌ (° ' "")` <- char2dms(cd$`Ʌ (° ' "")`, chd='°', chm="'", chs='"') %>% as.numeric()
  names(cd)[1] <- "dep"
  names(cd)[5] <- "lat"
  names(cd)[4] <- "long"
  merged_df <- merge(don, cd[, c("dep", "lat", "long")], by = "dep", all.x = TRUE, suffixes = c("_ancien", "_nouveau"))
  head(merged_df)
  condition <- merged_df$lat_ancien == 0 | is.na(merged_df$lat_ancien)
  merged_df$lat_ancien[condition] <- merged_df$lat_nouveau[condition]
  
  condition2 <- merged_df$long_ancien == 0 | is.na(merged_df$long_ancien)
  merged_df$long_ancien[condition2] <- merged_df$long_nouveau[condition2]
  
  data <- merged_df %>% select(-lat_nouveau, -long_nouveau)
  head(data)
  colnames(data)
  data$dep <- as.character(data$dep)
  unique(data$dep)
  
  # Préparation des données pour les cartes de gravité
  lat_long <- data %>%
    group_by(dep) %>%
    summarise(
      lat = mean(lat_ancien, na.rm = TRUE),  # Moyenne de la latitude
      long = mean(long_ancien, na.rm = TRUE),
      n_observations = n()# Moyenne de la longitude
    )
  mois_levels <- c("janvier", "février", "mars", "avril", "mai", "juin", 
                   "juillet", "août", "septembre", "octobre", "novembre", "décembre")
  mois_labels <- c("janvier", "février", "mars", "avril", "mai", "juin", 
                   "juillet", "août", "septembre", "octobre", "novembre", "décembre")
  
  # Vérifier si la colonne est déjà un facteur
  if (!is.factor(don$mois)) {
    don$mois <- factor(don$mois, levels = mois_levels, labels = mois_labels, ordered = TRUE)
  }
  
  # Créer un tableau avec le nombre d'accidents par année
  accidents_by_year <- as.data.frame(table(don$an))
  colnames(accidents_by_year) <- c("year", "number_of_accidents")
  accidents_by_year$year <- as.numeric(as.character(accidents_by_year$year))
  
  accidents_ts <- ts(accidents_by_year$number_of_accidents, 
                     start = as.numeric(min(accidents_by_year$year)), 
                     end = as.numeric(max(accidents_by_year$year)), 
                     frequency = 1)
  head(lat_long)
  
  data_global <- data %>%
    group_by(dep) %>%
    summarise(
      lat = mean(lat_ancien, na.rm = TRUE),
      long = mean(long_ancien, na.rm = TRUE),
      nombre_lignes = n(),
      femmes = sum(sexe == "Feminin", na.rm = TRUE),
      hommes = sum(sexe == "Masculin", na.rm = TRUE)
    ) %>%
    mutate(
      pourcentage_femmes = (femmes / nombre_lignes) * 100,
      pourcentage_hommes = (hommes / nombre_lignes) * 100
    ) %>%
    select(dep, nombre_lignes, pourcentage_femmes, pourcentage_hommes, lat, long)
  source("server/server_description.R", local = TRUE)
  source("server/server_spatio_temp.R", local = TRUE)
  })

