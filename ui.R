library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = 'ELO Soccer'),
  dashboardSidebar(
    sidebarMenu(
      menuItem('Teams', tabName = 'teams', icon = icon('keyboard-o')),
      menuItem('Games', tabName = 'games', icon = icon('keyboard-o')),
      menuItem('ELO Ratings', tabName = 'eloRatings', icon = icon('bar-chart-o'))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = 'teams',
              h4('Teams'),
              fluidRow(
                tabBox(width = 12, status = 'primary', title = 'Manage League', id = 'leagueManagement',
                       tabPanel("Add",
                                fluidRow(
                                  column(8, textInput('teamName', "Team name:")), 
                                  column(4, actionButton('teamNameEnter', label = 'Add', icon = icon('check')))
                                )
                       ), 
                       tabPanel("Remove",
                                fluidRow(
                                  column(8, selectInput('removeTeamName', "Select A Team:", choices = c(''))), 
                                  column(4, actionButton('teamNameRemove', label = 'Remove', icon = icon('times')))
                                )
                       )
                )
              ),
              fluidRow(
                box(width = 12, status = 'primary', title = 'Teams',
                    fluidRow(
                      column(12, dataTableOutput('teamsTable'))
                    )
                )
              )
      ),
      tabItem(
        tabName = 'games',
        h4("Games"),
        fluidRow(
          tabBox(
            width = 12, status = 'primary', title = "Manage games", id = "gamesManagement",
            tabPanel(
              "Add Game",
              fluidRow(column(12, selectizeInput("roundNumber", "Round", choices = c('')))),
              fluidRow(
                column(3, selectizeInput("homeTeam", "Home Team: ", choices = c(''))),
                column(2, textInput("homeTeamScore", "", value = "0")),
                column(2, textInput("awayTeamScore", "", value = "0")),
                column(3, selectizeInput("awayTeam", "Away Team: ", choices = c(''))),
                column(2, actionButton("enterGame", label = "Add", icon = icon("check")))
              )
            ),
            tabPanel(
              "Add Game Round",
              fluidRow(
                column(8, textInput("roundName", "Round: ", value = "")),
                column(4, actionButton("enterRound", "Add", icon = icon("check")))
              ),
              fluidRow(
                column(12, dataTableOutput("roundsTable"))
              )
            )
          )
        ),
        fluidRow(
          box(width = 12, status = 'primary', title = "Games", dataTableOutput('gamesTable'))
        )
      ),
      tabItem(tabName = 'players',
              h4('Players'),
              fluidRow(
                tabBox(width = 12, status = 'primary', title = 'Manage Players', id = 'playerManagement',
                       tabPanel("Add",
                                fluidRow(
                                  column(8, textInput('playerName', "Player name:")), 
                                  column(4, actionButton('playerNameEnter', label = 'Add', icon = icon('check')))
                                )
                       ), 
                       tabPanel("Remove",
                                fluidRow(
                                  column(8, selectInput('removePlayerName', "Select A Player:", choices = c(''))), 
                                  column(4, actionButton('playerNameRemove', label = 'Remove', icon = icon('times')))
                                )
                       )
                ),
                fluidRow(
                  box(width = 12, status = 'primary', title = 'Players',
                      fluidRow(
                        column(12, dataTableOutput('playersTable'))
                      )
                  )
                )
              )
      ),
      tabItem(tabName = 'eloRatings',
              h4('ELO Ratings'),
              box(width = 12, status = 'success', title = "Odds", 
                  fluidRow(
                    column(6, selectizeInput("oddsHomeTeam", "Home Team: ", choices = c(''))),
                    column(6, selectizeInput("oddsAwayTeam", "Away Team: ", choices = c('')))
                  ),
                  fluidRow(
                    column(6, h4(textOutput("computedOddsHome"))),
                    column(6, h4(textOutput("computedOddsAway")))
                  )
              ),
              box(width = 12, status = 'danger', title = "Current Elo Rankings", plotOutput('currentRanking', height = 500))
      )
    )
  )
))
