-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Create cost management for a domain in the {{ self_service_db }} database.
-- The script creates the following objects:

-- The script is idempotent and can be run multiple times without causing errors.

USE ROLE ACCOUNTADMIN;

CREATE NOTIFICATION INTEGRATION IF NOT EXISTS {{domain}}_budgets_notification_integration
  TYPE=EMAIL
  ENABLED=TRUE
  ALLOWED_RECIPIENTS=('<YOUR_EMAIL_ADDRESS>');

