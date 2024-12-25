# Python script to generate the SQL based on placeholders.

Below is the SQL script converted into a Jinja template format with the specified placeholders replaced by Jinja template syntax (`{{ }}`) for dynamic variables such as `domain`, `admin_user`, `creator_user`, and `viewer_user`.

### Jinja Template for SQL Script

```sql
-- Create the database, schema, and warehouse if they do not exist
CREATE DATABASE IF NOT EXISTS self_service;
CREATE SCHEMA IF NOT EXISTS self_service.{{ domain }}_schema;
CREATE WAREHOUSE IF NOT EXISTS {{ domain }}_warehouse
  WITH WAREHOUSE_SIZE = 'XSMALL'  -- Adjust the size as needed
  AUTO_SUSPEND = 300              -- Suspend after 5 minutes of inactivity
  AUTO_RESUME = TRUE;

-- Create the roles if they do not exist
CREATE ROLE IF NOT EXISTS {{ domain }}_admin;
CREATE ROLE IF NOT EXISTS {{ domain }}_creator;
CREATE ROLE IF NOT EXISTS {{ domain }}_viewer;

-- Create the budget for the self_service domain (data mesh)
CREATE BUDGET IF NOT EXISTS self_service_{{ domain }}_budget
  WITH
    CURRENCY = 'USD'                   -- Define the currency (optional, defaults to USD)
    CREDIT_QUOTA = 50                   -- Set the credit limit (for example, 50 credits)
    NOTIFY_WHEN_QUOTA_EXCEEDED = TRUE   -- Notify when the quota is exceeded
    NOTIFY_WHEN_90_PERCENT_REACHED = TRUE  -- Notify when 90% of the quota is reached
    NOTIFY_WHEN_100_PERCENT_REACHED = TRUE -- Notify when 100% of the quota is reached
    MONITORING_SCOPE = 'WAREHOUSE'      -- Link the budget to the domain warehouse
    ASSOCIATED_WITH_DATABASE = 'self_service'
    ASSOCIATED_WITH_WAREHOUSE = '{{ domain }}_warehouse';

-- Grant MONITOR privileges to {{ domain }}_admin and {{ domain }}_creator for the budget
GRANT MONITOR ON BUDGET self_service_{{ domain }}_budget TO ROLE {{ domain }}_admin;
GRANT MONITOR ON BUDGET self_service_{{ domain }}_budget TO ROLE {{ domain }}_creator;

-- Grant MONITOR privileges on the warehouse to {{ domain }}_admin and {{ domain }}_creator
GRANT MONITOR ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_admin;
GRANT MONITOR ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_admin full privileges on all objects and future objects in the schema
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE STREAMS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE TASKS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE PIPELINES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;

-- Grant {{ domain }}_admin the ability to grant roles to others
GRANT ROLE {{ domain }}_creator TO ROLE {{ domain }}_admin;
GRANT ROLE {{ domain }}_viewer TO ROLE {{ domain }}_admin;

-- Grant {{ domain }}_creator the ability to create objects in the schema
GRANT USAGE ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_creator;
GRANT USAGE ON SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT CREATE TABLE, CREATE TASK, CREATE PIPELINE, CREATE STREAM, CREATE VIEW TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_creator privileges on future objects (including views)
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT USAGE ON FUTURE TASKS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_viewer read-only access to the schema and usage on the warehouse
GRANT USAGE ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_viewer;
GRANT SELECT ON FUTURE TABLES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT USAGE ON SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT USAGE ON FUTURE TASKS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;

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

### Python Code to Generate the SQL from the Jinja Template

To generate the SQL from the Jinja template in Python, you can use the `jinja2` library. Below is a Python script that takes parameters like `domain`, `admin_user`, `creator_user`, and `viewer_user`, and renders the SQL from the template:

```python
import jinja2

