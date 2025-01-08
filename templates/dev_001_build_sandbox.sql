-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Create a sandbox environment for a domain in the {{ self_service_db }} database.
-- The script creates the following objects:
-- - A schema for the domain
-- - A warehouse for the domain
-- - Roles for the domain (admin, creator, viewer)
-- - Grants privileges to the roles
-- The script is idempotent and can be run multiple times without causing errors.

USE ROLE SYSADMIN;

-- Create the database, tags, schema, and warehouse if they do not exist
CREATE OR ALTER DATABASE {{ self_service_db }} COMMENT = 'SELF-SERVICE DATABASE';
USE {{ self_service_db }};
CREATE TAG IF NOT EXISTS costcenter COMMENT = 'Cost center attribution';
CREATE TAG IF NOT EXISTS project COMMENT = 'Project cost attribution';
CREATE TAG IF NOT EXISTS domain COMMENT = 'Data mesh / self service domain cost attribution';

ALTER DATABASE {{ self_service_db }} SET TAG project = 'SELFSERVICE';

CREATE OR ALTER SCHEMA {{ self_service_db }}.{{ domain }}
  COMMENT = 'Data mesh schema for domain {{ domain }}';
ALTER SCHEMA {{ self_service_db }}.{{ domain }} SET TAG project = 'SELFSERVICE', domain = '{{ domain }}', costcenter = '{{ costcenter }}';

-- Warehouse parameters are managed in the parameters.yaml file
CREATE OR ALTER WAREHOUSE {{ domain }}_wh
  WITH WAREHOUSE_SIZE = {{ WAREHOUSE.WAREHOUSE_SIZE }}           -- Adjust the size as needed
  WAREHOUSE_TYPE = {{ WAREHOUSE.WAREHOUSE_TYPE }}
  INITIALLY_SUSPENDED = {{ WAREHOUSE.INITIALLY_SUSPENDED }}      -- Start suspended
  AUTO_SUSPEND = {{ WAREHOUSE.AUTO_SUSPEND }}                    -- Suspend after {{ WAREHOUSE.AUTO_SUSPEND }} seconds of inactivity
  AUTO_RESUME = {{ WAREHOUSE.AUTO_RESUME }}
  MAX_CLUSTER_COUNT = {{ WAREHOUSE.MAX_CLUSTER_COUNT }}
  MIN_CLUSTER_COUNT = {{ WAREHOUSE.MIN_CLUSTER_COUNT }}
  COMMENT = 'Data mesh warehouse for domain {{ domain }}';
ALTER WAREHOUSE {{ domain }}_wh SET TAG project = 'SELFSERVICE', domain = '{{ domain }}', costcenter = '{{ costcenter }}';

