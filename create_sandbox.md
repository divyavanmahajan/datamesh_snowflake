# Creating the sandbox for the data mesh
[Go back](./README.md)

To implement a **budget** specifically for the **data mesh domain** using the newer **Snowflake Budget Object**, we will create a **budget** specific to the **domain** using the `CREATE BUDGET` command, which was introduced to manage and monitor the budget for your Snowflake usage. We'll also make sure the **`domain_admin`** and **`domain_creator`** roles have the necessary permissions to **view** and **monitor** the budget for the **data mesh domain**.

The Snowflake Budget Object allows you to track costs at a more granular level by associating it with specific resources, like a **warehouse** or a **database** (in this case, tied to the **`self_service`** domain). Here's how we can set it up:

### Step 1: Create the Budget for the Data Mesh Domain

We'll create a budget object for the **self_service** database and link it to the **`domain_admin`** and **`domain_creator`** roles. The budget will be set for the credit usage of the **`domain_warehouse`** associated with the **`self_service`** database.

```sql
-- Create the budget for the self_service domain (data mesh)
CREATE BUDGET IF NOT EXISTS self_service_domain_budget
  WITH
    CURRENCY = 'USD'                   -- Define the currency (optional, defaults to USD)
    CREDIT_QUOTA = 50                   -- Set the credit quota (for example, 50 credits)
    NOTIFY_WHEN_QUOTA_EXCEEDED = TRUE   -- Notify when the quota is exceeded
    NOTIFY_WHEN_90_PERCENT_REACHED = TRUE  -- Notify when 90% of the quota is reached
    NOTIFY_WHEN_100_PERCENT_REACHED = TRUE -- Notify when 100% of the quota is reached
    MONITORING_SCOPE = 'WAREHOUSE'      -- Link the budget to the domain warehouse
    ASSOCIATED_WITH_DATABASE = 'self_service'
    ASSOCIATED_WITH_WAREHOUSE = 'domain_warehouse';
```

### Explanation of Budget Object:
- **CREDIT_QUOTA**: The credit limit you want to enforce for the **self_service** domain (e.g., 50 credits).
- **NOTIFY_WHEN_QUOTA_EXCEEDED**: Will notify if the budget is exceeded.
- **NOTIFY_WHEN_90_PERCENT_REACHED** and **NOTIFY_WHEN_100_PERCENT_REACHED**: Notifications will be triggered when 90% or 100% of the allocated budget is consumed.
- **MONITORING_SCOPE**: This ensures the budget is tied to the warehouse (`domain_warehouse`).
- **ASSOCIATED_WITH_DATABASE**: Ensures that the budget is associated with the `self_service` database.

### Step 2: Grant Monitoring Privileges to Roles

After creating the budget, we need to grant the **`domain_admin`** and **`domain_creator`** roles the necessary privileges to monitor the budget.

```sql
-- Grant the domain_admin role the ability to monitor the self_service_domain_budget
GRANT MONITOR ON BUDGET self_service_domain_budget TO ROLE domain_admin;

-- Grant the domain_creator role the ability to monitor the self_service_domain_budget
GRANT MONITOR ON BUDGET self_service_domain_budget TO ROLE domain_creator;
```

### Step 3: Grant Monitoring Access to Warehouse (for context)

While the budget is tied to the **`self_service_domain_budget`** object, you also want to ensure that the **`domain_admin`** and **`domain_creator`** roles can monitor the **warehouse** (e.g., `domain_warehouse`) so that they can track usage and correlate it with the budget.

```sql
-- Grant MONITOR privileges on the domain warehouse to domain_admin
GRANT MONITOR ON WAREHOUSE domain_warehouse TO ROLE domain_admin;

-- Grant MONITOR privileges on the domain warehouse to domain_creator
GRANT MONITOR ON WAREHOUSE domain_warehouse TO ROLE domain_creator;
```

Here's the full idempotent script integrating the **budget** with the **data mesh** and ensuring **monitoring** access:

### Full Idempotent Script with Views Included

