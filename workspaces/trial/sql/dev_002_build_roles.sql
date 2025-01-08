-- Git commit: 52c4f50
-- Last generated on: 2024-12-26 21:32:56

-- Create a sandbox environment for a domain in the self_service_test database.
-- The script creates the following objects:
-- - Roles for the domain (admin, creator, viewer)
-- - Grants privileges to the roles
-- The script is idempotent and can be run multiple times without causing errors.

-- Create the roles if they do not exist
USE ROLE SECURITYADMIN;
CREATE ROLE IF NOT EXISTS trial_admin
  COMMENT = 'Admin role for domain trial';
CREATE ROLE IF NOT EXISTS trial_creator
  COMMENT = 'Creator role for domain trial';
CREATE ROLE IF NOT EXISTS trial_viewer
  COMMENT = 'Viewer read only role for domain trial';
USE ROLE SYSADMIN;
USE self_service_test;

USE SECONDARY ROLE SECURITYADMIN;
ALTER ROLE trial_admin SET TAG project = 'SELFSERVICE', domain = 'trial', costcenter = 'cs0001';
ALTER ROLE trial_creator SET TAG project = 'SELFSERVICE', domain = 'trial', costcenter = 'cs0001';
ALTER ROLE trial_viewer SET TAG project = 'SELFSERVICE', domain = 'trial', costcenter = 'cs0001';

-- Create a role hierarchy viewer>creator>admin>sysadmin
GRANT ROLE trial_admin TO ROLE sysadmin;
GRANT ROLE trial_creator TO ROLE trial_admin;
GRANT ROLE trial_viewer TO ROLE trial_creator;

-- Grant privileges from the lowest level up. Higher roles inherit from the hierarchy.
-- Grant privileges to trial_viewer and higher
GRANT USAGE ON WAREHOUSE trial_wh TO ROLE trial_viewer;
GRANT USAGE ON DATABASE self_service_test TO ROLE trial_viewer;
GRANT USAGE ON SCHEMA self_service_test.trial TO ROLE trial_viewer;

-- Grant read-only access to trial_viewer and higher
GRANT SELECT ON FUTURE TABLES IN SCHEMA self_service_test.trial TO ROLE trial_viewer;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA self_service_test.trial TO ROLE trial_viewer;

-- Grant trial_creator the ability to create objects in the schema
GRANT CREATE TABLE ON SCHEMA self_service_test.trial TO ROLE trial_creator;
GRANT CREATE VIEW ON SCHEMA self_service_test.trial TO ROLE trial_creator;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA self_service_test.trial TO ROLE trial_creator;
GRANT CREATE STREAM ON SCHEMA self_service_test.trial TO ROLE trial_creator;
GRANT CREATE FUNCTION ON SCHEMA self_service_test.trial TO ROLE trial_creator;
GRANT CREATE STREAMLIT ON SCHEMA self_service_test.trial TO ROLE trial_creator;

-- Grant trial_creator privileges on future objects (including views)
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA self_service_test.trial TO ROLE trial_creator;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA self_service_test.trial TO ROLE trial_creator;

-- Grant MONITOR privileges on the warehouse to trial_creator and higher
GRANT MONITOR ON WAREHOUSE trial_wh TO ROLE trial_creator;

-- Transfer ownership of warehouse and schema to the trial_admin
GRANT OWNERSHIP ON SCHEMA self_service_test.trial to role trial_admin copy current grants;
GRANT OWNERSHIP ON WAREHOUSE trial_WH to role trial_admin copy current grants;
