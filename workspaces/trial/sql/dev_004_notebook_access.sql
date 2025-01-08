-- Git commit: 52c4f50
-- Last generated on: 2024-12-26 21:32:57

-- Create a sandbox environment for a domain in the self_service_test database.
-- The script creates the following objects:
-- - CPU pool for notebooks
-- - Network integration for PyPi, Huggingface
-- - Grants privileges to the roles
-- The script is idempotent and can be run multiple times without causing errors.
-- Based on Snowflake documentation at: https://docs.snowflake.com/en/user-guide/ui-snowsight/notebooks-setup
USE ROLE ACCOUNTADMIN;
CREATE COMPUTE POOL IF NOT EXISTS trial_cpu
  MIN_NODES = 1
  MAX_NODES = 5
  INSTANCE_FAMILY = CPU_X64_XS
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  AUTO_SUSPEND_SECS = 300
  COMMENT = 'CPU Pool for notebooks for domain trial' 
  ;
ALTER COMPUTE POOL trial_cpu SET TAG project = 'SELFSERVICE', domain = 'trial', costcenter = 'cs0001';
GRANT OWNERSHIP ON COMPUTE POOL trial_cpu TO ROLE trial_admin copy current grants;
GRANT MONITOR ON COMPUTE POOL  trial_cpu TO ROLE trial_creator;
GRANT USAGE ON COMPUTE POOL  trial_cpu TO ROLE trial_viewer;

-- Grant notebook creation access to trial_viewer and higher
GRANT CREATE NOTEBOOK ON SCHEMA self_service_test.trial TO ROLE trial_viewer;
GRANT CREATE SERVICE ON SCHEMA self_service_test.trial TO ROLE trial_viewer;

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
GRANT USAGE ON INTEGRATION pypi_access_integration TO ROLE trial_viewer;
GRANT USAGE ON INTEGRATION hf_access_integration TO ROLE trial_viewer;