# Define a function to render the SQL
def generate_sql(domain, admin_user, creator_user, viewer_user):
    # Jinja template string (it can be loaded from a file as well)
    template_str = """
    -- Create the database, schema, and warehouse if they do not exist
    CREATE DATABASE IF NOT EXISTS self_service;
    CREATE SCHEMA IF NOT EXISTS self_service.{{ domain }}_schema;
    CREATE WAREHOUSE IF NOT EXISTS {{ domain }}_warehouse
      WITH WAREHOUSE_SIZE = 'XSMALL'  -- Adjust the size as needed
      AUTO_SUSPEND = 300              -- Suspend after 5 minutes of inactivity
      AUTO_RESUME = TRUE;

    -- Create the roles if they do not exist
    CREATE ROLE IF NOT EXISTS {{ domain }}_admin;
    CREATE ROLE IF NOT EXISTS {{ domain }}_creator;
    CREATE ROLE IF NOT EXISTS {{ domain }}_viewer;

    -- Create the budget for the self_service domain (data mesh)
    CREATE BUDGET IF NOT EXISTS self_service_{{ domain }}_budget
      WITH
        CURRENCY = 'USD'                   -- Define the currency (optional, defaults to USD)
        CREDIT_QUOTA = 50                   -- Set the credit limit (for example, 50 credits)
        NOTIFY_WHEN_QUOTA_EXCEEDED = TRUE   -- Notify when the quota is exceeded
        NOTIFY_WHEN_90_PERCENT_REACHED = TRUE  -- Notify when 90% of the quota is reached
        NOTIFY_WHEN_100_PERCENT_REACHED = TRUE -- Notify when 100% of the quota is reached
        MONITORING_SCOPE = 'WAREHOUSE'      -- Link the budget to the domain warehouse
        ASSOCIATED_WITH_DATABASE = 'self_service'
        ASSOCIATED_WITH_WAREHOUSE = '{{ domain }}_warehouse';

    -- Grant MONITOR privileges to {{ domain }}_admin and {{ domain }}_creator for the budget
    GRANT MONITOR ON BUDGET self_service_{{ domain }}_budget TO ROLE {{ domain }}_admin;
    GRANT MONITOR ON BUDGET self_service_{{ domain }}_budget TO ROLE {{ domain }}_creator;

    -- Grant MONITOR privileges on the warehouse to {{ domain }}_admin and {{ domain }}_creator
    GRANT MONITOR ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_admin;
    GRANT MONITOR ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_creator;

    -- Grant {{ domain }}_admin full privileges on all objects and future objects in the schema
    GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;
    GRANT ALL PRIVILEGES ON FUT

URE VIEWS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;
    GRANT ALL PRIVILEGES ON FUTURE STREAMS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;
    GRANT ALL PRIVILEGES ON FUTURE TASKS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;
    GRANT ALL PRIVILEGES ON FUTURE PIPELINES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_admin;

    -- Grant {{ domain }}_admin the ability to grant roles to others
    GRANT ROLE {{ domain }}_creator TO ROLE {{ domain }}_admin;
    GRANT ROLE {{ domain }}_viewer TO ROLE {{ domain }}_admin;

    -- Grant {{ domain }}_creator the ability to create objects in the schema
    GRANT USAGE ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_creator;
    GRANT USAGE ON SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
    GRANT CREATE TABLE, CREATE TASK, CREATE PIPELINE, CREATE STREAM, CREATE VIEW TO ROLE {{ domain }}_creator;

    -- Grant {{ domain }}_creator privileges on future objects (including views)
    GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
    GRANT USAGE ON FUTURE STREAMS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
    GRANT USAGE ON FUTURE TASKS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
    GRANT USAGE ON FUTURE PIPELINES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;
    GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_creator;

    -- Grant {{ domain }}_viewer read-only access to the schema and usage on the warehouse
    GRANT USAGE ON WAREHOUSE {{ domain }}_warehouse TO ROLE {{ domain }}_viewer;
    GRANT SELECT ON FUTURE TABLES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
    GRANT SELECT ON FUTURE VIEWS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
    GRANT USAGE ON SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
    GRANT USAGE ON FUTURE STREAMS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
    GRANT USAGE ON FUTURE TASKS IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;
    GRANT USAGE ON FUTURE PIPELINES IN SCHEMA self_service.{{ domain }}_schema TO ROLE {{ domain }}_viewer;

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
    """

    # Create a Jinja environment
    env = jinja2.Environment(
        loader=jinja2.BaseLoader()
    )

    # Compile the template
    template = env.from_string(template_str)

    # Render the template with parameters
    rendered_sql = template.render(
        domain=domain,
        admin_user=admin_user,
        creator_user=creator_user,
        viewer_user=viewer_user
    )

    return rendered_sql

# Example usage
sql = generate_sql('sales', 'admin123', 'creator456', 'viewer789')
print(sql)
```

### How to Use the Python Script:
1. Install Jinja2 if you haven't already:
   ```bash
   pip install jinja2
   ```

2. Run the Python script, passing the required parameters (`domain`, `admin_user`, `creator_user`, `viewer_user`) to the `generate_sql` function.

3. The script will output the rendered SQL based on the input parameters.

