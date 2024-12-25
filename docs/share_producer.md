# Share data as a producer by creating a share domain_sh in the producer account.

The producer is in the "prod" account. 

This script will allow the **`domain_sh`** share in the **prod account** to include:
- All tables in the **`erp`** and **`crm`** schemas of the **`silver`** database.
- The **`vendor`**, **`customer`**, and **`address`** tables in the **`partners`** schema of the **`silver`** database.
- Any future tables added to these schemas.
- 
### Full SQL Script to Create the Share in the Prod Account

```sql
-- Step 1: Create the share in the prod account (if not already created)
CREATE SHARE IF NOT EXISTS domain_sh;

-- Step 2: Grant access to all tables in the `erp` schema of the `silver` database
GRANT USAGE ON DATABASE silver TO SHARE domain_sh;
GRANT USAGE ON SCHEMA silver.erp TO SHARE domain_sh;
GRANT SELECT ON ALL TABLES IN SCHEMA silver.erp TO SHARE domain_sh;

-- Step 3: Grant access to all tables in the `crm` schema of the `silver` database
GRANT USAGE ON SCHEMA silver.crm TO SHARE domain_sh;
GRANT SELECT ON ALL TABLES IN SCHEMA silver.crm TO SHARE domain_sh;

-- Step 4: Grant access to all tables in the `partners` schema of the `silver` database
GRANT USAGE ON SCHEMA silver.partners TO SHARE domain_sh;
GRANT SELECT ON TABLE silver.partners.vendor TO SHARE domain_sh;
GRANT SELECT ON TABLE silver.partners.customer TO SHARE domain_sh;
GRANT SELECT ON TABLE silver.partners.address TO SHARE domain_sh;

-- Step 5: Grant access to future tables in the `erp` schema of the `silver` database
GRANT SELECT ON FUTURE TABLES IN SCHEMA silver.erp TO SHARE domain_sh;

-- Step 6: Grant access to future tables in the `crm` schema of the `silver` database
GRANT SELECT ON FUTURE TABLES IN SCHEMA silver.crm TO SHARE domain_sh;

-- Step 7: Grant access to future tables in the `partners` schema of the `silver` database
GRANT SELECT ON FUTURE TABLES IN SCHEMA silver.partners TO SHARE domain_sh;
```

### Explanation of Each Step:

1. **Create the Share**: The `CREATE SHARE IF NOT EXISTS` command ensures the share (`domain_sh`) is created if it doesn't already exist.
  
2. **Grant Permissions for `silver.erp` and `silver.crm`**:
   - These steps grant the **`USAGE`** privilege on the **`silver`** database and its **`erp`** and **`crm`** schemas.
   - The **`SELECT`** permission is granted on **all tables** in both schemas.

3. **Grant Permissions for Specific Tables in `silver.partners`**:
   - The **`USAGE`** permission is granted on the **`silver.partners`** schema.
   - The **`SELECT`** permission is granted on the **`vendor`**, **`customer`**, and **`address`** tables within the **`silver.partners`** schema.

4. **Grant Future Table Access**:
   - The **`SELECT`** permission is granted on **future tables** in the **`erp`**, **`crm`**, and **`partners`** schemas. This ensures that any new tables added to these schemas will automatically be included in the share.

### Key Notes:
- **`GRANT USAGE ON SCHEMA`**: Ensures the share can access the schema and its objects (tables, views).
- **`GRANT SELECT ON TABLE`**: Grants read access to the specific tables in the **`silver.partners`** schema.
- **`GRANT SELECT ON FUTURE TABLES`**: Automatically applies to any new tables added to the schema in the future.



