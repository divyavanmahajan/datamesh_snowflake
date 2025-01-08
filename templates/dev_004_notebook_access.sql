-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Create a sandbox environment for a domain in the {{ self_service_db }} database.
-- The script creates the following objects:
-- - CPU pool for notebooks
-- - Network integration for PyPi, Huggingface
-- - Grants privileges to the roles
-- The script is idempotent and can be run multiple times without causing errors.
-- Based on Snowflake documentation at: https://docs.snowflake.com/en/user-guide/ui-snowsight/notebooks-setup
USE ROLE ACCOUNTADMIN;
CREATE COMPUTE POOL IF NOT EXISTS {{ domain }}_cpu
  MIN_NODES = {{ CPU_POOL.MIN_NODES }}
  MAX_NODES = {{ CPU_POOL.MAX_NODES }}
  INSTANCE_FAMILY = {{ CPU_POOL.INSTANCE_FAMILY }}
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  AUTO_SUSPEND_SECS = {{ CPU_POOL.AUTO_SUSPEND_SECS }}
  COMMENT = 'CPU Pool for notebooks for domain {{ domain }}' 
  ;
ALTER COMPUTE POOL {{ domain }}_cpu SET TAG project = 'SELFSERVICE', domain = '{{ domain }}', costcenter = '{{ costcenter }}';
GRANT OWNERSHIP ON COMPUTE POOL {{ domain }}_cpu TO ROLE {{ domain }}_admin copy current grants;
GRANT MONITOR ON COMPUTE POOL  {{ domain }}_cpu TO ROLE {{ domain }}_creator;
GRANT USAGE ON COMPUTE POOL  {{ domain }}_cpu TO ROLE {{ domain }}_viewer;

-- Grant notebook creation access to {{ domain }}_viewer and higher
GRANT CREATE NOTEBOOK ON SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_viewer;
GRANT CREATE SERVICE ON SCHEMA {{ self_service_db }}.{{ domain }} TO ROLE {{ domain }}_viewer;

-- Network access for PyPi and Huggingface. These are global shared by everyone.
CREATE OR REPLACE NETWORK RULE pypi_network_rule
MODE = EGRESS
TYPE = HOST_PORT
VALUE_LIST = ('pypi.org', 'pypi.python.org', 'pythonhosted.org',  'files.pythonhosted.org');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION pypi_access_integration
ALLOWED_NETWORK_RULES = (pypi_network_rule)
ENABLED = true;

CREATE OR REPLACE NETWORK RULE hf_network_rule
MODE = EGRESS
TYPE = HOST_PORT
VALUE_LIST = ('huggingface.co', 'cdn-lfs.huggingface.co');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION hf_access_integration
ALLOWED_NETWORK_RULES = (hf_network_rule)
ENABLED = true;

-- Grant access to the viewer (i.e. the creator of the notebook, PUBLIC does not work)
-- See https://docs.snowflake.com/en/user-guide/ui-snowsight/notebooks-external-access
GRANT USAGE ON INTEGRATION pypi_access_integration TO ROLE {{ domain }}_viewer;
GRANT USAGE ON INTEGRATION hf_access_integration TO ROLE {{ domain }}_viewer;
