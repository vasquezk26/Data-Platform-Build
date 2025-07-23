#!/usr/bin/env python3
"""
Add empty Class and Sensitivity columns to all rows in admin_backend.csv
"""

import csv
import os

def add_empty_columns():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    csv_path = os.path.join(repo_root, 'fivetran', 'bronze_columns', 'admin_backend.csv')
    
    # Read all rows
    rows = []
    with open(csv_path, 'r', newline='') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            # Add empty values if row doesn't have them already
            if len(row) == 4:  # Only Database,Schema,Table,Column
                row.extend(['', ''])  # Add empty Class and Sensitivity
            elif len(row) == 5:  # Has Class but not Sensitivity
                row.append('')  # Add empty Sensitivity
            rows.append(row)
    
    # Write back with all rows having empty Class,Sensitivity
    with open(csv_path, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerows(rows)
    
    print(f"Updated {len(rows)} rows in {csv_path}")

if __name__ == '__main__':
    add_empty_columns()