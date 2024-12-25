# Data Mesh and Self Service within Snowflake

A data mesh requires the creation of isolated areas that independent teams can manage/develop in Snowflake. It uses concepts from the whitepaper, [Microsoft: Self serve data platforms](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/architectures/self-serve-data-platforms).

These documents walk you through the required SQL to create an isolated/sandbox area.

- [Create the sandbox with schema, warehouse, roles](./create_sandbox.md).
- [Producer sharing data](./share_producer.md).
- [Consumer using shared data](./share_consumer.md).

- [Python to create the sandbox](./python_generate.md).
- [Python to teardown the sandbox](./python_teardown.md).
