#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --tuples-only -c"

MAIN_PROGRAM() {
  # if you run without an argument.
  if [[ -z $1 ]]
  then
    echo Please provide an element as an argument.
    exit
  else
  PRINT_ELEMENT_INFO "$1"
  fi
}

PRINT_ELEMENT_INFO() {
  # Convert input to lowercase for consistent matching.
  INPUT=$(echo "$1" | tr '[:upper:]' '[:lower:]')

  if [[ $INPUT =~ ^[1-9]+$ ]]
  then
    # If number - Find atomic number by number.
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$INPUT;" | xargs)
  else 
  #  Else it's string - Find atomic number by symbol or name.
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE LOWER(symbol)='$INPUT' OR LOWER(name)='$INPUT';" | xargs)
  fi

  if [[ -z $ATOMIC_NUMBER ]]
  then 
    # If an element wasn't found by input.
    echo I could not find that element in the database.
  else
    # Fetch all required data.
    ELEMENT_DATA=$($PSQL "SELECT
      e.atomic_number,
      e.name,
      e.symbol,
      p.atomic_mass,
      p.melting_point_celsius,
      p.boiling_point_celsius,
      t.type
      FROM
        elements e
      JOIN
        properties p USING(atomic_number)
      JOIN
        types t USING(type_id)
      WHERE
        e.atomic_number = $ATOMIC_NUMBER;")

    # Parse into variables.
    read ATOMIC_NUMBER NAME SYMBOL ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE <<< $(echo $ELEMENT_DATA | sed 's/|/ /g')

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
}

MAIN_PROGRAM "$1"