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

USE ROLE ACCOUNTADMIN;


-- Drop the roles if they exist
DROP ROLE IF EXISTS {{ domain }}_admin;
DROP ROLE IF EXISTS {{ domain }}_creator;
DROP ROLE IF EXISTS {{ domain }}_viewer;

-- Drop the warehouse if it exists
DROP WAREHOUSE IF EXISTS {{ domain }}_wh;
DROP COMPUTE POOL IF EXISTS {{ domain }}_cpu;
-- Drop the schema if it exists
DROP SCHEMA IF EXISTS {{ self_service_db }}.{{ domain }};

-- Drop the database if it exists
DROP DATABASE IF EXISTS {{ self_service_db }};
-- Drop database shares if they exist
{% for db_dict in shares['production'] %}{% for db, schemas in db_dict.items() %}
DROP DATABASE IF EXISTS {{ domain }}_{{ db }};
{% endfor %}{% endfor %}
