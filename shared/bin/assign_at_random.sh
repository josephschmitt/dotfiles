#!/bin/bash

# Parse command-line options
while getopts "p:e:" opt; do
  case ${opt} in
    p ) IFS=',' read -r -a people <<< "$OPTARG" ;;
    e ) IFS=',' read -r -a exclude <<< "$OPTARG" ;;
    * ) echo "Usage: $0 -p people_list -e exclude_list"; exit 1 ;;
  esac
done

# Filter out the excluded people
filtered_people=()
for person in "${people[@]}"; do
  if [[ ! " ${exclude[@]} " =~ " $person " ]]; then
    filtered_people+=("$person")
  fi
done

# Check if there are any people left
if [[ ${#filtered_people[@]} -eq 0 ]]; then
  echo "No one left to choose from!"
  exit 1
fi

# Select a random person
selected=${filtered_people[RANDOM % ${#filtered_people[@]}]}

echo "Selected person: $selected"

