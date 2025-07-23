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
import json

from fivetran_client import FivetranClient


fivetran_client = FivetranClient()


def set_to_history_mode(databases=[]):
    dev_bronze_connection_ids = fivetran_client.get_dev_bronze_connection_ids()
    
    # Create schema config for each connector
    for conn_id in dev_bronze_connection_ids:
        bronze_schema = {}
        schema_names = fivetran_client.get_schema_names(conn_id)
        database = schema_names[0].replace("dev_", "").rsplit("_", 1)[0] # e.g. database = "mso"
        if database in databases:
            for schema_name in schema_names:  # e.g. schema_name = "dev_mso_public"
                source_schema_name = schema_name.rsplit("_", 1)[1] # e.g. source_schema_name = 'public'
                bronze_schema[source_schema_name] = {"enabled": True}
                bronze_schema[source_schema_name]["tables"] = {}
                table_names = fivetran_client.get_table_names(conn_id, schema_name)
                for table_name in table_names:
                    bronze_schema[source_schema_name]["tables"][table_name] = {"enabled": True, "sync_mode": "HISTORY"}
        
            with open(f"../fivetran/bronze_schemas/{database}.json", "w") as f:
                json.dump(bronze_schema, f, indent=2)


if __name__ == "__main__":
    databases = ["mso", "admin_backend"]
    set_to_history_mode(databases=databases)
