# Python to teardown the sandbox

A similar Jinja template that removes all the Snowflake objects created in the previous script, we'll generate SQL commands to drop the objects such as the database, schema, warehouse, roles, and budget. We'll assume the same structure as before, but the SQL commands will be focused on deleting or dropping the objects.

### 1. Jinja Template to Remove Snowflake Objects (`sql_drop_template.sql`)

This template will drop the previously created Snowflake objects (database, schema, warehouse, roles, budget, etc.) based on the parameters passed.

#### `sql_drop_template.sql`

```sql
-- Drop the roles if they exist
DROP ROLE IF EXISTS {{ domain }}_admin;
DROP ROLE IF EXISTS {{ domain }}_creator;
DROP ROLE IF EXISTS {{ domain }}_viewer;

-- Drop the budget for the {{ self_service_db }} domain (data mesh)
DROP BUDGET IF EXISTS {{ self_service_db }}_{{ domain }}_budget;

-- Drop the warehouse if it exists
DROP WAREHOUSE IF EXISTS {{ domain }}_warehouse;

-- Drop the schema if it exists
DROP SCHEMA IF EXISTS {{ self_service_db }}.{{ domain }}_schema;

-- Drop the database if it exists
DROP DATABASE IF EXISTS {{ self_service_db }};

-- Optionally, revoke roles from users (optional, depends on use case)
BEGIN
    -- Revoke roles from users if granted
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_admin' AND GRANTEE_NAME = '{{ admin_user }}') THEN
        REVOKE ROLE {{ domain }}_admin FROM USER {{ admin_user }};
    END IF;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_creator' AND GRANTEE_NAME = '{{ creator_user }}') THEN
        REVOKE ROLE {{ domain }}_creator FROM USER {{ creator_user }};
    END IF;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_viewer' AND GRANTEE_NAME = '{{ viewer_user }}') THEN
        REVOKE ROLE {{ domain }}_viewer FROM USER {{ viewer_user }};
    END IF;
END;
```

### 2. Updated YAML File (`parameters.yaml`)

You will use the same `parameters.yaml` file as before, but with the necessary parameters for the `self_service_db`, `domain`, and user roles.

#### `parameters.yaml`

```yaml
self_service_db: "self_service"  # Define the database name dynamically
domain: "sales"
admin_user: "admin123"
creator_user: "creator456"
viewer_user: "viewer789"
```

### 3. Updated Python Code (`generate_drop_sql.py`)

The Python script will now load the Jinja template for dropping objects (`sql_drop_template.sql`) and use the parameters to generate the drop SQL.

#### `generate_drop_sql.py`

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
    sql = generate_sql('sql_drop_template.sql', params)

    # Output the generated SQL
    print(sql)

if __name__ == "__main__":
    main()
```

### 4. How to Run

1. **Ensure you have the following files in the same directory:**
   - `sql_drop_template.sql` (the Jinja template for dropping objects)
   - `parameters.yaml` (the YAML file with parameters)
   - `generate_drop_sql.py` (the Python script to generate the drop SQL)

2. **Install dependencies** (if you haven't already):
   ```bash
   pip install jinja2 pyyaml
   ```

3. **Run the Python script**:
   ```bash
   python generate_drop_sql.py
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

The output SQL might look like this:

```sql
-- Drop the roles if they exist
DROP ROLE IF EXISTS sales_admin;
DROP ROLE IF EXISTS sales_creator;
DROP ROLE IF EXISTS sales_viewer;

-- Drop the budget for the self_service domain (data mesh)
DROP BUDGET IF EXISTS self_service_sales_budget;

-- Drop the warehouse if it exists
DROP WAREHOUSE IF EXISTS sales_warehouse;

-- Drop the schema if it exists
DROP SCHEMA IF EXISTS self_service.sales_schema;

-- Drop the database if it exists
DROP DATABASE IF EXISTS self_service;

-- Optionally, revoke roles from users (optional, depends on use case)
BEGIN
    -- Revoke roles from users if granted
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'sales_admin' AND GRANTEE_NAME = 'admin123') THEN
        REVOKE ROLE sales_admin FROM USER admin123;
    END IF;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'sales_creator' AND GRANTEE_NAME = 'creator456') THEN
        REVOKE ROLE sales_creator FROM USER creator456;
    END IF;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'sales_viewer' AND GRANTEE_NAME = 'viewer789') THEN
        REVOKE ROLE sales_viewer FROM USER viewer789;
    END IF;
END;
```

### Notes:
- **Dropping the Database**: The SQL drops the database, schema, and warehouse along with roles and budgets.
- **Revoke Roles**: The `REVOKE` statements are optional but are included in case you want to revoke roles before removing them. If you want to keep the roles assigned to users even after the deletion, you can remove the `BEGIN ... END` block.
- **Flexibility**: You can modify the `parameters.yaml` file to change the domain, database name, or user roles as needed.
