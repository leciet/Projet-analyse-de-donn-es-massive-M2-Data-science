
library(tidyverse)

load('don.RData')

don2 <- don[sapply(don, class) == 'factor']
don2 <- na.omit(don2)
don2 <- don2[-c(4,5)]

don2$hrmn <- paste(substr(don2$hrmn, 1, 3), '00', sep = '')


### Détection des problèmes pour le test du chi-deux

for (i in 1:12) print(table(don2$grav, don2[,i]))


### Ajustement des données pour mieux coller aux hypothèses

don2$hrmn <- fct_collapse(don2$hrmn,
                          '00:00 - 6:00' = c("00:00", "01:00", "02:00",
                                             "03:00", "04:00", "05:00", "06:00"))

don2$equipement1[don2$equipement1 %in% c('Dispositif enfants', 'Airbag', 'Gants')] = 'Autre'

for (i in 1:12) don2[,i] <- fct_drop(don2[,i])


### Création du vecteurs des tests chi-deux

mat_chisq = matrix(0, 1, 12)
rownames(mat_chisq) = "grav"
colnames(mat_chisq) = colnames(don2)

for (i in c(1:8, 10:12)){
  print(table(don2$grav, don2[,i]))
  mat_chisq[1,i] <- table(don2$grav, don2[,i]) |>
    chisq.test() %>%
    .$p.value
}

mat_chisq


### CA sur les couples de modalités

library(FactoMineR)
library(factoextra)

list_cas <- list()

for (i in c(1:8, 10:12)){
  tab <- table(don2$grav, don2[,i])
  res_ca <- CA(tab)
  
  list_cas[[names(don2)[i]]] = res_ca
}

plot(list_cas[[2]], cex = 0.8)
fviz_ca(list_cas[[2]], xlim = c(-0.075, 0.175), ylim = c(-0.025, 0.075))

# marche moins bien quand même