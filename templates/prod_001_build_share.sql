-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Create the artifacts in the production environment for a domain in the {{ self_service_db }} database.
-- The script creates the following objects:
-- - Share(s) for the domain
-- - Assign databases, schemas and tables/views to the share
-- The script is idempotent and can be run multiple times without causing errors.
{#
-- YAML structure should be the following and in the parameters.yaml file
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
create share {{ domain }}_{{ db }}_sh comment = 'Share {{ db }} for {{ domain }} SELF-SERVICE';
grant usage on database {{ db }} to share {{ domain }}_{{ db }}_sh;
use database {{ db }};
{% for schema_dict in schemas %}{% for schema, objectlist in schema_dict.items() %}
grant usage on schema {{ schema }} to share {{ domain }}_{{ db }}_sh;
{% for objectlist_dict in objectlist %}{% for objecttype, objects in objectlist_dict.items() %}{% for object in objects %}
grant select on {{ objecttype }} {{ schema }}.{{ object }} to share {{ domain }}_{{ db }}_sh;
{% endfor %}{% endfor %}{% endfor %}{% endfor %}{% endfor %}{% endfor %}{% endfor %}
alter share {{ domain }}_{{ db }}_sh add accounts = {{ accounts.sandbox }} SHARE_RESTRICTIONS=false;