
library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)

##-----------------------------------------------------------------------------
## LOADING DATA
## Loads the \code{mydb.sqlite3} database file which contains:
## - teams: data frame containing each team with its ELO ranking
##-----------------------------------------------------------------------------
source('db.R')
source('elo.R')

teams <- fetchTeams()
games <- fetchGames()

shinyServer(function(input, output, session) {
  ##---------------------------------------------------------------------------
  ## ACCESSING DATA
  ##---------------------------------------------------------------------------
  values <- reactiveValues(
    teams = fetchTeams(),
    games = fetchGames()
  )
  
  
  ##---------------------------------------------------------------------------
  ## CRUD: Create, Read, Update & Delete
  ##---------------------------------------------------------------------------
  ## Teams
  observeEvent(input$teamNameEnter, {
    if (!(input$teamName %in% teams$name)) {
      # Team name is new; add it to the data frame
      addTeam(input$teamName)
      
      # Update all teams-dependent shows
      teams <- fetchTeams()
      values$teams <- teams
    }
    # Clear the input field
    updateTextInput(session, inputId = 'teamName', value = '')
  })
  
  observeEvent(input$teamNameRemove, {
    # Remove team name & save
    removeTeam(input$removeTeamName)
    
    # Update all teams-dependent shows
    teams <- fetchTeams()
    values$teams <- teams
  })
  
  observeEvent(values$teams, {
    updateSelectInput(session, inputId = 'removeTeamName', choices = values$teams$name)
    updateSelectInput(session, inputId = 'homeTeam', choices = setNames(values$teams$id, values$teams$name))
    updateSelectInput(session, inputId = 'awayTeam', choices = setNames(values$teams$id, values$teams$name))
    updateSelectInput(session, inputId = 'oddsHomeTeam', choices = setNames(values$teams$id, values$teams$name))
    updateSelectInput(session, inputId = 'oddsAwayTeam', choices = setNames(values$teams$id, values$teams$name))
  })
  
  ##---------------------------------------------------------------------------
  ## Games
  observeEvent(input$enterGame, {
    if (input$homeTeam != input$awayTeam & 
        !is.na(as.integer(input$homeTeamScore)) & 
        !is.na(as.integer(input$awayTeamScore))) {
      # Team name is new; add it to the data frame
      addGame(input$homeTeam, input$awayTeam, input$homeTeamScore, input$awayTeamScore)
      
      # Update all teams-dependent shows
      games <- fetchGames()
      values$games = games
    }
    # Clear the input fields
    updateTextInput(session, inputId = 'homeTeamScore', value = '')
    updateTextInput(session, inputId = 'awayTeamScore', value = '')
  })
  
  ##---------------------------------------------------------------------------
  ## SHOWING DATA
  ##---------------------------------------------------------------------------
  output$teamsTable <- renderDataTable({
    df <- as.data.frame(values$teams$name)
    colnames(df) <- c("Team Name")
    df
  }, 
  options = list(
    pageLength= 24,
    lengthMenu = c(24),
    dom = 't'
  ))
  
  output$gamesTable <- renderDataTable({
    df <- values$games %>% select(home_team_name, home_score, away_score, away_team_name)
    colnames(df) <- c("Home Team", "Home Score", "Away Score", "Away Team")
    df
  }, 
  options = list(
    pageLength= 24,
    lengthMenu = c(24),
    dom = 't'
  ))
  
  
  ##---------------------------------------------------------------------------
  ## PLOTTING
  ##---------------------------------------------------------------------------
  output$currentRanking <- renderPlot({
    elo_ranking <- left_join(
      computeElo(values$teams, values$games),
      teams, by = c('team' = 'id')
    ) %>% arrange(elo)
    elo_ranking$name <- factor(elo_ranking$name, levels = elo_ranking$name)
    ggplot(elo_ranking, aes(name, elo, colour = factor(1))) +
      geom_point() +
      scale_colour_manual('', values = c('#006837')) + 
      scale_y_continuous("Elo Ranking", limits = c(1000, 2000), breaks = seq(1000, 2000, 50)) + xlab("") +
      coord_flip() + theme_bw() + theme(legend.position = 'none', axis.text.x = element_text(angle = 90))
  })
  
  output$computedOddsHome <- renderText({
    elo_ranking <- computeElo(values$teams, values$games)
    elo_home    <- elo_ranking[elo_ranking$team == input$oddsHomeTeam, 'elo']
    elo_away    <- elo_ranking[elo_ranking$team == input$oddsAwayTeam, 'elo']
    
    round(winningOdds(elo_home, elo_away), 2)
  })
  
  output$computedOddsAway <- renderText({
    elo_ranking <- computeElo(values$teams, values$games)
    elo_home    <- elo_ranking[elo_ranking$team == input$oddsHomeTeam, 'elo']
    elo_away    <- elo_ranking[elo_ranking$team == input$oddsAwayTeam, 'elo']
    
    round(winningOdds(elo_away, elo_home), 2)
  })
})