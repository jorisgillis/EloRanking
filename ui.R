library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = 'ELO Soccer'),
  dashboardSidebar(
    sidebarMenu(
      menuItem('Data Entry', tabName = 'dataEntry', icon = icon('keyboard-o')),
      menuItem('ELO Ratings', tabName = 'eloRatings', icon = icon('bar-chart-o'))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = 'dataEntry',
              h4('Data Entry'),
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
                                  column(4, actionButton('teamNameEnter', label = 'Remove', icon = icon('times')))
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
              ),
              fluidRow(
                box(width = 12, status = 'primary', title = 'Enter players', p("Players"))
              )
      ),
      tabItem(tabName = 'eloRatings',
              h4('ELO Ratings')
      )
    )
  )
))
