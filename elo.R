## K-factor: importance
K <- 50

##-----------------------------------------------------------------------------
## Compute the change in ELO ranking
updateElo <- function(home_ranking, away_ranking, home_score, away_score) {
  E_home <- winningChance(home_ranking, away_ranking)
  E_away <- 1 - E_home
  
  if (home_score > away_score) {
    # Home win
    S_home <- 1
  } else if (home_score < away_score) {
    # Away win
    S_home <- 0
  } else {
    # Draw
    S_home <- 0.5
  }
  S_away <- 1 - S_home
  
  c(round(home_ranking + K * (S_home - E_home)), round(away_ranking + K * (S_away - E_away)))
}

## Compute change of winning
## Compute the expected score for player 1 to win from player 2
winningChance <- function(elo1, elo2) {
  1 / (1 + 10 ^ ((elo2 - elo1) / 400))
}

## Compute the odds of team 1 winning
winningOdds <- function(elo1, elo2) {
  p <- winningChance(elo1, elo2)
  p / (1 - p)
}

##-----------------------------------------------------------------------------
## Competition
computeElo <- function(teams, games) {
  elo         <- data.frame(team = unique(teams$id), round = 'Start', elo = 1500)
  round_names <- unique(games$round_name)
  running_elo <- elo[,c('team', 'elo')]
  for (round_name in round_names) {
    round_games <- filter(games, round_name == round_name)
    for (i in 1:dim(round_games)[1]) {
      game    <- round_games[i,]
      new_elo <- updateElo(running_elo[running_elo$team == game$home_team_id, 'elo'], 
                           running_elo[running_elo$team == game$away_team_id, 'elo'], 
                           game$home_score, game$away_score)
      running_elo[running_elo$team == game$home_team_id, 'elo'] <- new_elo[1]
      running_elo[running_elo$team == game$away_team_id, 'elo'] <- new_elo[2]
    }
    elo <- rbind(elo, cbind(running_elo, round = round_name))
  }
  elo
}
