-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Drop the sandbox environment for the domain in the {{ self_service_db }} database.
-- The script drops the following objects:
-- - The shares created for the domain
-- The script is idempotent and can be run multiple times without causing errors.

-- The script is intentionally commented out to avoid accidental deletion.
-- so it must be uncommented before running it.

USE ROLE ACCOUNTADMIN;

{% for db_dict in shares['production'] %}{% for db, schemas in db_dict.items() %}
-- Sharing {{ db }} for the domain {{ domain }}
DROP SHARE IF EXISTS {{accounts.production}}.{{ domain }}_{{ db }}_sh;
{% endfor %}{% endfor %}
