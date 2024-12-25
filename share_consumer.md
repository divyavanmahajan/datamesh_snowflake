# Consuming shared data from the 'prod' account to the 'dev' account.
[Go back](./README.md)

The 'prod' account is the central landing zone which stores all the data products to be shared by the 'dev'/mesh domains. See [Microsoft: Self serve data platforms](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/architectures/self-serve-data-platforms)


To **mount a share** in the **dev account** using the `CREATE DATABASE FROM SHARE` syntax, you will follow these steps. This method is the preferred way to create a **database** directly from a **share** in Snowflake, which allows the **dev account** to access the shared data from the **prod account** (RZ556038) using a **share**.

### Key Steps:
1. **Create a database in the dev account** using the `CREATE DATABASE FROM SHARE` statement.
2. **Grant access** to the roles (`domain_admin`, `domain_creator`, `domain_viewer`) for the shared database, schema, tables, and views.
3. Ensure that the roles have access to **future objects** (tables, views, etc.) that may be added to the shared database.

### Step 1: Create the Database from the Share in the Dev Account

First, create a **database** in the **dev account** that will reference the **share** `domain_sh` from the **prod account** (RZ556038). We use the `CREATE DATABASE FROM SHARE` syntax to directly reference the share published by the prod account.

```sql
-- In the dev account, create a database from the shared domain_sh
CREATE DATABASE IF NOT EXISTS domain_share_db
  FROM SHARE <prod_account_id>.domain_sh;  -- Replace with actual share name from prod account
```

### Step 2: Grant Access to the Shared Database, Schema, and Objects

Once the database is created, you will grant access to the **`domain_admin`**, **`domain_creator`**, and **`domain_viewer`** roles in the **dev account** so they can access the shared data.

#### 1. Grant `USAGE` on the Shared Database

You need to grant the roles **`USAGE`** on the newly created database to allow them to access it.

```sql
-- Grant access to the domain_share_db (the mounted share) to the relevant roles
GRANT USAGE ON DATABASE domain_share_db TO ROLE domain_admin;
GRANT USAGE ON DATABASE domain_share_db TO ROLE domain_creator;
GRANT USAGE ON DATABASE domain_share_db TO ROLE domain_viewer;
```

#### 2. Grant `USAGE` on the Schema within the Shared Database

The next step is to grant **`USAGE`** on the **schema** within the shared database. This will allow roles to access objects (tables, views) in the schema.

```sql
-- Grant usage on the schema within the shared database to the roles
GRANT USAGE ON SCHEMA domain_share_db.public TO ROLE domain_admin;
GRANT USAGE ON SCHEMA domain_share_db.public TO ROLE domain_creator;
GRANT USAGE ON SCHEMA domain_share_db.public TO ROLE domain_viewer;
```

#### 3. Grant Permissions on Tables and Views in the Shared Schema

You will then grant **`SELECT`** privileges to the roles on the tables and views in the shared schema (`public` in this case).

```sql
-- Grant access to all tables and views in the shared schema
GRANT SELECT ON ALL TABLES IN SCHEMA domain_share_db.public TO ROLE domain_admin;
GRANT SELECT ON ALL VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_admin;

GRANT SELECT ON ALL TABLES IN SCHEMA domain_share_db.public TO ROLE domain_creator;
GRANT SELECT ON ALL VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_creator;

GRANT SELECT ON ALL TABLES IN SCHEMA domain_share_db.public TO ROLE domain_viewer;
GRANT SELECT ON ALL VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_viewer;
```

#### 4. Grant Access to Future Tables and Views

To ensure that the roles also have access to **future tables** and **future views** that might be added to the shared schema, you will grant the `SELECT` privilege on **future tables** and **future views**.

```sql
-- Grant access to future tables and views in the shared schema
GRANT SELECT ON FUTURE TABLES IN SCHEMA domain_share_db.public TO ROLE domain_admin;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_admin;

GRANT SELECT ON FUTURE TABLES IN SCHEMA domain_share_db.public TO ROLE domain_creator;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_creator;

GRANT SELECT ON FUTURE TABLES IN SCHEMA domain_share_db.public TO ROLE domain_viewer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_viewer;
```

### Step 3: Verify the Setup

After the roles are granted access, the **`domain_admin`**, **`domain_creator`**, and **`domain_viewer`** roles should be able to query the shared data.

For example, as **`domain_viewer`**, you can run:

```sql
-- Verify access to a shared table
SELECT * FROM domain_share_db.public.some_shared_table;

-- Verify access to a shared view
SELECT * FROM domain_share_db.public.some_shared_view;
```

### Complete Script to Create the Share Database and Grant Permissions

Here is the full script to mount the share, grant the necessary privileges, and ensure that the roles can access the shared data:

```sql
-- Step 1: Create the database from the shared domain_sh in the prod account
CREATE DATABASE IF NOT EXISTS domain_share_db
  FROM SHARE <prod_account_id>.domain_sh;  -- Replace with actual share name from prod account

-- Step 2: Grant access to the domain_share_db (mounted share) to the relevant roles
GRANT USAGE ON DATABASE domain_share_db TO ROLE domain_admin;
GRANT USAGE ON DATABASE domain_share_db TO ROLE domain_creator;
GRANT USAGE ON DATABASE domain_share_db TO ROLE domain_viewer;

-- Step 3: Grant usage on the schema within the shared database to the roles
GRANT USAGE ON SCHEMA domain_share_db.public TO ROLE domain_admin;
GRANT USAGE ON SCHEMA domain_share_db.public TO ROLE domain_creator;
GRANT USAGE ON SCHEMA domain_share_db.public TO ROLE domain_viewer;

-- Step 4: Grant access to all tables and views in the shared schema
GRANT SELECT ON ALL TABLES IN SCHEMA domain_share_db.public TO ROLE domain_admin;
GRANT SELECT ON ALL VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_admin;

GRANT SELECT ON ALL TABLES IN SCHEMA domain_share_db.public TO ROLE domain_creator;
GRANT SELECT ON ALL VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_creator;

GRANT SELECT ON ALL TABLES IN SCHEMA domain_share_db.public TO ROLE domain_viewer;
GRANT SELECT ON ALL VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_viewer;

-- Step 5: Grant access to future tables and views in the shared schema
GRANT SELECT ON FUTURE TABLES IN SCHEMA domain_share_db.public TO ROLE domain_admin;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_admin;

GRANT SELECT ON FUTURE TABLES IN SCHEMA domain_share_db.public TO ROLE domain_creator;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_creator;

GRANT SELECT ON FUTURE TABLES IN SCHEMA domain_share_db.public TO ROLE domain_viewer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA domain_share_db.public TO ROLE domain_viewer;
```

### Key Points:

1. **`CREATE DATABASE FROM SHARE`**: This creates a **new database** in the **dev account** from the shared data in the **prod account**.
2. **Granting `USAGE` and `SELECT`**: The roles are granted `USAGE` on the database and schema and `SELECT` on the tables and views in the schema.
3. **Future Objects**: Access to **future tables** and **views** is granted, ensuring that the roles have access to any new objects added to the shared schema.

This setup ensures that the **`domain_admin`**, **`domain_creator`**, and **`domain_viewer`** roles in the **dev account** can access the shared data from the **prod account**.
