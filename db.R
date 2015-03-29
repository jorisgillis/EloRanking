library(RSQLite)

drv     <- dbDriver("SQLite")
db_name <- "mydb.sqlite3"
conn    <- dbConnect(drv, db_name)

##-----------------------------------------------------------------------------
## FETCHING
##-----------------------------------------------------------------------------
## Getting teams
fetchTeams <- function() {
  dbReadTable(conn, "teams") %>% arrange(name)
}

fetchTeamNames <- function() {
  dbReadTable(conn, "teams") %>% select(-id) %>% arrange(name)
}

fetchGames <- function() {
  df     <- dbReadTable(conn, "games")
  teams  <- fetchTeams()
  rounds <- fetchRounds()
  df <- left_join(
    left_join(
      left_join(df, teams, by = c('home_team' = 'id')),
      teams, by = c('away_team' = 'id')
    ),
    rounds, by = c('round_id' = 'id')
  )
  colnames(df) <- c('id', 'home_team_id', 'away_team_id', 'home_score', 'away_score', 'round_id', 
                    'home_team_name', 'away_team_name', 'round_name')
  df
}

fetchRounds <- function() {
  dbReadTable(conn, "rounds") %>% arrange(name)
}

##-----------------------------------------------------------------------------
## STORING
##-----------------------------------------------------------------------------
## Add a team
addTeam <- function(team_name) {
  df <- fetchTeams()
  id <- getID(df)
  dbWriteTable(conn, 'teams', data.frame(id = id, name = team_name), append = T)
}

## Remove a team
removeTeam <- function(team_name) {
  dbWriteTable(conn, 'teams', (fetchTeams() %>% filter(name != team_name)), overwrite = T)
}


## Add Game
addGame <- function(round_id, home_team, away_team, home_score, away_score) {
  df <- dbReadTable(conn, "games")
  id <- getID(df)
  dbWriteTable(conn, "games", 
               data.frame(id = id, 
                          home_team = home_team, away_team = away_team, 
                          home_score = home_score, away_score = away_score, 
                          round_id = round_id),
               append = T)
}

## Add Round
addRound <- function(roundName) {
  df <- dbReadTable(conn, "rounds")
  id <- getID(df)
  dbWriteTable(conn, "rounds", data.frame(id = id, name = roundName), append = T)
}


##-----------------------------------------------------------------------------
## UTILITY
##-----------------------------------------------------------------------------
getID <- function(df) {
  if (dim(df)[1] > 0) {
    id <- max(df$id) + 1
  } else {
    id <- 1
  }
}

