-- Git commit: {{ git_commit_hash }}
-- Last generated on: {{ now }}

-- Create a sandbox environment for a domain in the {{ self_service_db }} database.
-- The script creates the following objects:
-- - Assigns roles to users
-- The script is idempotent and can be run multiple times without causing errors.

-- Assign roles to users


-- Admins
{% for admin_user in admin_users %}
GRANT ROLE {{ domain }}_ADMIN TO USER {{ admin_user }};
{% endfor %}
-- Creators
{% for creator_user in creator_users %}
GRANT ROLE {{ domain }}_creator TO USER {{ creator_user }};
{% endfor %}
-- Viewers
{% for viewer_user in viewer_users %}
GRANT ROLE {{ domain }}_viewer TO USER {{ viewer_user }};
{% endfor %}
