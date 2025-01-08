-- Git commit: 52c4f50
-- Last generated on: 2024-12-26 21:32:57

-- Mounts shares from production as databases for the domain trial
-- The script creates the following objects:
-- - Database(s) for each shared database.
-- - Assign databases, schemas and tables/views to the share
-- The script is idempotent and can be run multiple times without causing errors.



-- Sharing edw for the domain trial
CREATE OR REPLACE DATABASE trial_edw FROM SHARE EDWARDS.trial_edw_sh COMMENT = 'Read-only share for production database edw from account EDWARDS';
grant imported privileges on database trial_edw to role trial_viewer;
--alter database trial_edw enable imported privileges;
--grant ownership on DATABASE trial_edw to role trial_admin copy current grants;

-- Sharing edw_hvr for the domain trial
CREATE OR REPLACE DATABASE trial_edw_hvr FROM SHARE EDWARDS.trial_edw_hvr_sh COMMENT = 'Read-only share for production database edw_hvr from account EDWARDS';
grant imported privileges on database trial_edw_hvr to role trial_viewer;
--alter database trial_edw_hvr enable imported privileges;
--grant ownership on DATABASE trial_edw_hvr to role trial_admin copy current grants;



-- Sharing  for the domain trial

CREATE DATABASE IF NOT EXISTS edw_servicenow FROM SHARE EDWARDS.edw_servicenow_sh;
grant imported privileges on database edw_servicenow to role trial_viewer;
--alter database edw_servicenow enable imported privileges;

-- Sharing  for the domain trial

CREATE DATABASE IF NOT EXISTS edw_fivetran FROM SHARE EDWARDS.edw_fivetran_sh;
grant imported privileges on database edw_fivetran to role trial_viewer;
--alter database edw_fivetran enable imported privileges;
