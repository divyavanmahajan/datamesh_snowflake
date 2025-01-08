-- Git commit: 52c4f50
-- Last generated on: 2024-12-26 21:32:56

-- Create a sandbox environment for a domain in the self_service_test database.
-- The script creates the following objects:
-- - A schema for the domain
-- - A warehouse for the domain
-- - Roles for the domain (admin, creator, viewer)
-- - Grants privileges to the roles
-- The script is idempotent and can be run multiple times without causing errors.

USE ROLE SYSADMIN;

-- Create the database, tags, schema, and warehouse if they do not exist
CREATE OR ALTER DATABASE self_service_test COMMENT = 'SELF-SERVICE DATABASE';
USE self_service_test;
CREATE TAG IF NOT EXISTS costcenter COMMENT = 'Cost center attribution';
CREATE TAG IF NOT EXISTS project COMMENT = 'Project cost attribution';
CREATE TAG IF NOT EXISTS domain COMMENT = 'Data mesh / self service domain cost attribution';

ALTER DATABASE self_service_test SET TAG project = 'SELFSERVICE';

CREATE OR ALTER SCHEMA self_service_test.trial
  COMMENT = 'Data mesh schema for domain trial';
ALTER SCHEMA self_service_test.trial SET TAG project = 'SELFSERVICE', domain = 'trial', costcenter = 'cs0001';

-- Warehouse parameters are managed in the parameters.yaml file
CREATE OR ALTER WAREHOUSE trial_wh
  WITH WAREHOUSE_SIZE = XSMALL           -- Adjust the size as needed
  WAREHOUSE_TYPE = STANDARD
  INITIALLY_SUSPENDED = True      -- Start suspended
  AUTO_SUSPEND = 300                    -- Suspend after 300 seconds of inactivity
  AUTO_RESUME = True
  MAX_CLUSTER_COUNT = 1
  MIN_CLUSTER_COUNT = 1
  COMMENT = 'Data mesh warehouse for domain trial';
ALTER WAREHOUSE trial_wh SET TAG project = 'SELFSERVICE', domain = 'trial', costcenter = 'cs0001';
