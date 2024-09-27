
library(tidyverse)

load("don.RData")

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
