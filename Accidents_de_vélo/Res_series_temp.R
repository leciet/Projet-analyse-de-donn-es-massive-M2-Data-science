
library(forecast)
library(dplyr)

load("don.RData")


# Construction des jeux de données -----

levels(don$mois) = 1:12

nb_acc2 <- don |>
  group_by(an, mois, grav) |>
  summarise(Accidents = n()) |>
  rename(Année = an, Mois = mois, Gravité = grav) |>
  mutate(Date = as.Date(paste(Année, Mois, '01', sep = '-')))

nb_acc_tot2 <- don |>
  group_by(an, mois) |>
  summarise(Accidents = n()) |>
  rename(Année = an, Mois = mois) |>
  mutate(Date = as.Date(paste(Année, Mois, '01', sep = '-')))


# Construction des séries temporelles ------

ts1 <- ts(nb_acc_tot2$Accidents)

tsi <- nb_acc2 |>
  filter(Gravité == 'Indemne') %>%
  .$Accidents |>
  ts()

tsl <- nb_acc2 |>
  filter(Gravité == 'Blessé léger') %>%
  .$Accidents |>
  ts()

tsh <- nb_acc2 |>
  filter(Gravité == 'Blessé hospitalisé') %>%
  .$Accidents |>
  ts()

tst <- nb_acc2 |>
  filter(Gravité == 'Tué') %>%
  .$Accidents |>
  ts()

# Construction des modèles ARIMA ------

t = 1:length(ts1)
x = outer(t, 1:6)*(pi/6)
df = data.frame(acc = ts1, t = t, cos = cos(x), sin = sin(x))
df <- df[-ncol(df)]

mod1 <- Arima(ts1, c(2,0,0), xreg = as.matrix(df[,-1]))

t = 1:length(tsi)
x = outer(t, 1:6)*(pi/6)
df = data.frame(acc = tsi, t = t, cos = cos(x), sin = sin(x))
df <- df[-ncol(df)]

modi <- Arima(tsi, c(1,0,1), xreg = as.matrix(df[,-1]))

t = 1:length(tsl)
x = outer(t, 1:6)*(pi/6)
df = data.frame(acc = tsl, t = t, cos = cos(x), sin = sin(x))
df <- df[-ncol(df)]

modl <- Arima(tsl, c(1,0,0), xreg = as.matrix(df[,-1]))

t = 1:length(tsh)
x = outer(t, 1:6)*(pi/6)
df = data.frame(acc = tsh, t = t, cos = cos(x), sin = sin(x))
df <- df[-ncol(df)]

modh <- Arima(tsh, c(2,0,1), xreg = as.matrix(df[,-1]))

t <- 1:length(tst)
x <- outer(t, 1:6)*(pi/6)
df <- data.frame(acc = tst, t = t, cos = cos(x), sin = sin(x))
df <- df[-ncol(df)]

modt <- Arima(tst, c(0,0,0), xreg = as.matrix(df[,-1]))

rm(df,x,t)
