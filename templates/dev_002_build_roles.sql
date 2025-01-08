-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Create a sandbox environment for a domain in the {{ self_service_db }} database.
-- The script creates the following objects:
-- - Roles for the domain (admin, creator, viewer)
-- - Grants privileges to the roles
-- The script is idempotent and can be run multiple times without causing errors.

-- Create the roles if they do not exist
USE ROLE SECURITYADMIN;
CREATE ROLE IF NOT EXISTS {{ domain }}_admin
  COMMENT = 'Admin role for domain {{ domain }}';
CREATE ROLE IF NOT EXISTS {{ domain }}_creator
  COMMENT = 'Creator role for domain {{ domain }}';
CREATE ROLE IF NOT EXISTS {{ domain }}_viewer
  COMMENT = 'Viewer read only role for domain {{ domain }}';
USE ROLE SYSADMIN;
USE {{ self_service_db }};

USE SECONDARY ROLE SECURITYADMIN;
ALTER ROLE {{ domain }}_admin SET TAG project = 'SELFSERVICE', domain = '{{ domain }}', costcenter = '{{ costcenter }}';
ALTER ROLE {{ domain }}_creator SET TAG project = 'SELFSERVICE', domain = '{{ domain }}', costcenter = '{{ costcenter }}';
ALTER ROLE {{ domain }}_viewer SET TAG project = 'SELFSERVICE', domain = '{{ domain }}', costcenter = '{{ costcenter }}';

-- Create a role hierarchy viewer>creator>admin>sysadmin
GRANT ROLE {{ domain }}_admin TO ROLE sysadmin;
GRANT ROLE {{ domain }}_creator TO ROLE {{ domain }}_admin;
GRANT ROLE {{ domain }}_viewer TO ROLE {{ domain }}_creator;

-- Grant privileges from the lowest level up. Higher roles inherit from the hierarchy.
-- Grant privileges to {{ domain }}_viewer and higher
GRANT USAGE ON WAREHOUSE {{ domain }}_wh TO ROLE {{ domain }}_viewer;
GRANT USAGE ON DATABASE {{ self_service_db }} TO ROLE {{ domain }}_viewer;
GRANT USAGE ON SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_viewer;

-- Grant read-only access to {{ domain }}_viewer and higher
GRANT SELECT ON FUTURE TABLES IN SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_viewer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_viewer;

-- Grant {{ domain }}_creator the ability to create objects in the schema
GRANT CREATE TABLE ON SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_creator;
GRANT CREATE VIEW ON SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_creator;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_creator;
GRANT CREATE STREAM ON SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_creator;
GRANT CREATE FUNCTION ON SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_creator;
GRANT CREATE STREAMLIT ON SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_creator;

-- Grant {{ domain }}_creator privileges on future objects (including views)
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_creator;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_creator;

-- Grant MONITOR privileges on the warehouse to {{ domain }}_creator and higher
GRANT MONITOR ON WAREHOUSE {{ domain }}_wh TO ROLE {{ domain }}_creator;

-- Transfer ownership of warehouse and schema to the {{ domain }}_admin
GRANT OWNERSHIP ON SCHEMA {{ self_service_db }}.{{ domain }} to role {{ domain }}_admin copy current grants;
GRANT OWNERSHIP ON WAREHOUSE {{ domain }}_WH to role {{ domain }}_admin copy current grants;

