# EloRanking
A Shiny Server project to track the games in a (soccer) league. You add the teams in the league and 
add games between the teams. This Shiny app will compute an ELO-based score for each team. The ELO score can
be tracked over time and be used to predict the outcome of games. 

## Database setup
This Shiny app uses a SQLite3 database. Creating a SQLite3 database is as simple as running
``
sqlite3 mydb.sqlite3
``

The schema of the database is constructed as follows:
``
CREATE TABLE teams (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255)
);
``
