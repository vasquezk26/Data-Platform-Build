#!/bin/bash
"""
Setup script for scheduling the hourly dbt job on a cluster.

This script sets up a cron job to run dbt models every hour.
Run this once on your cluster to establish the schedule.

Usage:
    bash setup_cron_job.sh [environment]
"""

set -e

# Default environment
ENV=${1:-prod}

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DBT_SCRIPT="$SCRIPT_DIR/run_dbt_hourly.py"

echo "Setting up hourly dbt cron job for environment: $ENV"

# Make the Python script executable
chmod +x "$DBT_SCRIPT"

# Create log directory
mkdir -p /var/log/dbt

# Create cron job entry
CRON_ENTRY="0 * * * * cd $SCRIPT_DIR && python3 run_dbt_hourly.py --env $ENV >> /var/log/dbt/hourly_run.log 2>&1"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "run_dbt_hourly.py"; then
    echo "Cron job already exists. Updating..."
    # Remove existing job and add new one
    (crontab -l 2>/dev/null | grep -v "run_dbt_hourly.py"; echo "$CRON_ENTRY") | crontab -
else
    echo "Adding new cron job..."
    # Add new job to existing crontab
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
fi

echo "Cron job setup complete!"
echo "Job will run every hour at minute 0"
echo "Logs will be written to: /var/log/dbt/hourly_run.log"
echo ""
echo "To view current cron jobs: crontab -l"
echo "To remove the job: crontab -e (and delete the line with run_dbt_hourly.py)"
echo ""
echo "Manual test run: python3 $DBT_SCRIPT --env $ENV"