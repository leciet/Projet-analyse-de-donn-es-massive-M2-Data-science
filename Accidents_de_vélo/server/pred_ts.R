
source('server/Res_series_temp.R')

output$graph_ts <- renderPlotly({
  input$parametres_serie_temp
  isolate({
    liste_ts <- list(Total = ts1,
                        'Indemne' = tsi,
                        'Blessé léger' = tsl,
                        'Blessé hospitalisé' = tsh,
                        'Tué' = tst)
  liste_modeles <- list(Total = mod1,
                        'Indemne' = modi,
                        'Blessé léger' = modl,
                        'Blessé hospitalisé' = modh,
                        'Tué' = modt)
  
  ts_choisie <- liste_ts[input$type_ts] #
  mod_choisi <- liste_modeles[input$type_ts]#
  
  nb_periodes <- 12*(as.numeric(input$annee_pred) - 2021)
  periodes <- paste( rep(2022:2040, each = 12),
                     rep(1:12, 19),
                     rep(1,19*12),
                     sep = '-')
  periodes_choisies <- as.Date(periodes[1:nb_periodes], format = "%Y-%m-%d")
  
  t <- (length(ts_choisie) + 1):(length(ts_choisie) + nb_periodes)
  x <- outer(t, 1:6)*(pi/6)
  df <- data.frame(t = t, cos = cos(x), sin = sin(x))
  df <- df[-ncol(df)]
  
  fc <- generics::forecast(mod_choisi[[1]], h = nb_periodes, xreg = as.matrix(df))
  
  df_pred <- data.frame(Date = periodes_choisies,
                        Accidents = round(fc$mean),
                        col = 1,
                        Upper = round(fc$upper[,2]),
                        Lower = round(fc$lower[,2]))
  
  if (input$type_ts == 'Total'){
    df_plot <- nb_acc_tot2 |>
      ungroup() |>
      select(Accidents, Date) |>
      mutate(col = 0) |>
      bind_rows(df_pred)
    
  } else {
    df_plot <- nb_acc2 |>
      ungroup() |>
      filter(Gravité == input$type_ts) |>
      select(Accidents, Date) |>
      mutate(col = 0) |>
      bind_rows(df_pred)
  }
  
  gpl <- ggplot(df_plot) + aes(x = Date, y = Accidents, color = col) +
    geom_line() +
    geom_line(aes(y = Upper), color = 'darkgray', linetype = 'dotted') +
    geom_line(aes(y = Lower), color = 'darkgray', linetype = 'dotted') +
    theme(legend.position = 'none') +
    labs(title = "Prédiction du nombre d'accidents")
  
  plotly::ggplotly(gpl, tooltip = c("x", "y"))
  }
    )
  
  
})