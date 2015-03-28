
library(shiny)
library(shinydashboard)
library(dplyr)

##-----------------------------------------------------------------------------
## LOADING DATA
## Loads the \code{mydb.sqlite3} database file which contains:
## - teams: data frame containing each team with its ELO ranking
##-----------------------------------------------------------------------------
source('db.R')

teams <- fetchTeamNames()

shinyServer(function(input, output, session) {
  ##---------------------------------------------------------------------------
  ## ACCESSING DATA
  ##---------------------------------------------------------------------------
  values <- reactiveValues(teams = fetchTeamNames())
  
  
  ##---------------------------------------------------------------------------
  ## CRUD: Create, Read, Update & Delete
  ##---------------------------------------------------------------------------
  observeEvent(input$teamNameEnter, {
    if (!(input$teamName %in% teams$name)) {
      # Team name is new; add it to the data frame
      addTeam(input$teamName)
      
      # Update all teams-dependent shows
      teams <- fetchTeamNames()
      values$teams = teams
    }
    # Clear the input field
    updateTextInput(session, inputId = 'teamName', value = '')
  })
  
  observeEvent(input$teamNameRemove, {
    # Remove team name & save
    removeTeam(input$removeTeamName)
    
    # Update all teams-dependent shows
    teams <- fetchTeamNames()
    values$teams = teams
  })
  
  observeEvent(values$teams, {
    updateSelectInput(session, inputId = 'removeTeamName', choices = values$teams$name)
  })
  
  ##---------------------------------------------------------------------------
  ## SHOWING DATA
  ##---------------------------------------------------------------------------
  output$teamsTable <- renderDataTable({
    values$teams
  }, 
  options = list(
    pageLength= 24,
    lengthMenu = c(24),
    dom = 't'
  ))
  
})