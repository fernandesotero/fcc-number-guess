#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read username

# Check if the user exists
USER_EXISTS=$($PSQL "SELECT username FROM users WHERE username='$username'")

if [[ -z $USER_EXISTS ]]; then
  # New user
  echo "Welcome, $username! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$username')" > /dev/null
else
  # Existing user
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$username'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$username'")
  echo "Welcome back, $username! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

# Start the guessing loop
echo "Guess the secret number between 1 and 1000:"
while true; do
  read GUESS

  # Validate input
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  GUESS_COUNT=$((GUESS_COUNT + 1))

  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Update the database
$PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$username'" > /dev/null

# Update best game if applicable
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$username'")
if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]; then
  $PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username='$username'" > /dev/null
fi