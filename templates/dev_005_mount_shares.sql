-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Mounts shares from production as databases for the domain {{ domain }}
-- The script creates the following objects:
-- - Database(s) for each shared database.
-- - Assign databases, schemas and tables/views to the share
-- The script is idempotent and can be run multiple times without causing errors.
{#
-- YAML structure should be the following and in the parameters.yaml file
-- accounts:
--   production: RZ44044
--   sandbox: RZ44424
-- shares:
--   production:
--     - edw:
--         - hangar:
--             - TABLE:
--                 - C_JDE_ADDRESS_BOOK
--         - takeoff:
--             - TABLE:
--                 - DIM_FIN_CUSTOMER
--             - VIEW:
--                 - V_FIN_BALANCE
--             - 'MATERIALIZED VIEW':
--                 - VW_FIN_BALANCE
--     - edw_hvr:
--         - landing:
--             - TABLE:
--               - F0001
#}

{% for db_dict in shares['production'] %}{% for db, schemas in db_dict.items() %}
-- Sharing {{ db }} for the domain {{ domain }}
CREATE OR REPLACE DATABASE {{ domain }}_{{ db }} FROM SHARE {{accounts.production}}.{{ domain }}_{{ db }}_sh COMMENT = 'Read-only share for production database {{ db }} from account {{ accounts.production}}';
grant imported privileges on database {{ domain }}_{{ db }} to role {{ domain }}_viewer;
--alter database {{ domain }}_{{ db }} enable imported privileges;
--grant ownership on DATABASE {{ domain }}_{{ db }} to role {{ domain }}_admin copy current grants;
{% endfor %}{% endfor %}

{% for sharename in mountshares['production'] %}
-- Sharing {{ db }} for the domain {{ domain }}
{% set mountname = sharename.replace('_sh', '') if '_sh' in sharename else sharename %}
CREATE DATABASE IF NOT EXISTS {{ mountname }} FROM SHARE {{accounts.production}}.{{ sharename }};
grant imported privileges on database {{ mountname }} to role {{ domain }}_viewer;
--alter database {{ mountname }} enable imported privileges;
{% endfor %}
