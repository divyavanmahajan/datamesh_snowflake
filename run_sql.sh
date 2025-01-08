#!/bin/bash

# Check if connection_name argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <connection_name> <domain> <prefix of generated SQL files to run>"
  exit 1
fi

# Assign the connection_name argument to a variable
connection_name=$1

# Check if domain argument is provided
if [ -z "$2" ]; then
  echo "Usage: $0 <connection> <domain> <prefix of generated SQL files to run>"
  exit 1
fi

# Assign the domain argument to a variable
domain=$2

# Check if prefix argument is provided
if [ -z "$3" ]; then
  echo "Usage: $0 <connection> <domain> <prefix of generated SQL files to run>"
  exit 1
fi

# Assign the domain argument to a variable
prefix=$3

# Define the directory to scan
directory="workspaces/$domain/sql"

# Define the temporary file
temp_file=$(mktemp)

# Find and concatenate files matching dev_0* in alphabetical order
echo "Searching for files starting with $prefix in $directory"
find "$directory" -type f -name $prefix'*.sql' | sort 
find "$directory" -type f -name $prefix'*.sql' | sort | xargs cat > "$temp_file"

# Print the location of the temporary file
echo "Concatenated files are stored in: $temp_file"

# Execute SnowSQL
echo "snowsql -c $connection_name -f $temp_file"
echo "========================================="
snowsql -c $connection_name -f $temp_file
