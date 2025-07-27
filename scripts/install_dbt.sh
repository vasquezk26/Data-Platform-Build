#!/bin/bash
# Databricks cluster init script to install dbt-databricks

echo "Installing dbt-databricks on cluster..."

# Install dbt-databricks and dependencies
/databricks/python/bin/pip install dbt-databricks

# Verify installation
/databricks/python/bin/dbt --version

echo "dbt installation complete!"