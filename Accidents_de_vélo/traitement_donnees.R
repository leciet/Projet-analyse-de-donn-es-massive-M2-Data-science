load("don.RData")

# Define server logic required to draw a histogram
cd <- read_excel("Centre_departement.xlsx", skip = 1)
cd$`ɸ (° ' "")` <- gsub(" ", "", cd$`ɸ (° ' "")`)
cd$`ɸ (° ' "")` <- char2dms(cd$`ɸ (° ' "")`, chd='°', chm="'", chs='"') %>% as.numeric()
cd$`Ʌ (° ' "")` <- char2dms(cd$`Ʌ (° ' "")`, chd='°', chm="'", chs='"') %>% as.numeric()
names(cd)[1] <- "dep"
names(cd)[5] <- "lat"
names(cd)[4] <- "long"
cd$dep <- as.factor(cd$dep)

don$dep <- as.character(don$dep)
for (i in 1:9) don$dep[don$dep == as.character(i)] <- paste('0', i, sep = '')
don$dep <- as.factor(don$dep)

merged_df <- left_join(don, cd[, c("dep", "lat", "long")], by = "dep", suffix = c("_ancien", "_nouveau"))

dta <- merged_df

# Préparation des données pour les cartes de gravité
lat_long <- dta %>%
  group_by(dep) %>%
  summarise(
    lat = mean(lat_nouveau, na.rm = TRUE),  # Moyenne de la latitude
    long = mean(long_nouveau, na.rm = TRUE),
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

data_global <- dta %>%
  group_by(dep) %>%
  summarise(
    lat = mean(lat_nouveau, na.rm = TRUE),
    long = mean(long_nouveau, na.rm = TRUE),
    nombre_lignes = n(),
    femmes = sum(sexe == "Feminin", na.rm = TRUE),
    hommes = sum(sexe == "Masculin", na.rm = TRUE)
  ) %>%
  mutate(
    pourcentage_femmes = round((femmes / nombre_lignes) * 100),
    pourcentage_hommes = round((hommes / nombre_lignes) * 100)
  ) %>%
  select(dep, nombre_lignes, pourcentage_femmes, pourcentage_hommes, lat, long)  