```sql
-- Create the database, schema, and warehouse if they do not exist
CREATE DATABASE IF NOT EXISTS self_service;
CREATE SCHEMA IF NOT EXISTS self_service.domain_schema;
CREATE WAREHOUSE IF NOT EXISTS domain_warehouse
  WITH WAREHOUSE_SIZE = 'XSMALL'  -- Adjust the size as needed
  AUTO_SUSPEND = 300              -- Suspend after 5 minutes of inactivity
  AUTO_RESUME = TRUE;

-- Create the roles if they do not exist
CREATE ROLE IF NOT EXISTS domain_admin;
CREATE ROLE IF NOT EXISTS domain_creator;
CREATE ROLE IF NOT EXISTS domain_viewer;

-- Create the budget for the self_service domain (data mesh)
CREATE BUDGET IF NOT EXISTS self_service_domain_budget
  WITH
    CURRENCY = 'USD'                   -- Define the currency (optional, defaults to USD)
    CREDIT_QUOTA = 50                   -- Set the credit limit (for example, 50 credits)
    NOTIFY_WHEN_QUOTA_EXCEEDED = TRUE   -- Notify when the quota is exceeded
    NOTIFY_WHEN_90_PERCENT_REACHED = TRUE  -- Notify when 90% of the quota is reached
    NOTIFY_WHEN_100_PERCENT_REACHED = TRUE -- Notify when 100% of the quota is reached
    MONITORING_SCOPE = 'WAREHOUSE'      -- Link the budget to the domain warehouse
    ASSOCIATED_WITH_DATABASE = 'self_service'
    ASSOCIATED_WITH_WAREHOUSE = 'domain_warehouse';

-- Grant MONITOR privileges to domain_admin and domain_creator for the budget
GRANT MONITOR ON BUDGET self_service_domain_budget TO ROLE domain_admin;
GRANT MONITOR ON BUDGET self_service_domain_budget TO ROLE domain_creator;

-- Grant MONITOR privileges on the warehouse to domain_admin and domain_creator
GRANT MONITOR ON WAREHOUSE domain_warehouse TO ROLE domain_admin;
GRANT MONITOR ON WAREHOUSE domain_warehouse TO ROLE domain_creator;

-- Grant domain_admin full privileges on all objects and future objects in the schema
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA self_service.domain_schema TO ROLE domain_admin;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA self_service.domain_schema TO ROLE domain_admin;
GRANT ALL PRIVILEGES ON FUTURE STREAMS IN SCHEMA self_service.domain_schema TO ROLE domain_admin;
GRANT ALL PRIVILEGES ON FUTURE TASKS IN SCHEMA self_service.domain_schema TO ROLE domain_admin;
GRANT ALL PRIVILEGES ON FUTURE PIPELINES IN SCHEMA self_service.domain_schema TO ROLE domain_admin;

-- Grant domain_admin the ability to grant roles to others
GRANT ROLE domain_creator TO ROLE domain_admin;
GRANT ROLE domain_viewer TO ROLE domain_admin;

-- Grant domain_creator the ability to create objects in the schema
GRANT USAGE ON WAREHOUSE domain_warehouse TO ROLE domain_creator;
GRANT USAGE ON SCHEMA self_service.domain_schema TO ROLE domain_creator;
GRANT CREATE TABLE, CREATE TASK, CREATE PIPELINE, CREATE STREAM, CREATE VIEW TO ROLE domain_creator;

-- Grant domain_creator privileges on future objects (including views)
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA self_service.domain_schema TO ROLE domain_creator;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA self_service.domain_schema TO ROLE domain_creator;
GRANT USAGE ON FUTURE TASKS IN SCHEMA self_service.domain_schema TO ROLE domain_creator;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA self_service.domain_schema TO ROLE domain_creator;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA self_service.domain_schema TO ROLE domain_creator;

-- Grant domain_viewer read-only access to the schema and usage on the warehouse
GRANT USAGE ON WAREHOUSE domain_warehouse TO ROLE domain_viewer;
GRANT SELECT ON FUTURE TABLES IN SCHEMA self_service.domain_schema TO ROLE domain_viewer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA self_service.domain_schema TO ROLE domain_viewer;
GRANT USAGE ON SCHEMA self_service.domain_schema TO ROLE domain_viewer;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA self_service.domain_schema TO ROLE domain_viewer;
GRANT USAGE ON FUTURE TASKS IN SCHEMA self_service.domain_schema TO ROLE domain_viewer;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA self_service.domain_schema TO ROLE domain_viewer;

-- Assign roles to users (replace <admin_user>, <creator_user>, <viewer_user> with actual usernames)
BEGIN
    -- Check if the role is already granted
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'DOMAIN_ADMIN' AND GRANTEE_NAME = '<admin_user>') THEN
        GRANT ROLE domain_admin TO USER <admin_user>;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'DOMAIN_CREATOR' AND GRANTEE_NAME = '<creator_user>') THEN
        GRANT ROLE domain_creator TO USER <creator_user>;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'DOMAIN_VIEWER' AND GRANTEE_NAME = '<viewer_user>') THEN
        GRANT ROLE domain_viewer TO USER <viewer_user>;
    END IF;
END;
```
### Key Points:
1. **domain_admin**: 
   - Has **full ownership** and can manage all future objects (tables, views, streams, tasks, pipelines, etc.) in the schema.
   - Can grant privileges to other roles.

