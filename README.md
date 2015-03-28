# EloRanking
A Shiny Server project to track the games in a (soccer) league. You add the teams in the league and 
add games between the teams. This Shiny app will compute an ELO-based score for each team. The ELO score can
be tracked over time and be used to predict the outcome of games. 

## Database setup
This Shiny app uses a SQLite3 database. Creating a SQLite3 database is as simple as running
```
sqlite3 mydb.sqlite3
```

The schema of the database is constructed as follows:
```
CREATE TABLE teams (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE games (
  id INTEGER PRIMARY KEY,
  home_team INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  away_team INTEGER NOT NULL REFERNECES teams(id) ON DELETE CASCADE,
  home_score INTEGER NOT NULL,
  away_score INTEGER NOT NULL,
  CONSTRAINT different_team CHECK (home_team <> away_team)
);
```
