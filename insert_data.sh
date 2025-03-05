#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Lire le fichier CSV et ajouter les équipes
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Ignorer l'entête
  if [[ $WINNER != "winner" ]]
  then
    # Vérifier si WINNER existe dans teams
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # Si WINNER n'existe pas, l'insérer
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') RETURNING team_id")
      if [[ $INSERT_WINNER_RESULT =~ ^[0-9]+$ ]]
      then
        echo "Ajouté dans teams : $WINNER (ID: $INSERT_WINNER_RESULT)"
      fi
    fi

    # Vérifier si OPPONENT existe dans teams
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Si OPPONENT n'existe pas, l'insérer
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') RETURNING team_id")
      if [[ $INSERT_OPPONENT_RESULT =~ ^[0-9]+$ ]]
      then
        echo "Ajouté dans teams : $OPPONENT (ID: $INSERT_OPPONENT_RESULT)"
      fi
    fi
  
  # Check if WINNER team exists in teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # If WINNER is not found, insert it
    if [[ -z $WINNER_ID ]]
    then
      WINNER_ID=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') RETURNING team_id")
      echo "Inserted into teams: $WINNER (ID: $WINNER_ID)"
    fi

    # Check if OPPONENT team exists in teams table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # If OPPONENT is not found, insert it
    if [[ -z $OPPONENT_ID ]]
    then
      OPPONENT_ID=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') RETURNING team_id")
      echo "Inserted into teams: $OPPONENT (ID: $OPPONENT_ID)"
    fi

    # Insert game data into the games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
                                VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted game: $YEAR - $ROUND ($WINNER vs. $OPPONENT)"
    fi
  fi

done
