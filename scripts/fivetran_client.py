import os
import requests
from requests.auth import HTTPBasicAuth

FIVETRAN_API_KEY = os.getenv("FIVETRAN_API_KEY")
FIVETRAN_API_SECRET = os.getenv("FIVETRAN_API_SECRET")


class FivetranClient():
    def __init__(self, api_key=None, api_secret=None):
        self.api_key = api_key or FIVETRAN_API_KEY
        self.api_secret = api_secret or FIVETRAN_API_SECRET
        self.base_url = "https://api.fivetran.com/v1"
        self.schemas = {}

    def _get_api_response(self, url):
        response = requests.get(url, auth=HTTPBasicAuth(self.api_key, self.api_secret))

        if response.status_code != 200:
            raise Exception(f"Error: {response.status_code}, {response.text}")

        return response.json()

    def get_items(self, endpoint):
        """
        Fetches all items from a given Fivetran API endpoint.
        """
        url = f"{self.base_url}/{endpoint}"
        response = self._get_api_response(url)
        items = response.get("data", {}).get("items", [])
        return items

    def _get_schemas_in_connection(self, connection_id):
        url = f"{self.base_url}/connections/{connection_id}/schemas"
        response = self._get_api_response(url)
        return response

    def get_cloud_sql_connections(self, environment='development', catalog='fh_bronze'):
        # Find dev cloudsql destination
        groups = self.get_items("groups")
        dev_bronze_group_id = [group["id"] for group in groups if group["name"] == f"{environment}_databricks_{catalog}"][0]

        # Find dev cloudsql connectors
        connections = self.get_items("connections")
        dev_bronze_connnectors = [conn for conn in connections if conn["group_id"] == dev_bronze_group_id and conn["service"] == "google_cloud_postgresql"]
        return dev_bronze_connnectors
    
    def get_dev_bronze_connection_ids(self):
        dev_bronze_connnections = self.get_cloud_sql_connections(environment='development', catalog='fh_bronze')
        connection_ids = [conn["id"] for conn in dev_bronze_connnections]
        return connection_ids
    
    def get_connection_id_for_schema(self, destination_schema):
        dev_bronze_connection_ids = self.get_dev_bronze_connection_ids()
        for conn_id in dev_bronze_connection_ids:
            schema_names = self.get_schema_names(conn_id)
            if destination_schema in schema_names:
                return conn_id
        return None

    def get_schemas(self, connection_id):
        schema_response = self._get_schemas_in_connection(connection_id)
        schemas_dict = schema_response.get("data", {}).get("schemas", {})
        self.schemas[connection_id] = schemas_dict
        return schemas_dict
    
    def get_schema_names(self, connection_id):
        schemas_dict = self.schemas.get(connection_id) or self.get_schemas(connection_id)
        destination_schema_names = [schema_details["name_in_destination"] for source_schema, schema_details in schemas_dict.items()]
        return destination_schema_names

    def get_tables(self, connection_id, destination_schema):
        schemas_dict = self.schemas.get(connection_id) or self.get_schemas(connection_id)
        for source_schema, schema_details in schemas_dict.items():
            if schema_details.get("name_in_destination") == destination_schema:
                return schema_details.get("tables")
        return {}
    
    def get_table_names(self, connection_id, destination_schema):
        tables_dict = self.get_tables(connection_id, destination_schema)
        table_names = [table_details["name_in_destination"] for source_table, table_details in tables_dict.items()]
        return table_names

    def get_table_sync_modes(self, connection_id, destination_schema):
        tables_dict = self.get_tables(connection_id, destination_schema)
        table_sync_modes = {table_details["name_in_destination"]: table_details["sync_mode"] for source_table, table_details in tables_dict.items()}
        return table_sync_modes
    
    def get_columns(self, connection_id, destination_schema, table_name):
        tables_dict = self.get_tables(connection_id, destination_schema)
        table_dict = tables_dict.get(table_name)
        columns_dict = table_dict.get("columns")
        return columns_dict
    
    def get_column_names(self, connection_id, destination_schema, table_name):
        columns_dict = self.get_columns(connection_id, destination_schema, table_name)
        column_names = [column_details["name_in_destination"] for source_column, column_details in columns_dict.items()]
        return column_names
