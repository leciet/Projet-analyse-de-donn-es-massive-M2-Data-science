navbarMenu("Analyse",
           tabPanel("Analyse univariée",
                    fluidPage(
                      h2("Analyse univariée"),
                      p("Représentez la répartition des accidents en fonction de l'une des variables de la liste à gauche ci-dessous."),
                      p("Vous pouvez, au choix, comparer les nombres totaux d'accidents ou la répartition de la gravité des accidents."),
                      p(em("Remarque : les incidents nocturnes, de 0:00 à 9:00, n'ont été enregistrés que depuis 2019.")),
                      br(),
                      hr(),
                      
                      fluidRow(column(3,
                                      selectInput('varuni',
                                                  label = 'Variable à représenter',
                                                  choices = setNames(var_analyse,
                                                                     c("Année", "Mois", "Jour", "Heure",
                                                                       "Agglomération", "Luminosité", "Météo", 
                                                                       "Type de route", "Type de surface", 
                                                                       "Gravité", "Sexe", "Âge", "Type de trajet", 
                                                                       "Port de casque", "Port de gilet"))),
                                      sliderInput('annee',
                                                  label = 'Plage temporelle',
                                                  min = 2005,
                                                  max = 2021,
                                                  value = c(2005, 2021),
                                                  sep = ''),
                                      selectInput('by_grav',
                                                  label = "Nombre d'accidents",
                                                  choices = c('Total', 'Par gravité'))),
                               column(9,
                                      plotlyOutput('graph_uni')
                               )
                      )
                    )
           ),
           
           tabPanel("Analyse multivariée",
                    fluidPage(
                      h2("Analyse multivariée"),
                      p( HTML("Deux types d'analyses sont disponibles : 
                                   <ul> <li> une ACM (Analyse des Correspondances Multiples) sur au moins 3 variables de votre choix ; </li>
                                   <li> une AC (Analyse des Correspondances) mettant en relation la gravité d'un accident et une variable de votre choix. </li>
                                   </ul> ")),
                      p(em("Remarque : la construction de l'ACM peut prendre plusieurs secondes.")),
                      hr(),
                      
                      tabsetPanel(
                        tabPanel("ACM",
                                 br(),
                                 fluidRow(
                                   shinyjs::useShinyjs(),
                                   column(2,
                                          checkboxGroupInput("var_acm",
                                                             label = "Variables actives :",
                                                             choices = setNames(var_analyse[- which(var_analyse == "grav")],
                                                                                c("Année", "Mois", "Jour", "Heure",
                                                                                  "Agglomération", "Luminosité", "Météo", 
                                                                                  "Type de route", "Type de surface", 
                                                                                  "Sexe", "Âge", "Type de trajet", 
                                                                                  "Port de casque", "Port de gilet")),
                                                             selected = var_analyse[c(5:9, 13:15)]),
                                          actionButton("constr_acm", 
                                                       "Construire l'ACM"),
                                          br()),
                                   
                                   column(5,
                                          plotOutput("plot_MCA_ind", width = '600px', height = '400px')),
                                   
                                   column(5,
                                          plotOutput("plot_MCA_var", width = '600px', height = '400px'))
                                 )),
                        
                        tabPanel("AC",
                                 br(),
                                 fluidRow(column(2,
                                                 selectInput('var_ac',
                                                             label = 'Variable à représenter',
                                                             choices = setNames(var_analyse[-c(5,10,11,14:15)],
                                                                                c("Année", "Mois", "Jour", "Heure",
                                                                                  "Luminosité", "Météo", "Type de route", 
                                                                                  "Type de surface", "Âge", "Type de trajet"))),
                                                 p(em("Remarque : les variables à 2 modalités ont été retirées."))),
                                          
                                          column(10,
                                                 plotOutput('plot_CA'))
                                 )
                        )
                      )
                    )
           )
)