load("don.RData")

# Define server logic required to draw a histogram
cd <- read_excel("Centre_departement.xlsx", skip = 1)
cd$`ɸ (° ' "")` <- gsub(" ", "", cd$`ɸ (° ' "")`)
cd$`Ʌ (° ' "")` <- gsub("O", "W", cd$`Ʌ (° ' "")`)
cd$`ɸ (° ' "")` <- char2dms(cd$`ɸ (° ' "")`, chd='°', chm="'", chs='"') %>% as.numeric()
cd$`Ʌ (° ' "")` <- char2dms(cd$`Ʌ (° ' "")`, chd='°', chm="'", chs='"') %>% as.numeric()
names(cd)[1] <- "dep"
names(cd)[5] <- "lat"
names(cd)[4] <- "long"

# problème avec certains départements : 1 au lieu de 01
don$dep <- as.character(don$dep)
don[don$dep=="1",'dep'] <- "01"
don[don$dep=="2",'dep'] <- "02"
don[don$dep=="3",'dep'] <- "03"
don[don$dep=="4",'dep'] <- "04"
don[don$dep=="5",'dep'] <- "05"
don[don$dep=="6",'dep'] <- "06"
don[don$dep=="7",'dep'] <- "07"
don[don$dep=="8",'dep'] <- "08"
don[don$dep=="9",'dep'] <- "09"

merged_df <- merge(don, cd[, c("dep", "lat", "long")], by = "dep", all.x = TRUE, suffixes = c("_ancien", "_dep"))

unique(don$dep)



# Préparation des données pour les cartes de gravité
lat_long <- merged_df %>%
  group_by(dep) %>%
  summarise(
    lat = lat_dep,  
    long = long_dep,
    n_observations = n()
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

data_global <- merged_df %>%
  group_by(dep) %>%
  summarise(
    lat = lat_dep,
    long = long_dep,
    nombre_lignes = n(),
    femmes = sum(sexe == "Femme", na.rm = TRUE),
    hommes = sum(sexe == "Homme", na.rm = TRUE)
  ) %>%
  mutate(
    pourcentage_femmes = (femmes / nombre_lignes) * 100,
    pourcentage_hommes = (hommes / nombre_lignes) * 100
  ) %>%
  select(dep, nombre_lignes, pourcentage_femmes, pourcentage_hommes, lat, long)  