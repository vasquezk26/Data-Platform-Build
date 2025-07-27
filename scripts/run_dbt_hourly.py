#!/usr/bin/env python3
"""
Hourly dbt model execution script for cluster deployment.

This script runs dbt models on a schedule and handles error reporting.
Designed to be executed as a scheduled job on Databricks clusters.

Usage:
    python run_dbt_hourly.py [--models model_pattern] [--env environment]
"""

import argparse
import logging
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def setup_logging():
    """Configure logging for the script."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler('dbt_hourly_run.log')
        ]
    )
    return logging.getLogger(__name__)


def run_dbt_command(command: list, logger: logging.Logger) -> tuple[bool, str]:
    """
    Execute a dbt command and return success status and output.
    
    Args:
        command: List of command arguments
        logger: Logger instance
        
    Returns:
        Tuple of (success, output)
    """
    try:
        logger.info(f"Running command: {' '.join(command)}")
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            cwd='/workspace/dbt',  # Adjust path as needed for your cluster setup
            timeout=3600  # 1 hour timeout
        )
        
        if result.returncode == 0:
            logger.info("Command completed successfully")
            logger.info(f"Output: {result.stdout}")
            return True, result.stdout
        else:
            logger.error(f"Command failed with return code {result.returncode}")
            logger.error(f"Error output: {result.stderr}")
            return False, result.stderr
            
    except subprocess.TimeoutExpired:
        logger.error("Command timed out after 1 hour")
        return False, "Command timed out"
    except Exception as e:
        logger.error(f"Unexpected error running command: {e}")
        return False, str(e)


def run_dbt_models(models: str = None, env: str = "prod", logger: logging.Logger = None) -> bool:
    """
    Run dbt models with optional model selection.
    
    Args:
        models: dbt model selection pattern (optional)
        env: Environment (dev/prod)
        logger: Logger instance
        
    Returns:
        Success status
    """
    # Set environment variables
    os.environ['_ENV'] = env
    
    # Base dbt run command
    command = ['dbt', 'run']
    
    # Add model selection if specified
    if models:
        command.extend(['--models', models])
    
    # Add profile and target
    command.extend(['--profiles-dir', f'environments/{env}'])
    
    success, output = run_dbt_command(command, logger)
    
    if not success:
        logger.error("dbt run failed, attempting to run with --fail-fast for better error reporting")
        # Retry with fail-fast for better error reporting
        retry_command = command + ['--fail-fast']
        run_dbt_command(retry_command, logger)
    
    return success


def run_dbt_tests(env: str = "prod", logger: logging.Logger = None) -> bool:
    """
    Run dbt tests to validate model outputs.
    
    Args:
        env: Environment (dev/prod)
        logger: Logger instance
        
    Returns:
        Success status
    """
    command = [
        'dbt', 'test',
        '--profiles-dir', f'environments/{env}'
    ]
    
    success, output = run_dbt_command(command, logger)
    
    if not success:
        logger.warning("Some dbt tests failed - check logs for details")
    
    return success


def send_notification(success: bool, env: str, models: str, logger: logging.Logger):
    """
    Send notification about job status (placeholder for actual notification system).
    
    Args:
        success: Whether the job succeeded
        env: Environment
        models: Models that were run
        logger: Logger instance
    """
    status = "SUCCESS" if success else "FAILURE"
    message = f"DBT Hourly Run {status} - Env: {env}, Models: {models or 'all'}, Time: {datetime.now()}"
    
    logger.info(f"Notification: {message}")
    
    # TODO: Implement actual notification system (Slack, email, etc.)
    # Example:
    # send_slack_notification(message)
    # send_email_alert(message, success)


def main():
    """Main execution function."""
    parser = argparse.ArgumentParser(description='Run dbt models on hourly schedule')
    parser.add_argument('--models', help='dbt model selection pattern')
    parser.add_argument('--env', default='prod', choices=['dev', 'prod'], help='Environment')
    parser.add_argument('--skip-tests', action='store_true', help='Skip running tests after models')
    
    args = parser.parse_args()
    
    logger = setup_logging()
    
    logger.info(f"Starting hourly dbt run - Environment: {args.env}, Models: {args.models or 'all'}")
    
    try:
        # Run dbt models
        model_success = run_dbt_models(args.models, args.env, logger)
        
        # Run tests if models succeeded and not skipped
        test_success = True
        if model_success and not args.skip_tests:
            test_success = run_dbt_tests(args.env, logger)
        
        overall_success = model_success and test_success
        
        # Send notification
        send_notification(overall_success, args.env, args.models, logger)
        
        if overall_success:
            logger.info("Hourly dbt run completed successfully")
            sys.exit(0)
        else:
            logger.error("Hourly dbt run failed")
            sys.exit(1)
            
    except Exception as e:
        logger.error(f"Unexpected error in main execution: {e}")
        send_notification(False, args.env, args.models, logger)
        sys.exit(1)


if __name__ == '__main__':
    main()