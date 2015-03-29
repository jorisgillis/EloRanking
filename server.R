
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

teams  <- fetchTeams()
games  <- fetchGames()
rounds <- fetchRounds()

shinyServer(function(input, output, session) {
  ##---------------------------------------------------------------------------
  ## ACCESSING DATA
  ##---------------------------------------------------------------------------
  values <- reactiveValues(
    teams  = fetchTeams(),
    games  = fetchGames(),
    rounds = fetchRounds()
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
      addGame(input$roundNumber, input$homeTeam, input$awayTeam, input$homeTeamScore, input$awayTeamScore)
      
      # Update all teams-dependent shows
      games <- fetchGames()
      values$games = games
    }
    # Clear the input fields
    updateTextInput(session, inputId = "homeTeamScore", value = '0')
    updateTextInput(session, inputId = "awayTeamScore", value = '0')
  })
  
  observeEvent(input$enterRound, {
    if (!(input$roundName %in% rounds$name)) {
      addRound(input$roundName)
      values$rounds <- fetchRounds()
    }
    updateTextInput(session, inputId = "roundName", value = "")
  })
  
  observeEvent(values$rounds, {
    r <- values$rounds %>% arrange(desc(name))
    updateSelectInput(session, inputId = 'roundNumber', choices = setNames(r$id, r$name))
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
    df <- values$games %>% select(round_name, home_team_name, home_score, away_score, away_team_name)
    colnames(df) <- c("Round", "Home Team", "Home Score", "Away Score", "Away Team")
    df
  }, 
  options = list(
    pageLength= 24
  ))
  
  output$roundsTable <- renderDataTable({
    df <- values$rounds %>% select(-id)
    colnames(df) <- c("Round Name")
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
    # Getting the elo ratings
    elo_ranking <- left_join(
      computeElo(values$teams, values$games),
      teams, by = c('team' = 'id')
    )
    elo_ranking$name  <- factor(elo_ranking$name)
    
    # Colors: interpolate because there are usually more teams than colors in a given palette
    colors <- RColorBrewer::brewer.pal(8, name = 'Set1')
    colors <- colorRampPalette(colors)(dim(teams)[1])
    
    # Shapes: create 6 equal size groups, based on ranking
    # WIP last_elo <- tail(elo_ranking, n = dim(teams)[1]) %>% arrange(elo)
    
    ggplot(elo_ranking, aes(as.integer(round), elo, colour = name)) +
      geom_point() + geom_line() +
      scale_colour_manual("Teams", values = colors) + 
      scale_x_discrete("Round", labels = levels(elo_ranking$round)) +
      scale_y_continuous("Elo Ranking", limits = c(1000, 2000), breaks = seq(1000, 2000, 50)) + 
      theme_bw() + theme(axis.text.x = element_text(angle = 90))
  })
  
  output$computedOddsHome <- renderText({
    elo_ranking <- computeElo(values$teams, values$games)
    elo_home    <- elo_ranking[elo_ranking$team == input$oddsHomeTeam, 'elo']
    elo_away    <- elo_ranking[elo_ranking$team == input$oddsAwayTeam, 'elo']
    
    tail(round(winningOdds(elo_home, elo_away), 2), 1)
  })
  
  output$computedOddsAway <- renderText({
    elo_ranking <- computeElo(values$teams, values$games)
    elo_home    <- elo_ranking[elo_ranking$team == input$oddsHomeTeam, 'elo']
    elo_away    <- elo_ranking[elo_ranking$team == input$oddsAwayTeam, 'elo']
    
    tail(round(winningOdds(elo_away, elo_home), 2), 1)
  })
})