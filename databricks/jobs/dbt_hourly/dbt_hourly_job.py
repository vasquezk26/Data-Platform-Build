# Databricks notebook source
# MAGIC %md
# MAGIC # DBT Hourly Execution Job
# MAGIC 
# MAGIC This notebook runs dbt models on an hourly schedule within Databricks.
# MAGIC It's designed to be executed as a Databricks Job with scheduling.
# MAGIC 
# MAGIC **Setup Instructions:**
# MAGIC 1. Install dbt in your cluster: `%pip install dbt-databricks`
# MAGIC 2. Clone your dbt repository to Databricks workspace
# MAGIC 3. Create a Databricks Job pointing to this notebook
# MAGIC 4. Set schedule to run hourly
# MAGIC 
# MAGIC **Widget Parameters:**
# MAGIC - `env`: Environment (dev/prod) 
# MAGIC - `models`: Model selection pattern (optional)
# MAGIC - `skip_tests`: Skip test execution (true/false)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Setup and Configuration

# COMMAND ----------

# Install dbt if not already available
%pip install dbt-databricks

# COMMAND ----------

# Setup widgets for job parameters
dbutils.widgets.dropdown("env", "prod", ["dev", "prod"], "Environment")
dbutils.widgets.text("models", "", "Models (optional)")
dbutils.widgets.dropdown("skip_tests", "false", ["true", "false"], "Skip Tests")

# Get widget values
env = dbutils.widgets.get("env")
models = dbutils.widgets.get("models")
skip_tests = dbutils.widgets.get("skip_tests").lower() == "true"

print(f"Running dbt job with:")
print(f"  Environment: {env}")
print(f"  Models: {models if models else 'all'}")
print(f"  Skip Tests: {skip_tests}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## DBT Execution Functions

# COMMAND ----------

import subprocess
import os
import sys
from datetime import datetime
import json

def setup_environment(env_name):
    """Setup environment variables and paths for dbt execution."""
    os.environ['_ENV'] = env_name
    
    # Set dbt project directory (adjust path as needed)
    dbt_project_dir = "/Workspace/Repos/data-platform-infra/dbt"
    os.chdir(dbt_project_dir)
    
    print(f"Working directory: {os.getcwd()}")
    print(f"Environment variable _ENV: {os.environ.get('_ENV')}")
    
    return dbt_project_dir

def run_dbt_command(command_args, timeout=3600):
    """Execute a dbt command and return results."""
    try:
        print(f"Executing: dbt {' '.join(command_args)}")
        
        result = subprocess.run(
            ['dbt'] + command_args,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=os.getcwd()
        )
        
        # Print output
        if result.stdout:
            print("STDOUT:")
            print(result.stdout)
        
        if result.stderr:
            print("STDERR:")
            print(result.stderr)
        
        if result.returncode == 0:
            print("✅ Command completed successfully")
            return True, result.stdout
        else:
            print(f"❌ Command failed with return code {result.returncode}")
            return False, result.stderr
            
    except subprocess.TimeoutExpired:
        print(f"❌ Command timed out after {timeout} seconds")
        return False, "Command timed out"
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False, str(e)

def send_notification(success, env, models, error_msg=None):
    """Send notification about job status."""
    status = "SUCCESS" ✅" if success else "FAILURE ❌"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    message = f"""
    DBT Hourly Job {status}
    Timestamp: {timestamp}
    Environment: {env}
    Models: {models if models else 'all'}
    """
    
    if not success and error_msg:
        message += f"\nError: {error_msg}"
    
    print("=" * 50)
    print("JOB NOTIFICATION")
    print(message)
    print("=" * 50)
    
    # TODO: Add actual notification integrations
    # Example: Send to Slack webhook, email, etc.
    # webhook_url = dbutils.secrets.get("slack", "webhook-url")
    # requests.post(webhook_url, json={"text": message})

# COMMAND ----------

# MAGIC %md
# MAGIC ## Main Execution

# COMMAND ----------

def main():
    """Main execution function."""
    start_time = datetime.now()
    print(f"🚀 Starting DBT hourly job at {start_time}")
    
    try:
        # Setup environment
        setup_environment(env)
        
        # Build dbt run command
        run_command = ['run', '--profiles-dir', f'environments/{env}']
        
        if models:
            run_command.extend(['--models', models])
        
        # Execute dbt run
        print("\n" + "="*50)
        print("RUNNING DBT MODELS")
        print("="*50)
        
        run_success, run_output = run_dbt_command(run_command)
        
        if not run_success:
            # Try again with fail-fast for better error reporting
            print("\n⚠️ Initial run failed, retrying with --fail-fast...")
            retry_command = run_command + ['--fail-fast']
            run_dbt_command(retry_command)
        
        # Run tests if models succeeded and not skipped
        test_success = True
        if run_success and not skip_tests:
            print("\n" + "="*50)
            print("RUNNING DBT TESTS")
            print("="*50)
            
            test_command = ['test', '--profiles-dir', f'environments/{env}']
            if models:
                test_command.extend(['--models', models])
            
            test_success, test_output = run_dbt_command(test_command)
            
            if not test_success:
                print("⚠️ Some tests failed - check output above")
        
        # Overall success
        overall_success = run_success and test_success
        
        # Calculate duration
        end_time = datetime.now()
        duration = end_time - start_time
        
        print(f"\n⏱️ Total execution time: {duration}")
        
        # Send notification
        error_msg = None if overall_success else "Check logs for details"
        send_notification(overall_success, env, models, error_msg)
        
        if overall_success:
            print("\n🎉 DBT hourly job completed successfully!")
        else:
            print("\n💥 DBT hourly job failed!")
            raise Exception("Job failed - see logs above")
            
    except Exception as e:
        print(f"\n💥 Fatal error in job execution: {e}")
        send_notification(False, env, models, str(e))
        raise

# Execute main function
main()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Job Completion
# MAGIC 
# MAGIC The DBT hourly job has completed. Check the output above for details.
# MAGIC 
# MAGIC **Next Steps:**
# MAGIC 1. Review the execution logs
# MAGIC 2. Check data freshness in your target schemas
# MAGIC 3. Monitor any notification channels configured
# MAGIC 
# MAGIC **Troubleshooting:**
# MAGIC - If jobs fail, check the error output in the cell above
# MAGIC - Verify dbt profiles are correctly configured for the environment
# MAGIC - Ensure cluster has necessary permissions for target schemas