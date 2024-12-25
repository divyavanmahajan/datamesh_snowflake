-- Git commit: a981586
-- Last generated on: 2024-12-25 21:48:26

-- Create a sandbox environment for a domain in the self_service database.
-- The script creates the following objects:
-- - A schema for the domain
-- - A warehouse for the domain
-- - Roles for the domain (admin, creator, viewer)
-- - A budget for the domain
-- - Grants privileges to the roles
-- - Assigns roles to users
-- The script is idempotent and can be run multiple times without causing errors.


-- Create the database, schema, and warehouse if they do not exist
CREATE DATABASE IF NOT EXISTS self_service;
CREATE SCHEMA IF NOT EXISTS self_service.cs_emeacla_sh;
CREATE WAREHOUSE IF NOT EXISTS cs_emeacla_wh
  WITH WAREHOUSE_SIZE = 'XSMALL'  -- Adjust the size as needed
  AUTO_SUSPEND = 300              -- Suspend after 5 minutes of inactivity
  AUTO_RESUME = TRUE;

-- Create the roles if they do not exist
CREATE ROLE IF NOT EXISTS cs_emeacla_admin;
CREATE ROLE IF NOT EXISTS cs_emeacla_creator;
CREATE ROLE IF NOT EXISTS cs_emeacla_viewer;

-- Create the budget for the self_service domain (data mesh)
CREATE BUDGET IF NOT EXISTS self_service_cs_emeacla_budget
  WITH
    CURRENCY = 'USD'                   -- Define the currency (optional, defaults to USD)
    CREDIT_QUOTA = 50                   -- Set the credit limit (for example, 50 credits)
    NOTIFY_WHEN_QUOTA_EXCEEDED = TRUE   -- Notify when the quota is exceeded
    NOTIFY_WHEN_90_PERCENT_REACHED = TRUE  -- Notify when 90% of the quota is reached
    NOTIFY_WHEN_100_PERCENT_REACHED = TRUE -- Notify when 100% of the quota is reached
    MONITORING_SCOPE = 'WAREHOUSE'      -- Link the budget to the domain warehouse
    ASSOCIATED_WITH_DATABASE = 'self_service'
    ASSOCIATED_WITH_wh = 'cs_emeacla_wh';

-- Grant MONITOR privileges to cs_emeacla_admin and cs_emeacla_creator for the budget
GRANT MONITOR ON BUDGET self_service_cs_emeacla_budget TO ROLE cs_emeacla_admin;
GRANT MONITOR ON BUDGET self_service_cs_emeacla_budget TO ROLE cs_emeacla_creator;

-- Grant MONITOR privileges on the warehouse to cs_emeacla_admin and cs_emeacla_creator
GRANT MONITOR ON WAREHOUSE cs_emeacla_wh TO ROLE cs_emeacla_admin;
GRANT MONITOR ON WAREHOUSE cs_emeacla_wh TO ROLE cs_emeacla_creator;

-- Grant cs_emeacla_admin full privileges on all objects and future objects in the schema
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_admin;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_admin;
GRANT ALL PRIVILEGES ON FUTURE STREAMS IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_admin;
GRANT ALL PRIVILEGES ON FUTURE TASKS IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_admin;
GRANT ALL PRIVILEGES ON FUTURE PIPELINES IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_admin;

-- Grant cs_emeacla_admin the ability to grant roles to others
GRANT ROLE cs_emeacla_creator TO ROLE cs_emeacla_admin;
GRANT ROLE cs_emeacla_viewer TO ROLE cs_emeacla_admin;

-- Grant cs_emeacla_creator the ability to create objects in the schema
GRANT USAGE ON WAREHOUSE cs_emeacla_wh TO ROLE cs_emeacla_creator;
GRANT USAGE ON SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_creator;
GRANT CREATE TABLE, CREATE TASK, CREATE PIPELINE, CREATE STREAM, CREATE VIEW TO ROLE cs_emeacla_creator;

-- Grant cs_emeacla_creator privileges on future objects (including views)
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_creator;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_creator;
GRANT USAGE ON FUTURE TASKS IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_creator;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_creator;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_creator;

-- Grant cs_emeacla_viewer read-only access to the schema and usage on the warehouse
GRANT USAGE ON WAREHOUSE cs_emeacla_wh TO ROLE cs_emeacla_viewer;
GRANT SELECT ON FUTURE TABLES IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_viewer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_viewer;
GRANT USAGE ON SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_viewer;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_viewer;
GRANT USAGE ON FUTURE TASKS IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_viewer;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA self_service.cs_emeacla_sh TO ROLE cs_emeacla_viewer;

-- Assign roles to users (replace <admin_user>, <creator_user>, <viewer_user> with actual usernames)
BEGIN
    -- Admins
    
        -- Check if the role is already granted
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_ADMIN' AND GRANTEE_NAME = 'divyavanmahajan') THEN
            GRANT ROLE cs_emeacla_ADMIN TO USER divyavanmahajan;
        END IF;
    
        -- Check if the role is already granted
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_ADMIN' AND GRANTEE_NAME = 'admin2') THEN
            GRANT ROLE cs_emeacla_ADMIN TO USER admin2;
        END IF;
    
        -- Check if the role is already granted
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_ADMIN' AND GRANTEE_NAME = 'admin3') THEN
            GRANT ROLE cs_emeacla_ADMIN TO USER admin3;
        END IF;
    
    -- Creators
    
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_CREATOR' AND GRANTEE_NAME = 'divyavanmahajan') THEN
            GRANT ROLE cs_emeacla_creator TO USER divyavanmahajan;
        END IF;
    
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_CREATOR' AND GRANTEE_NAME = 'creator456') THEN
            GRANT ROLE cs_emeacla_creator TO USER creator456;
        END IF;
    
    -- Viewers
    

        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_VIEWER' AND GRANTEE_NAME = 'divyavanmahajan') THEN
            GRANT ROLE cs_emeacla_viewer TO USER divyavanmahajan;
        END IF;
    

        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_VIEWER' AND GRANTEE_NAME = 'viewer789') THEN
            GRANT ROLE cs_emeacla_viewer TO USER viewer789;
        END IF;
    

END;