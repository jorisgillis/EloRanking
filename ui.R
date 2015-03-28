library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = 'ELO Soccer'),
  dashboardSidebar(
    sidebarMenu(
      menuItem('Teams', tabName = 'teams', icon = icon('keyboard-o')),
      menuItem('Players', tabName = 'players', icon = icon('keyboard-o')),
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
              h4('ELO Ratings')
      )
    )
  )
))
