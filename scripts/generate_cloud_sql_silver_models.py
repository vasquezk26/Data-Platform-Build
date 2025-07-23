"""
Fivetran currently does not support automatically opt-in to sync in history mode.
We need to explicitly list out every table and set it history mode.
This script can be used to dynamically generate the list of tables and 
update terraform code automatically

The script gets the list of tables using already created fivetran connector in development
and updates the bronze_scemas.json file in fivetran folder

Usage:
1. First create the connector in main.tf without history mode in Dev. Dont set schemas variable.
2. Run this script locally
```
export FIVETRAN_API_KEY=
export FIVETRAN_API_SECRET=
cd $DP_INFRA_REPO_DIR/scripts && python set_fivetran_to_history_mode.py
```
3. Update connector in main.tf by setting schemas like this `schemas = local.bronze_schemas.mso`
4. Check-in the files under bronze_schemas and main.tf
"""
import csv
import os
import yaml

from fivetran_client import FivetranClient


class IndentDumper(yaml.SafeDumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(IndentDumper, self).increase_indent(flow, False)


fc = FivetranClient()

VIEW_SQL_TEMPLATE = """
SELECT
  {COLUMNS}
FROM
  {TABLE}
WHERE
  {WHERE_CLAUSE}
"""

def process_database(database='', bronze_catalog=''):    
    destination_schema = f'dev_{database}_public'   # TODO: handle mutiple schemas
    connection_id = fc.get_connection_id_for_schema(destination_schema=destination_schema)
    schema_names = fc.get_schema_names(connection_id)
    all_columns = []
    for schema_name in schema_names:
        table_names = fc.get_table_names(connection_id, schema_name)
        table_sync_modes = fc.get_table_sync_modes(connection_id, schema_name)

        source_schema_name = destination_schema.rsplit("_", 1)[1] # e.g. source_schema_name = 'public'
        models_dir = f"../dbt/models/cloud_sql/{database}/{source_schema_name}"
        os.makedirs(models_dir, exist_ok=True)

        sources_dict = {
            "version": 2, 
            "sources": [
                {
                    "name": database,
                    "database": bronze_catalog,
                    "schema": f"{{{{ env_var('_ENV') }}}}_{database}_public",
                    "tables": [{"name": t} for t in table_names]
                }
            ]
        }
        with open(f"{models_dir}/sources.yml", "w") as f:
            yaml.dump(sources_dict, f, sort_keys=False, default_flow_style=False, indent=2, Dumper=IndentDumper)

        for table_name in table_names:
            column_names = fc.get_column_names(connection_id, schema_name, table_name)
            for column_name in column_names:
                all_columns.append({
                    "Database": database,
                    "Schema": schema_name.replace(f"dev_{database}_", ""),
                    "Table": table_name,
                    "Column": column_name
                    })
            
            model_file_name = f"{database}_{table_name}" if table_name == 'alembic_version' else table_name
            with open(f"{models_dir}/{model_file_name}.sql", "w") as f:
                starter_select_column = "_fivetran_active" if table_sync_modes.get(table_name) == 'HISTORY' else '_fivetran_deleted'
                where_clause = "_fivetran_active = True" if table_sync_modes.get(table_name) == 'HISTORY' else '_fivetran_deleted = False'
                column_names = [starter_select_column] + column_names
                columns_expression = "\n  -- , ".join(column_names)
                sql = VIEW_SQL_TEMPLATE.format(
                    COLUMNS=columns_expression,
                    TABLE=f"{{{{ source('{database}', '{table_name}') }}}}",
                    WHERE_CLAUSE=where_clause
                )
                f.write(sql)
                
    bronze_columns_dir = "../fivetran/bronze_columns"
    os.makedirs(bronze_columns_dir, exist_ok=True)
    with open(f"{bronze_columns_dir}/{database}.csv", 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=all_columns[0].keys())
        writer.writeheader()
        writer.writerows(all_columns)


if __name__ == "__main__":
    bronze_catalog = 'fh_bronze'
    databases = ["mso", "admin_backend"]
    for database in databases:
        process_database(database=database, bronze_catalog=bronze_catalog)