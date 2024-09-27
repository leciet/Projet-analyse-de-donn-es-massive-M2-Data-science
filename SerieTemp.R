install.packages("tsibble")
library(readr)
library(dplyr)
library(tidyr)
library(fpp2)
library(tseries)
library(urca)
library(lubridate)
library(tsibble)
vll <- read_csv(file.path(path, "accidentsVelo.csv"))
summary(vll)
# Conversion de la date en format Date (si applicable)
vll$date <- as.Date(vll$date) # Assurez-vous que "date" est le bon nom de la colonne

# Agrégation des données par mois ou par an (selon le besoin)
vl_agg <- vll %>%
  group_by(year = year(date)) %>% # ou month(date) si vous souhaitez une agrégation mensuelle
  summarise(accidents = n()) %>%
  ungroup()

vl_tsibble <- vl_agg %>%
  as_tsibble(index = year)  # Ensure your index is the date or year column
library(ggplot2)

ggplot(vl_tsibble, aes(x = year, y = accidents)) + 
  geom_line() +
  labs(title = "Série Temporelle des Accidents de Vélo",
       x = "Année",
       y = "Nombre d'Accidents")

vl_ts <- ts(vl_agg$accidents, frequency = 1)
ggAcf(vl_ts)
adf_test <- adf.test(vl_ts)
print(adf_test)
# KPSS test pour la stationnarité
kpss_test <- ur.kpss(vl_ts)
summary(kpss_test)

# Différenciation si non stationnaire
if(adf_test$p.value > 0.05) {
  vl_diff <- diff(vl_ts)
  ggAcf(vl_diff) # ACF après différenciation
}

# Identification des ordres p et q
ggAcf(vl_diff)
ggPacf(vl_diff)

# Ajustement du modèle ARIMA
fit <- auto.arima(vl_ts)
summary(fit)

# Prévisions à partir du modèle
forecast_fit <- fit %>% forecast(h = 10) # Prévisions pour les 10 prochaines périodes
autoplot(forecast_fit) + 
  labs(title = "Prévisions des Accidents de Vélo",
       x = "Année",
       y = "Nombre d'Accidents Prévisibles")

# Vérification des résidus
checkresiduals(fit)
