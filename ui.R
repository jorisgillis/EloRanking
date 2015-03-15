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
                box(width = 12, status = 'primary', title = 'Manage Teams', 
                    fluidRow(
                      column(8, textInput('teamName', "Team name:")), 
                      column(4, actionButton('teamNameEnter', label = 'Add', icon = icon('check')))
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
