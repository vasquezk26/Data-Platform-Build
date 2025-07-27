# data-platform-infra

## Setup steps
Prequisites
- Create virtual environment .venv in the root directory of this repo.  
Note: I'm running python 3.12.9

```
python3.12 -m venv ~/src/data-platform-infra/.venv
source ~/src/data-platform-infra/.venv/bin/activate
```

# DBT Setup
```
python -m pip install dbt-core dbt-bigquery dbt-snowflake dbt-databricks
pip install 'snowflake-connector-python[pandas]'
dbt --version
```

> Core:
>   - installed: 1.9.4
>   - latest:    1.9.4 - Up to date!
>
> Plugins:
>   - bigquery:  1.9.1 - Up to date!
>   - snowflake: 1.9.2 - Up to date!

Setup your DBT Profiles:

```
cd ~/
mkdir .dbt
echo "
databricks:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: databricks_poc
      schema: dbt_<username>
      host: fakehostname.3.gcp.databricks.com
      http_path: /sql/1.0/warehouses/0556174cd69373a3
#      auth_type: oauth
#      client_id: <email address>@my_email.com
      auth_type: token
      token: <your token>
      threads: 1

      # Keypair config
      # private_key_path: /Users/zshapiro/.ssh/snowflake_rsa_key.p8
      # or private_key instead of private_key_path
      # private_key_passphrase: [passphrase for the private key, if key is encrypted]

      # warehouse: DEVELOPMENT
      # client_session_keep_alive: False
      query_tag: dbt_<username>

      # optional
      connect_retries: 0 # default 0
      connect_timeout: 10 # default: 10
      retry_on_database_errors: False # default: false
      retry_all: False  # default: false
      reuse_connections: True
" >> ~/.dbt/profiles.yml
```
