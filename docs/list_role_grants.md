# Role hierarchy - Retrieve the roles and grants

## Retrieve the list of roles in the role hierarchy.

```sql
use role accountadmin;

with cte as (
  select * 
  from snowflake.account_usage.grants_to_roles
  where grantee_name ilike '<role_name>' -- replace <role_name> with the primary role name of the role hierarchy
    and granted_on = 'ROLE'
    and privilege = 'USAGE'
    and deleted_on is null
  UNION ALL 
  select g.*
  from snowflake.account_usage.grants_to_roles g 
  join cte on g.grantee_name = cte.name
  where g.granted_on = 'ROLE'
  and g.privilege = 'USAGE'
  and g.deleted_on is null
)
select * from cte;
```

## Retrieve the list of grants to all the roles in the role hierarchy.
```sql
with cte as (
  select * 
  from snowflake.account_usage.grants_to_roles
  where grantee_name ilike '<role_name>' -- replace <role_name> with the primary role name of the role hierarchy
    and granted_on = 'ROLE'
    and privilege = 'USAGE'
    and deleted_on is null
  UNION ALL 
  select g.*
  from snowflake.account_usage.grants_to_roles g 
  join cte on g.grantee_name = cte.name
  where g.granted_on = 'ROLE'
  and g.privilege = 'USAGE'
  and g.deleted_on is null
)
select * from cte
union 
select gr.* from cte c, snowflake.account_usage.grants_to_roles gr
where gr.grantee_name = c.name
and gr.deleted_on is null
;
```

## Additional Information
Note: Latency for the `snowflake.account_usage.grants_to_roles` view may be up to **120 minutes (2 hours)**.
For details on snowflake.account_usage.grants_to_roles view, refer to the [documentation](https://docs.snowflake.com/en/sql-reference/account-usage/grants_to_roles).

## Source
https://community.snowflake.com/s/article/How-to-retrieve-the-list-of-roles-and-its-grants-in-the-role-hierarchy
