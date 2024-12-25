-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Drop the sandbox environment for the domain in the {{ self_service_db }} database.
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


-- -- Drop the roles if they exist
-- DROP ROLE IF EXISTS {{ domain }}_admin;
-- DROP ROLE IF EXISTS {{ domain }}_creator;
-- DROP ROLE IF EXISTS {{ domain }}_viewer;

-- -- Drop the budget for the {{ self_service_db }} domain (data mesh)
-- DROP BUDGET IF EXISTS {{ self_service_db }}_{{ domain }}_budget;

-- -- Drop the warehouse if it exists
-- DROP WAREHOUSE IF EXISTS {{ domain }}_wh;

-- -- Drop the schema if it exists
-- DROP SCHEMA IF EXISTS {{ self_service_db }}.{{ domain }}_sh;

-- -- Optionally, revoke roles from users (optional, depends on use case)
-- BEGIN
--     -- Revoke roles from users if granted
--     {% for admin_user in admin_users %}
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_admin' AND GRANTEE_NAME = '{{ admin_user }}') THEN
--         REVOKE ROLE {{ domain }}_admin FROM USER {{ admin_user }};
--     END IF;
--     {% endfor %}
--     {% for creator_user in creator_users %}
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_creator' AND GRANTEE_NAME = '{{ creator_user }}') THEN
--         REVOKE ROLE {{ domain }}_creator FROM USER {{ creator_user }};
--     END IF;
--     {% endfor %}
--     {% for viewer_user in viewer_users %}
    
--     IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROLE_GRANTS WHERE ROLE_NAME = '{{ domain }}_viewer' AND GRANTEE_NAME = '{{ viewer_user }}') THEN
--         REVOKE ROLE {{ domain }}_viewer FROM USER {{ viewer_user }};
--     END IF;
--     {% endfor %}
    
-- END;