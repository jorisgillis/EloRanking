
library(shiny)
library(shinydashboard)
library(dplyr)

##-----------------------------------------------------------------------------
## LOADING DATA
## Loads the \code{elo.RData} file which contains:
## - teams: data frame containing each team with its ELO ranking
##-----------------------------------------------------------------------------
load('elo.RData')


shinyServer(function(input, output, session) {
  ##---------------------------------------------------------------------------
  ## ACCESSING DATA
  ##---------------------------------------------------------------------------
  values <- reactiveValues(teams = teams)
  
  
  ##---------------------------------------------------------------------------
  ## CUD: Create, Update, Delete
  ##---------------------------------------------------------------------------
  observeEvent(input$teamNameEnter, 
               function() {
                 if (!(input$teamName %in% teams$Team)) {
                   # Team name is new; add it to the data frame
                   teams <- rbind(teams, c(input$teamName, 1500))
                   save(teams, file = 'elo.RData')
                   
                   # Update all teams-dependent shows
                   values$teams <- teams
                   
                   # Clear the input field
                   updateTextInput(session, inputId = 'teamName', value = '')
                 }
               })
  
  observeEvent(values$teams, {
    updateSelectInput(session, inputId = 'removeTeamName', choices = values$teams$Team)
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