# Workspace configuration Guide

Steps to create a new domain '**domain_name**'.

1. Create a subdirectory `workspaces/domain_name`.
2. Create the file `workspaces/domain_name/parameters.yaml`. See below for details.
3. If you haven't already done so, install the Python requirements. ```pip install -r requirements.txt```.
4. Generate the SQL, ```./generate.sh domain_name```.
5. Run the SQL scripts in the workspaces/domain_name/sql folder.

This guide below provides instructions on how to create the domain YAML configuration file.
Each section and field is described in detail to help you understand and customize the configuration according to your needs.

## Domain parameters.yaml configuration


```yaml
accounts: 
  sandbox: RZA44357
  production: EDWARDS
self_service_db: "self_service_test"
domain: "cs_emeacla"
costcenter: "cs0001"
WAREHOUSE:
  WAREHOUSE_SIZE: XSMALL
  WAREHOUSE_TYPE: STANDARD
  INITIALLY_SUSPENDED: TRUE
  AUTO_SUSPEND: 300
  AUTO_RESUME: TRUE
  MAX_CLUSTER_COUNT: 3
  MIN_CLUSTER_COUNT: 1

CPU_POOL:
  MIN_NODES: 1
  MAX_NODES: 5
  INSTANCE_FAMILY: CPU_X64_XS
  AUTO_SUSPEND_SECS: 300

admin_users:
  - DIVYA_MAHAJAN
  - VERONIKA_TABORSKA
creator_users:
  - MAREK_TRAVNICEK_SAC
  - PRASHANTH_JADAV
viewer_users:
  - PRANAV_KINI
  - MAREK_TRAVNICEK

shares:
  production:
    - edw:
        - hangar:
            - TABLE:
                - C_JDE_ADDRESS_BOOK
        - takeoff:
            - TABLE:
                - DIM_FIN_CUSTOMER
            - VIEW:
                - V_FIN_BALANCE
            - 'MATERIALIZED VIEW':
                - VW_FIN_BALANCE
    - edw_hvr:
        - landing:
            - TABLE:
              - F0001
```

## Field Descriptions

### Account Information
- **sandbox**: The account identifier for the Snowflake workspace/sandbox account.
- **production**: The account identifier for the Snowflake production/central account.

### Domain Information
- **self_service_db**: The name of the self-service database.
- **domain**: The domain name associated with the configuration.
- **costcenter**: The cost center identifier.

### Warehouse Configuration
- **WAREHOUSE_SIZE**: The size of the warehouse (e.g., XSMALL, SMALL, MEDIUM).
- **WAREHOUSE_TYPE**: The type of the warehouse (e.g., STANDARD, ENTERPRISE).
- **INITIALLY_SUSPENDED**: Indicates whether the warehouse should start in a suspended state (TRUE or FALSE).
- **AUTO_SUSPEND**: The number of seconds of inactivity after which the warehouse will be automatically suspended.
- **AUTO_RESUME**: Indicates whether the warehouse should automatically resume when a query is executed (TRUE or FALSE).
- **MAX_CLUSTER_COUNT**: The maximum number of clusters for the warehouse.
- **MIN_CLUSTER_COUNT**: The minimum number of clusters for the warehouse.

### CPU Pool Configuration
- **MIN_NODES**: The minimum number of nodes in the CPU pool.
- **MAX_NODES**: The maximum number of nodes in the CPU pool.
- **INSTANCE_FAMILY**: The instance family for the CPU pool (e.g., CPU_X64_XS).
- **AUTO_SUSPEND_SECS**: The number of seconds of inactivity after which the CPU pool will be automatically suspended.

### User Roles
- **admin_users**: A list of users with administrative privileges.
- **creator_users**: A list of users with creator privileges.
- **viewer_users**: A list of users with viewer privileges.

### Shares Configuration
- **production**: The production environment configuration.
  - **edw**: The EDW database configuration.
    - **hangar**: The hangar schema configuration.
      - **TABLE**: A list of tables in the hangar schema.
    - **takeoff**: The takeoff schema configuration.
      - **TABLE**: A list of tables in the takeoff schema.
      - **VIEW**: A list of views in the takeoff schema.
      - **MATERIALIZED VIEW**: A list of materialized views in the takeoff schema.
  - **edw_hvr**: The EDW_HVR database configuration.
    - **landing**: The landing schema configuration.
      - **TABLE**: A list of tables in the landing schema.

