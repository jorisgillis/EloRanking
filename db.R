library(RSQLite)

drv     <- dbDriver("SQLite")
db_name <- "mydb.sqlite3"
conn    <- dbConnect(drv, db_name)

##-----------------------------------------------------------------------------
## FETCHING
##-----------------------------------------------------------------------------
## Getting teams
fetchTeams <- function() {
  dbReadTable(conn, "teams")
}

fetchTeamNames <- function() {
  dbReadTable(conn, "teams") %>% select(-id) %>% arrange(name)
}

##-----------------------------------------------------------------------------
## STORING
##-----------------------------------------------------------------------------
## Add a team
addTeam <- function(team_name) {
  df <- fetchTeams()
  if (dim(df)[1] > 0) {
    id <- max(df$id) + 1
  } else {
    id <- 1
  }
  dbWriteTable(conn, 'teams', data.frame(id = id, name = team_name), append = T)
}

## Remove a team
removeTeam <- function(team_name) {
  dbWriteTable(conn, 'teams', (fetchTeams() %>% filter(name != team_name)), overwrite = T)
}
