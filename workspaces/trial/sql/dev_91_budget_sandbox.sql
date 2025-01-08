-- Git commit: 52c4f50
-- Last generated on: 2024-12-26 21:32:57

-- Create cost management for a domain in the self_service_test database.
-- The script creates the following objects:

-- The script is idempotent and can be run multiple times without causing errors.

USE ROLE ACCOUNTADMIN;

CREATE NOTIFICATION INTEGRATION IF NOT EXISTS trial_budgets_notification_integration
  TYPE=EMAIL
  ENABLED=TRUE
  ALLOWED_RECIPIENTS=('<YOUR_EMAIL_ADDRESS>');