2. **domain_creator**: 
   - Can create and modify objects in the domain schema.
   - Has **select, insert, update, delete** access on **future tables** and **usage** privileges on **future streams, tasks, and pipelines**.
   - Cannot manage roles or grant privileges to other roles.

3. **domain_viewer**:
   - Has **read-only** access to all future tables (via `SELECT`).
   - Can **use** future streams, tasks, and pipelines for execution (but not modify).
   - Cannot modify objects.

4. **Future Grants**:
   - The `ON FUTURE` clauses ensure that any **future objects** created within the domain schema will automatically inherit the required privileges for the corresponding roles. This means any new table, view, task, stream, or pipeline will automatically have the right access for the roles.


### Key Points of Idempotency:

1. **`CREATE DATABASE` / `CREATE SCHEMA` / `CREATE ROLE` / `CREATE WAREHOUSE IF NOT EXISTS`**:
   - These statements are used to ensure that the database, schema, warehouse, and roles are only created if they don’t already exist. This prevents errors if the script is run multiple times.

2. **Ownership Grants**:
   - We use `IF NOT EXISTS` checks to ensure that **ownership** is granted only if it's not already in place. This prevents reapplication of ownership if it's already set.

3. **Future Grants**:
   - The `GRANT ALL PRIVILEGES ON FUTURE` statements ensure that any **future objects** (tables, views, streams, etc.) created in the schema will automatically inherit the necessary privileges, so there's no need to reapply them if new objects are added.

4. **Granting Roles to Users**:
   - The script checks if the **roles** are already granted to users using `INFORMATION_SCHEMA.ROLE_GRANTS`. This ensures that roles aren’t granted again if they’ve already been assigned to the user.

5. **BEGIN/END Blocks**:
   - The `BEGIN...END` blocks are used for conditional execution within Snowflake's stored procedure-like logic, but note that Snowflake does not support procedural constructs like `IF` directly for non-stored procedures (such as in SQL scripts). If you want this script to work exactly as written, you'd need to either:
     - Run this logic as part of a **Snowflake stored procedure**, or
     - Instead, make the `GRANT` statements conditional with manual checks on grants or use external scripting tools (e.g., using Python or Snowflake's Task Scheduler to manage idempotency).

### Key Points for budget:

1. **Budget Object**: 
   - The **budget** is created for the **`self_service`** domain with a **credit quota** of **50 credits**.
   - Notifications are set for **90%**, **100%**, and **over quota** (i.e., 110%).
   - The **budget** is tied to the **`domain_warehouse`** and **`self_service`** database.

2. **MONITOR Privileges**:
   - The **`domain_admin`** and **`domain_creator`** roles are granted

### Notes:

- **Replace** the placeholders `<admin_user>`, `<creator_user>`, and `<viewer_user>` with actual usernames in your environment.
- This script assumes you're running it as a user with the necessary privileges to perform `GRANT OWNERSHIP` and assign roles.


