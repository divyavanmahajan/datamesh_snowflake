import jinja2
import yaml
import argparse
import subprocess
from datetime import datetime

# Function to load YAML parameters
def load_parameters(yaml_file):
    with open(yaml_file, 'r') as f:
        return yaml.safe_load(f)

# Function to get the current Git commit hash
def get_git_commit_hash():
    try:
        # Get the short hash of the current Git commit
        result = subprocess.run(['git', 'rev-parse', '--short', 'HEAD'], capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return "unknown_commit_hash"  # Return a fallback if the command fails (e.g., not in a git repository)

# Function to get the current timestamp
def get_current_timestamp():
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# Function to generate SQL from Jinja template
def generate_sql(template_file, params):
    # Load the Jinja template from file
    with open(template_file, 'r') as file:
        template_str = file.read()

    # Create a Jinja environment
    env = jinja2.Environment(
        loader=jinja2.BaseLoader()
    )

    # Compile the template
    template = env.from_string(template_str)

    # Render the template with the parameters
    rendered_sql = template.render(params)

    return rendered_sql

# Main function to load parameters and generate SQL
def main():
    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(description="Generate SQL from a Jinja template using parameters from a YAML file.")
    parser.add_argument('yaml_file', type=str, help="Path to the YAML file containing parameters.")
    parser.add_argument('template_file', type=str, help="Path to the Jinja SQL template file.")
    parser.add_argument('output_file', type=str, help="Path to the generated SQL file.")

    # Parse the command-line arguments
    args = parser.parse_args()

    # Load parameters from the YAML file
    params = load_parameters(args.yaml_file)

    # Add current timestamp and Git commit hash to the parameters
    params['now'] = get_current_timestamp()
    params['git_commit_hash'] = get_git_commit_hash()

    # # Print all keys in the config
    # print("Keys in the config:")
    # for key in params.keys():
    #     print(key)
        
    # Generate SQL from the Jinja template
    sql = generate_sql(args.template_file, params)

    # Write the generated SQL to the output file
    with open(args.output_file, 'w') as out_file:
        out_file.write(sql)

    # Optionally print the SQL to console
    print(f"SQL has been written to {args.output_file}")

if __name__ == "__main__":
    main()
