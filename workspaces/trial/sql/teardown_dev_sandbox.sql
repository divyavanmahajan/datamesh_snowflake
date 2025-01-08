-- Git commit: 52c4f50
-- Last generated on: 2024-12-26 21:32:57

-- Drop the sandbox environment for the domain in the self_service_test database.
-- The script drops the following objects:
-- - The schema for the domain
-- - The warehouse for the domain
-- - The roles for the domain (admin, creator, viewer)
-- - The budget for the domain
-- - Revokes privileges from the roles
-- - Revokes roles from users
-- The script is idempotent and can be run multiple times without causing errors.

-- The script is intentionally commented out to avoid accidental deletion.
-- so it must be uncommented before running it.

USE ROLE ACCOUNTADMIN;


-- Drop the roles if they exist
DROP ROLE IF EXISTS trial_admin;
DROP ROLE IF EXISTS trial_creator;
DROP ROLE IF EXISTS trial_viewer;

-- Drop the warehouse if it exists
DROP WAREHOUSE IF EXISTS trial_wh;
DROP COMPUTE POOL IF EXISTS trial_cpu;
-- Drop the schema if it exists
DROP SCHEMA IF EXISTS self_service_test.trial;

-- Drop the database if it exists
DROP DATABASE IF EXISTS self_service_test;
-- Drop database shares if they exist

DROP DATABASE IF EXISTS trial_edw;

DROP DATABASE IF EXISTS trial_edw_hvr;
