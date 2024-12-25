# Python script to generate the SQL based on placeholders.

Below is the SQL script converted into a Jinja template format with the specified placeholders replaced by Jinja template syntax (`{{ }}`) for dynamic variables such as `domain`, `self_service_db`, `admin_user`, `creator_user`, and `viewer_user`.

### 1. Jinja Template File (`sql_template.sql`)

In the Jinja template, we will replace `self_service` with `self_service_db` so that the database name is dynamically injected with the new variable.

#### `sql_template.sql`

```sql
-- Create the database, schema, and warehouse if they do not exist
CREATE DATABASE IF NOT EXISTS {{ self_service_db }};
CREATE SCHEMA IF NOT EXISTS {{ self_service_db }}.{{ domain }}_schema;
CREATE WAREHOUSE IF NOT EXISTS {{ domain }}_warehouse
  WITH WAREHOUSE_SIZE = 'XSMALL'  -- Adjust the size as needed
  AUTO_SUSPEND = 300              -- Suspend after 5 minutes of inactivity
  AUTO_RESUME = TRUE;

-- Create the roles if they do not exist
CREATE ROLE IF NOT EXISTS {{ domain }}_admin;
CREATE ROLE IF NOT EXISTS {{ domain }}_creator;
CREATE ROLE IF NOT EXISTS {{ domain }}_viewer;

-- Create the budget for the {{ self_service_db }} domain (data mesh)
CREATE BUDGET IF NOT EXISTS {{ self_service_db }}_{{ domain }}_budget
  WITH
    CURRENCY = 'USD'                   -- Define the currency (optional, defaults to USD)
    CREDIT_QUOTA = 50                   -- Set the credit limit (for example, 50 credits)
    NOTIFY_WHEN_QUOTA_EXCEEDED = TRUE   -- Notify when the quota is exceeded
    NOTIFY_WHEN_90_PERCENT_REACHED = TRUE  -- Notify when 90% of the quota is reached
    NOTIFY_WHEN_100_PERCENT_REACHED = TRUE -- Notify when 100% of the quota is reached
    MONITORING_SCOPE = 'WAREHOUSE'      -- Link the budget to the domain warehouse
    ASSOCIATED_WITH_DATABASE = '{{ self_service_db }}'
    ASSOCIATED_WITH_WAREHOUSE = '{{ domain }}_warehouse';

-- Grant MONITOR privileges to {{ domain }}_admin and {{ domain }}_creator for the budget
GRANT MONITOR ON BUDGET {{ self_service_db }}_{{ domain }}_budget TO ROLE {{ domain }}_admin;
GRANT MONITOR ON BUDGET {{ self_service_db }}_{{ domain }}_budget TO ROLE {{ domain }}_creator;

-- Grant MONITOR privileges on the warehouse to {{ domain }}_admin and {{ domain }}_creator
GRANT MONITOR ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_admin;
GRANT MONITOR ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_admin full privileges on all objects and future objects in the schema
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE STREAMS IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE TASKS IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE PIPELINES IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_admin;

-- Grant {{ domain }}_admin the ability to grant roles to others
GRANT ROLE {{ domain }}_creator TO ROLE {{ domain }}_admin;
GRANT ROLE {{ domain }}_viewer TO ROLE {{ domain }}_admin;

-- Grant {{ domain }}_creator the ability to create objects in the schema
GRANT USAGE ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_creator;
GRANT USAGE ON SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT CREATE TABLE, CREATE TASK, CREATE PIPELINE, CREATE STREAM, CREATE VIEW TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_creator privileges on future objects (including views)
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT USAGE ON FUTURE TASKS IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_viewer read-only access to the schema and usage on the warehouse
GRANT USAGE ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_viewer;
GRANT SELECT ON FUTURE TABLES IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT USAGE ON SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT USAGE ON FUTURE TASKS IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA {{ self_service_db }}.{{ domain }}_schema TO ROLE {{ domain }}_viewer;

-- Assign roles to users (replace <admin_user>, <creator_user>, <viewer_user> with actual usernames)
BEGIN
    -- Check if the role is already granted
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_ADMIN' AND GRANTEE_NAME = '{{ admin_user }}') THEN
        GRANT ROLE {{ domain }}_admin TO USER {{ admin_user }};
    END IF;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_CREATOR' AND GRANTEE_NAME = '{{ creator_user }}') THEN
        GRANT ROLE {{ domain }}_creator TO USER {{ creator_user }};
    END IF;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_VIEWER' AND GRANTEE_NAME = '{{ viewer_user }}') THEN
        GRANT ROLE {{ domain }}_viewer TO USER {{ viewer_user }};
    END IF;
END;
```

### 2. Updated YAML File (`parameters.yaml`)

Create a file called `parameters.yaml` where you can specify the values for the variables.

#### `parameters.yaml`

```yaml
self_service_db: "self_service"  # Define the database name dynamically
domain: "sales"
admin_user: "admin123"
creator_user: "creator456"
viewer_user: "viewer789"
```

### 3. Updated Python Code (`generate_sql.py`)

The Python script will read the parameters from the `parameters.yaml` file and use Jinja to render the SQL using the template from the `sql_template.sql` file.

#### `generate_sql.py`

```python
import jinja2
import yaml

# Function to load YAML parameters
def load_parameters(yaml_file):
    with open(yaml_file, 'r') as f:
        return yaml.safe_load(f)

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
    # Load parameters from the YAML file
    params = load_parameters('parameters.yaml')

    # Generate SQL from the Jinja template
    sql = generate_sql('sql_template.sql', params)

    # Output the generated SQL
    print(sql)

if __name__ == "__main__":
    main()
```

### 4. How to Run

1. **Install dependencies** (if you haven't already):
   ```bash
   pip install jinja2 pyyaml
   ```

2. **Ensure you have the following files in the same directory:**
   - `sql_template.sql` (the Jinja template)
   - `parameters.yaml` (the YAML file with parameters)
   - `generate_sql.py` (the Python script)

3. **Run the Python script**:
   ```bash
   python generate_sql.py
   ```

### Example Output:

If the `parameters.yaml` file contains:

```yaml
self_service_db: "self_service"
domain: "sales"
admin_user: "admin123"
creator_user: "creator456"
viewer_user: "viewer789"
```

The output might look like this:

```sql
-- Create the database, schema, and warehouse if they

 do not exist
CREATE DATABASE IF NOT EXISTS self_service;
CREATE SCHEMA IF NOT EXISTS self_service.sales_schema;
CREATE WAREHOUSE IF NOT EXISTS sales_warehouse
  WITH WAREHOUSE_SIZE = 'XSMALL'  -- Adjust the size as needed
  AUTO_SUSPEND = 300              -- Suspend after 5 minutes of inactivity
  AUTO_RESUME = TRUE;
...
```


