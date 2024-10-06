
# Packages et environnement ----------------------------------------------------

rm(list=ls()) # clean environment 



# Importation et vérification du jeu de données --------------------------------

dta <- read.csv('accidents-velos.csv',
                header = T)

summary(dta)
dta$date <- factor(dta$date)
dta$mois <- factor(dta$mois)
dta$jour <- factor(dta$jour)
dta$hrmn <- factor(dta$hrmn)
dta$dep <- factor(dta$dep)
dta$com <- factor(dta$com)

dta <- subset(dta, 
              select = -c(Num_Acc,
                          int,
                          nbv,
                          prof,
                          circ,
                          col,
                          plan,
                          lartpc,
                          larrout,
                          infra,
                          obs,
                          obsm,
                          choc,
                          manv,
                          vehiculeid,
                          manoeuvehicules,
                          situ,
                          X_infos_commune.code_epci,
                          secuexist,
                          typevehicules))

# secu_exist =? secu1 
# equipement
# typevehicules


# Changement des noms des modalités --------------------------------------------

dta$agg <- factor(dta$agg)
levels(dta$agg) <- c("Hors agglomération",
                     "En agglomération")

dta$lum <- factor(dta$lum)
levels(dta$lum) <- c("Plein jour",
                     "Crépuscule/Aube",
                     "Nuit 0 éclairage",
                     "Nuit éclairage non allumé",
                     "Nuit éclairage allumé")

dta$atm <- factor(dta$atm)
levels(dta$atm) <- c("Temps normale",
                     "Pluie légère",
                     "Pluie Forte",
                     "Neige-grêle",
                     "Brouillard-fumée",
                     "Vent fort-tempête",
                     "Temps éblouissant",
                     "Temps couvert",
                     "Temps autre")

dta$catr <- factor(dta$catr)
levels(dta$catr) <- c("Autoroute",
                      "Nationale",
                      "Départementale",
                      "Communale",
                      "Hors réseau",
                      "Parking",
                      "Métropoles urbaines",
                      "Voie autre")

dta$surf <- factor(dta$surf)
levels(dta$surf) <- c("Surface NA",
                      "Surface normale",
                      "Mouillée",
                      "Flaques",
                      "Inondée",
                      "Enneigée",
                      "Boue",
                      "Verglacée",
                      "Corps gras-Huile",
                      "Surface autre")


dta$grav <- factor(dta$grav)
levels(dta$grav) <- c("Indemne",
                      "Tué",
                      "Blessé hospitalisé",
                      "Blessé léger")

dta$sexe <- factor(dta$sexe)
levels(dta$sexe) <- c("Sexe NA",
                      "Homme",
                      "Femme")

# les modalités -1 et 0 de trajet sont similaires donc on remplace les -1 par des 0
dta$trajet[dta$trajet==-1] <- 0

dta$trajet <- factor(dta$trajet)
levels(dta$trajet) <- c("Motif NA",
                        "Domicile-Travail",
                        "Domicile-Ecole",
                        "Courses-Achats",
                        "Utilisation professionnelle",
                        "Promenade-Loisirs",
                        "Motif autre")

# equipement : on a juste qu'à 3 équipements renseignés
# 2 possibilités -> binaire pour chaque équipement (1 colonne par équipement)
#                -> 3 colonnes avec en modalités le type d'équipement 
# 0 : Aucun equipement
# 2 : Casque
# 9 : Autre
# 4 : Gilet réflechissant
require(stringr)

dta$casque <- str_count(dta$equipement,"2")
dta$gilet <- str_count(dta$equipement,"4")
dta$equipement_autre <- str_count(dta$equipement,"9")

don <- dta

don$date <- as.Date(don$date)
don$mois <- fct_relevel(don$mois,
                        c("janvier", "février", "mars", "avril",
                          "mai", "juin", "juillet", "août",
                          "septembre", "octobre", "novembre", "décembre"))
don$jour <- fct_relevel(don$jour,
                        c('lundi', 'mardi', 'mercredi', 'jeudi',
                          'vendredi', 'samedi', 'dimanche'))

ind_hr <- which(nchar(as.character(don$hrmn)) != 5)
don <- don[-ind_hr,]

ind_dep <- which(as.numeric(don$dep) > 100)
don <- don[-ind_dep,]

ind_coord <- which(don$lat == 0 & don$long == 0)
don$lat[ind_coord] <- NA
don$long[ind_coord] <- NA

don$grav <- forcats::fct_relevel(don$grav, "Indemne", 
                                 "Blessé léger", 
                                 "Blessé hospitalisé",
                                 "Tué")

ind_age <- !(don$age > 80 | is.na(don$age) | don$age < 13)
don <- don[ind_age,] 

don$trajet[don$trajet == 'Motif NA'] <- NA

don$casque <- as.factor(don$casque)
don$gilet <- as.factor(don$gilet)

don <- don[,-20]

don$sexe <- droplevels(don$sexe)

summary(don)

save(don, file = "don.RData")

