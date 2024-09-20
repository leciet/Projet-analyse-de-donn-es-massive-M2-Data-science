# ------------------------------------------------------------------------------
#  16/09/2024
#  Petit script pépou pour voir les données
#  par moi
#  description à changer avant envoi faut pas abuser
# ------------------------------------------------------------------------------


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


# Changement des noms des modalités 

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
                      "Masculin",
                      "Feminin")

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
dta$equipement1 <- substring(dta$equipement,1,1)
dta$equipement1 <- factor(dta$equipement1)
levels(dta$equipement1) <- c("Equipement NA",
                             "Aucun équipement",
                             "Ceinture",
                             "Casque",
                             "Dispositif enfants",
                             "Gilet réflechissant",
                             "Airbag",
                             "Gants",
                             "Equipement non déterminable",
                             "Autre")
dta$equipement2 <- substring(dta$equipement,5,5)
dta$equipement3 <- substring(dta$equipement,9,9)

save(dta, file="data.RData")

