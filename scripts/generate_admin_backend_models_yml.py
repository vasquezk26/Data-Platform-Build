#!/usr/bin/env python3
"""
Generate models.yml file for admin_backend/public from CSV schema definition.

This script reads the admin_backend.csv file containing column definitions
and generates a dbt models.yml file with model and column documentation,
including meta sections with class and sensitivity fields.

Usage:
    python generate_admin_backend_models_yml.py
"""

import csv
import os
import yaml
from collections import defaultdict
from typing import Dict, List


def read_csv_schema(csv_path: str) -> Dict[str, List[Dict]]:
    """
    Read CSV file and group columns by table name with metadata.
    
    Args:
        csv_path: Path to the CSV file
        
    Returns:
        Dictionary mapping table names to lists of column dictionaries with metadata
    """
    table_columns = defaultdict(list)
    
    with open(csv_path, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            database = row['Database']
            schema = row['Schema']
            table = row['Table']
            column = row['Column']
            
            # Get class and sensitivity from CSV if columns exist, otherwise use empty string
            column_class = row.get('Class', '')
            sensitivity = row.get('Sensitivity', '')
            
            # Only process admin_backend.public tables and columns with governance data
            if database == 'admin_backend' and schema == 'public':
                # Only include columns that have BOTH Class AND Sensitivity values
                if column_class and sensitivity:
                    column_info = {
                        'name': column,
                        'class': column_class,
                        'sensitivity': sensitivity
                    }
                    table_columns[table].append(column_info)
    
    return dict(table_columns)


def get_sensitivity_level(table_name: str, column_name: str) -> str:
    """
    Return empty string for sensitivity level.
    
    Args:
        table_name: Name of the table
        column_name: Name of the column
        
    Returns:
        Empty string for sensitivity level
    """
    return ""


def get_data_class(table_name: str) -> str:
    """
    Return empty string for data class.
    
    Args:
        table_name: Name of the table
        
    Returns:
        Empty string for data class
    """
    return ""


def generate_models_yml(table_columns: Dict[str, List[Dict]]) -> Dict:
    """
    Generate dbt models.yml structure from table and column information.
    
    Args:
        table_columns: Dictionary mapping table names to column dictionaries with metadata
        
    Returns:
        Dictionary representing the models.yml structure
    """
    models = []
    
    for table_name in sorted(table_columns.keys()):
        columns = table_columns[table_name]
        
        # Convert table name to model name with stg__ prefix
        model_name = f'stg__{table_name}'
        alias_name = table_name
        if table_name == 'alembic_version':
            model_name = 'stg__admin_backend_alembic_version'
            alias_name = 'admin_backend_alembic_version'
        
        # Create model structure
        model = {
            'name': model_name,
            'description': f'Model for {table_name} table from admin_backend database',
            'config': {
                'alias': alias_name
            },
            'columns': []
        }
        
        # Add columns with their specific class and sensitivity from CSV
        for column_info in sorted(columns, key=lambda x: x['name']):
            column_def = {
                'name': column_info['name'],
                'description': f'{column_info["name"]} column from {table_name} table',
                'meta': {
                    'class': column_info['class'],
                    'sensitivity': column_info['sensitivity']
                }
            }
            model['columns'].append(column_def)
        
        models.append(model)
    
    return {
        'version': 2,
        'models': models
    }


def write_models_yml(models_data: Dict, output_path: str):
    """
    Write models.yml file with proper formatting.
    
    Args:
        models_data: Dictionary containing models configuration
        output_path: Path where to write the models.yml file
    """
    # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w') as f:
        yaml.dump(models_data, f, default_flow_style=False, sort_keys=False, indent=2)


def main():
    """Main function to generate models.yml from CSV schema."""
    # Define paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    
    csv_path = os.path.join(repo_root, 'fivetran', 'bronze_columns', 'admin_backend.csv')
    output_path = os.path.join(repo_root, 'dbt', 'models', 'ai_chats', 'admin_backend', 'public', 'models.yml')
    
    # Check if CSV file exists
    if not os.path.exists(csv_path):
        print(f"Error: CSV file not found at {csv_path}")
        return
    
    print(f"Reading schema from: {csv_path}")
    
    # Read CSV and generate models.yml
    table_columns = read_csv_schema(csv_path)
    models_data = generate_models_yml(table_columns)
    
    # Write models.yml file
    write_models_yml(models_data, output_path)
    
    print(f"Generated models.yml at: {output_path}")
    print(f"Generated {len(models_data['models'])} model definitions")
    
    # Print summary
    print("\nModels generated:")
    for model in models_data['models']:
        print(f"  - {model['name']} ({len(model['columns'])} columns)")


if __name__ == '__main__':
    main()