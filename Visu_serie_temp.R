
library(tidyverse)

load("don.RData")

# Par an ------

nb_acc <- don |>
  group_by(an, grav) |>
  summarise(Accidents = n()) |>
  rename(Année = an, Gravité = grav)

nb_acc_tot <- don |>
  group_by(an) |>
  summarise(Accidents = n()) |>
  rename(Année = an)

gpl <- ggplot(nb_acc) + aes(x = Année, y = Accidents, 
                            group = Gravité, color = Gravité, shape = Gravité) +
  geom_point() +
  geom_line() +
  labs(title = "Nombre d'accidents par an")

plotly::ggplotly(gpl, tooltip = c('x', 'y'))

gpl2 <- ggplot(nb_acc_tot) + aes(x = Année, y = Accidents) +
  geom_point() +
  geom_line() +
  labs(title = "Nombre d'accidents par an")

plotly::ggplotly(gpl2)


# Par mois -----

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

gpl <- ggplot(nb_acc2) + aes(x = Date, y = Accidents, 
                            group = Gravité, color = Gravité, shape = Gravité) +
  geom_line() +
  labs(title = "Nombre d'accidents par an")

plotly::ggplotly(gpl, tooltip = c('x', 'y'))

gpl2 <- ggplot(nb_acc_tot2) + aes(x = Date, y = Accidents) +
  geom_line() +
  labs(title = "Nombre d'accidents par an")

plotly::ggplotly(gpl2)


# Séries temporelles (total) ------

library(forecast)

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

ggtsdisplay(ts1)

ts1_nosais <- diff(ts1, lag = 12)
ggtsdisplay(ts1_nosais)

t = 1:length(ts1)
x = outer(t, 1:6)*(pi/6)
df = data.frame(acc = ts1, t = t, cos = cos(x), sin = sin(x))
df <- df[-ncol(df)]

acc_lm <- lm(acc~., data = df)
ggtsdisplay(acc_lm$residuals)

res_acc <- auto.arima(acc_lm$residuals)
res_acc
ggtsdisplay(res_acc$residuals)

ajustement_final <- Arima(ts1, c(2,0,0), xreg = as.matrix(df[,-1]))

plot(ts1, col = 'red')
lines(ajustement_final$fitted, col = 'blue')

t <- (length(ts1) + 1):(length(ts1) + 50)
x = outer(t, 1:6)*(pi/6)
df2 = data.frame(t = t, cos = cos(x), sin = sin(x))
df2 <- df2[-ncol(df2)]

fc <- forecast(ajustement_final, h = 50, xreg = as.matrix(df2))

plot(ts1, col = 'red', xlim = c(0,250))
lines(ajustement_final$fitted, col = 'blue')
lines(fc$x, col = 'green')


# Séries temporelles (blessés hospitalisés) ------

ggtsdisplay(tsh)

tsh_nosais <- diff(tsh, lag = 12)
ggtsdisplay(tsh_nosais)

t <- 1:length(tsh)
x <- outer(t, 1:6)*(pi/6)
df <- data.frame(acc = tsh, t = t, cos = cos(x), sin = sin(x))
df <- df[-ncol(df)]

acc_lm <- lm(acc~., data = df)
ggtsdisplay(acc_lm$residuals)

res_acc <- auto.arima(acc_lm$residuals)
res_acc
ggtsdisplay(res_acc$residuals)

ajustement_final <- Arima(tsh, c(2,0,1), xreg = as.matrix(df[,-1]))

plot(tsh, col = 'red')
lines(ajustement_final$fitted, col = 'blue')

t <- (length(tsh) + 1):(length(tsh) + 50)
x <- outer(t, 1:6)*(pi/6)
df2 <- data.frame(t = t, cos = cos(x), sin = sin(x))
df2 <- df2[-ncol(df2)]

fc <- forecast(ajustement_final, h = 50, xreg = as.matrix(df2))

plot(fc)

# Séries temporelles (tués) ------

ggtsdisplay(tst)

tst_nosais <- diff(tst, lag = 12)
ggtsdisplay(tst_nosais)

t <- 1:length(tst)
x <- outer(t, 1:6)*(pi/6)
df <- data.frame(acc = tst, t = t, cos = cos(x), sin = sin(x))
df <- df[-ncol(df)]

acc_lm <- lm(acc~., data = df)
ggtsdisplay(acc_lm$residuals)

res_acc <- auto.arima(acc_lm$residuals)
res_acc

ajustement_final <- Arima(tst, c(0,0,0), xreg = as.matrix(df[,-1]))

plot(tst, col = 'red')
lines(ajustement_final$fitted, col = 'blue')

t <- (length(tst) + 1):(length(tst) + 50)
x <- outer(t, 1:6)*(pi/6)
df2 <- data.frame(t = t, cos = cos(x), sin = sin(x))
df2 <- df2[-ncol(df2)]

fc <- forecast(ajustement_final, h = 50, xreg = as.matrix(df2))

plot(fc, main = 'Prédictions à t + 50')

pred_tst <- fc$mean
pred_tst_lower <- fc$lower
pred_tst_upper <- fc$upper


