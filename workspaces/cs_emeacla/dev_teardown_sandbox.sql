-- Git commit: a981586
-- Last generated on: 2024-12-25 21:48:26

-- Drop the sandbox environment for the domain in the self_service database.
-- The script drops the following objects:
-- - The schema for the domain
-- - The warehouse for the domain
-- - The roles for the domain (admin, creator, viewer)
-- - The budget for the domain
-- - Revokes privileges from the roles
-- - Revokes roles from users
-- The script is idempotent and can be run multiple times without causing errors.

-- The script is commented out - so it must be uncommented before running it.


-- -- Drop the roles if they exist
-- DROP ROLE IF EXISTS cs_emeacla_admin;
-- DROP ROLE IF EXISTS cs_emeacla_creator;
-- DROP ROLE IF EXISTS cs_emeacla_viewer;

-- -- Drop the budget for the self_service domain (data mesh)
-- DROP BUDGET IF EXISTS self_service_cs_emeacla_budget;

-- -- Drop the warehouse if it exists
-- DROP WAREHOUSE IF EXISTS cs_emeacla_wh;

-- -- Drop the schema if it exists
-- DROP SCHEMA IF EXISTS self_service.cs_emeacla_sh;

-- -- Optionally, revoke roles from users (optional, depends on use case)
-- BEGIN
--     -- Revoke roles from users if granted
--     
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_admin' AND GRANTEE_NAME = 'divyavanmahajan') THEN
--         REVOKE ROLE cs_emeacla_admin FROM USER divyavanmahajan;
--     END IF;
--     
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_admin' AND GRANTEE_NAME = 'admin2') THEN
--         REVOKE ROLE cs_emeacla_admin FROM USER admin2;
--     END IF;
--     
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_admin' AND GRANTEE_NAME = 'admin3') THEN
--         REVOKE ROLE cs_emeacla_admin FROM USER admin3;
--     END IF;
--     
--     
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_creator' AND GRANTEE_NAME = 'divyavanmahajan') THEN
--         REVOKE ROLE cs_emeacla_creator FROM USER divyavanmahajan;
--     END IF;
--     
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_creator' AND GRANTEE_NAME = 'creator456') THEN
--         REVOKE ROLE cs_emeacla_creator FROM USER creator456;
--     END IF;
--     
--     
    
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_viewer' AND GRANTEE_NAME = 'divyavanmahajan') THEN
--         REVOKE ROLE cs_emeacla_viewer FROM USER divyavanmahajan;
--     END IF;
--     
    
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = 'cs_emeacla_viewer' AND GRANTEE_NAME = 'viewer789') THEN
--         REVOKE ROLE cs_emeacla_viewer FROM USER viewer789;
--     END IF;
--     
    
-- END;