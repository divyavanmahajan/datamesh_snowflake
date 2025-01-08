# Data Mesh and Self Service within Snowflake

A data mesh requires the creation of isolated areas that independent teams can manage/develop in Snowflake. It uses concepts from the whitepaper, [Microsoft: Self serve data platforms](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/architectures/self-serve-data-platforms).

These documents walk you through the required SQL to create an isolated/sandbox area.

- [Create the sandbox with schema, warehouse, roles](docs/create_sandbox.md).
- [Producer sharing data](docs/share_producer.md).
- [Consumer using shared data](docs/share_consumer.md).

## Automation
- [YAML file to configure a new domain](docs/create_domain.md)
- [Python to create the sandbox](docs/python_generate.md).
- [Python to teardown the sandbox](docs/python_teardown.md).

### How to Run

1. **Install dependencies** (if you haven't already):
   ```bash
   pip install -r requirements.txt
   ```
2. **Ensure you have the following files in the same directory:**
   - `sql_template.sql` (the Jinja templates are stored in the templates directory)
   
2. **Ensure you have the following files in the workspace subdirectory:**
   - `workspaces/<domain>` (the domain subdirectory directory )
   - `parameters.yaml` (the YAML file with parameters, should be in the `workspaces/<domain>` directory )
   
3. **Run the bash script**:
   ```bash
   generate.sh <domain>
   ```
