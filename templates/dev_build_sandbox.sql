-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Create a sandbox environment for a domain in the {{ self_service_db }} database.
-- The script creates the following objects:
-- - A schema for the domain
-- - A warehouse for the domain
-- - Roles for the domain (admin, creator, viewer)
-- - A budget for the domain
-- - Grants privileges to the roles
-- - Assigns roles to users
-- The script is idempotent and can be run multiple times without causing errors.


-- Create the database, schema, and warehouse if they do not exist
CREATE DATABASE IF NOT EXISTS {{ self_service_db }};
CREATE SCHEMA IF NOT EXISTS {{ self_service_db }}.{{ domain }}_sh;
CREATE WAREHOUSE IF NOT EXISTS {{ domain }}_wh
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
    ASSOCIATED_WITH_wh = '{{ domain }}_wh';

-- Grant MONITOR privileges to {{ domain }}_admin and {{ domain }}_creator for the budget
GRANT MONITOR ON BUDGET {{ self_service_db }}_{{ domain }}_budget TO ROLE {{ domain }}_admin;
GRANT MONITOR ON BUDGET {{ self_service_db }}_{{ domain }}_budget TO ROLE {{ domain }}_creator;

-- Grant MONITOR privileges on the warehouse to {{ domain }}_admin and {{ domain }}_creator
GRANT MONITOR ON WAREHOUSE {{ domain }}_wh TO ROLE {{ domain }}_admin;
GRANT MONITOR ON WAREHOUSE {{ domain }}_wh TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_admin full privileges on all objects and future objects in the schema
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE STREAMS IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE TASKS IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_admin;
GRANT ALL PRIVILEGES ON FUTURE PIPELINES IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_admin;

-- Grant {{ domain }}_admin the ability to grant roles to others
GRANT ROLE {{ domain }}_creator TO ROLE {{ domain }}_admin;
GRANT ROLE {{ domain }}_viewer TO ROLE {{ domain }}_admin;

-- Grant {{ domain }}_creator the ability to create objects in the schema
GRANT USAGE ON WAREHOUSE {{ domain }}_wh TO ROLE {{ domain }}_creator;
GRANT USAGE ON SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_creator;
GRANT CREATE TABLE, CREATE TASK, CREATE PIPELINE, CREATE STREAM, CREATE VIEW TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_creator privileges on future objects (including views)
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_creator;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_creator;
GRANT USAGE ON FUTURE TASKS IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_creator;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_creator;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_viewer read-only access to the schema and usage on the warehouse
GRANT USAGE ON WAREHOUSE {{ domain }}_wh TO ROLE {{ domain }}_viewer;
GRANT SELECT ON FUTURE TABLES IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_viewer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_viewer;
GRANT USAGE ON SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_viewer;
GRANT USAGE ON FUTURE STREAMS IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_viewer;
GRANT USAGE ON FUTURE TASKS IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_viewer;
GRANT USAGE ON FUTURE PIPELINES IN SCHEMA {{ self_service_db }}.{{ domain }}_sh TO ROLE {{ domain }}_viewer;

-- Assign roles to users (replace <admin_user>, <creator_user>, <viewer_user> with actual usernames)
BEGIN
    -- Admins
    {% for admin_user in admin_users %}
        -- Check if the role is already granted
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_ADMIN' AND GRANTEE_NAME = '{{ admin_user }}') THEN
            GRANT ROLE {{ domain }}_ADMIN TO USER {{ admin_user }};
        END IF;
    {% endfor %}
    -- Creators
    {% for creator_user in creator_users %}
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_CREATOR' AND GRANTEE_NAME = '{{ creator_user }}') THEN
            GRANT ROLE {{ domain }}_creator TO USER {{ creator_user }};
        END IF;
    {% endfor %}
    -- Viewers
    {% for viewer_user in viewer_users %}

        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_VIEWER' AND GRANTEE_NAME = '{{ viewer_user }}') THEN
            GRANT ROLE {{ domain }}_viewer TO USER {{ viewer_user }};
        END IF;
    {% endfor %}

END;