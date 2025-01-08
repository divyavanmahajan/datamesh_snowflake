#!/bin/bash

# Check if a domain argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Set the domain variable
DOMAIN="$1"

# Define the directories
SCRIPT_DIR="$(dirname "$(realpath "$0")")"  # Directory of the bash script
TEMPLATES_DIR="$SCRIPT_DIR/templates"       # Directory where SQL templates are located
WORKSPACES_DIR="$SCRIPT_DIR/workspaces/$DOMAIN"  # Workspace directory for the domain
YAML_FILE="$WORKSPACES_DIR/parameters.yaml"  # Path to the YAML file
OUTPUT_DIR="$WORKSPACES_DIR/sql"                 # Output directory (same as workspace)

# Check if the workspaces/<domain> directory exists
if [ ! -d "$WORKSPACES_DIR" ]; then
    echo "Error: The directory workspaces/$DOMAIN does not exist."
    exit 1
fi

# Clear *.sql files in the workspace directory
rm -rf $WORKSPACES_DIR/sql/*sql
# Check if the YAML file exists
if [ ! -f "$YAML_FILE" ]; then
    echo "Error: The YAML file $YAML_FILE does not exist."
    exit 1
fi

# Check if the templates directory exists
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "Error: The templates directory does not exist."
    exit 1
fi

# Loop through each .sql file in the templates directory
for template_file in "$TEMPLATES_DIR"/*.sql; do
    # Check if there are no .sql files in the templates directory
    if [ ! -f "$template_file" ]; then
        echo "No .sql files found in the templates directory."
        exit 1
    fi

    # Get the base name of the template file (without path and extension)
    base_name=$(basename "$template_file" .sql)

    # Define the output file path
    output_file="$OUTPUT_DIR/$base_name.sql"

    # Run the Python script to generate SQL from the template and YAML file
    python3 "$SCRIPT_DIR/generate_sql.py" "$YAML_FILE" "$template_file" "$output_file"

    # Check if the Python script executed successfully
    if [ $? -eq 0 ]; then
        echo "Generated SQL for $base_name and saved to $output_file"
    else
        echo "Error generating SQL for $base_name"
    fi
done
