-- Git commit: 52c4f50
-- Last generated on: 2024-12-26 21:32:56

-- Create a sandbox environment for a domain in the self_service_test database.
-- The script creates the following objects:
-- - Assigns roles to users
-- The script is idempotent and can be run multiple times without causing errors.

-- Assign roles to users


-- Admins

GRANT ROLE trial_ADMIN TO USER PRANAV_KINI;

GRANT ROLE trial_ADMIN TO USER DIVYA_MAHAJAN;

-- Creators

GRANT ROLE trial_creator TO USER MAREK_TRAVNICEK_SAC;

GRANT ROLE trial_creator TO USER VERONIKA_TABORSKA;

-- Viewers

GRANT ROLE trial_viewer TO USER MAREK_TRAVNICEK;

GRANT ROLE trial_viewer TO USER PRASHANTH_JADAV;
