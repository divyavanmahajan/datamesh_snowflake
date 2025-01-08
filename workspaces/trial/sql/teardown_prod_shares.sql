-- Git commit: 52c4f50
-- Last generated on: 2024-12-26 21:32:57

-- Drop the sandbox environment for the domain in the self_service_test database.
-- The script drops the following objects:
-- - The shares created for the domain
-- The script is idempotent and can be run multiple times without causing errors.

-- The script is intentionally commented out to avoid accidental deletion.
-- so it must be uncommented before running it.

USE ROLE ACCOUNTADMIN;


-- Sharing edw for the domain trial
DROP SHARE IF EXISTS EDWARDS.trial_edw_sh;

-- Sharing edw_hvr for the domain trial
DROP SHARE IF EXISTS EDWARDS.trial_edw_hvr_sh;
