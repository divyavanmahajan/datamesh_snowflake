-- Git commit: 52c4f50
-- Last generated on: 2024-12-26 21:32:57

-- Create the artifacts in the production environment for a domain in the self_service_test database.
-- The script creates the following objects:
-- - Share(s) for the domain
-- - Assign databases, schemas and tables/views to the share
-- The script is idempotent and can be run multiple times without causing errors.



-- Sharing edw for the domain trial
create share trial_edw_sh comment = 'Share edw for trial SELF-SERVICE';
grant usage on database edw to share trial_edw_sh;
use database edw;

grant usage on schema hangar to share trial_edw_sh;

grant select on TABLE hangar.C_JDE_ADDRESS_BOOK to share trial_edw_sh;

grant usage on schema takeoff to share trial_edw_sh;

grant select on TABLE takeoff.DIM_FIN_CUSTOMER to share trial_edw_sh;

grant select on VIEW takeoff.V_FIN_BALANCE to share trial_edw_sh;

grant select on MATERIALIZED VIEW takeoff.VW_FIN_BALANCE to share trial_edw_sh;

-- Sharing edw_hvr for the domain trial
create share trial_edw_hvr_sh comment = 'Share edw_hvr for trial SELF-SERVICE';
grant usage on database edw_hvr to share trial_edw_hvr_sh;
use database edw_hvr;

grant usage on schema landing to share trial_edw_hvr_sh;

grant select on TABLE landing.F0001 to share trial_edw_hvr_sh;

alter share trial__sh add accounts = RZA44357 SHARE_RESTRICTIONS=false;