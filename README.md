# Ethereum dbt Project

A dbt (data build tool) project for transforming raw Ethereum on-chain data in Snowflake. Built while following Daniel Weigel's Udemy course *"dbt (Data Build Tool) - Complete Analytics Engineering Course"*, using Ethereum blockchain data as the working example instead of the course's default dataset.

## Stack

- **dbt-core** 1.9.4
- **dbt-snowflake** 1.9.4 (adapter)
- **Warehouse:** Snowflake

## Project structure

The dbt project lives in [`eth/`](eth/).

```
eth/
├── models/
│   ├── base/                       # staging models (1:1 with sources)
│   │   ├── stg_contracts.sql
│   │   ├── stg_token_transfers.sql
│   │   └── stg_transactions.sql
│   ├── intermediate/
│   │   └── int_transactions_enriched.sql   # transactions + token transfer aggregates
│   ├── marts/
│   │   ├── eth_activity_per_day.sql        # daily transaction activity & ETH volume
│   │   └── stablecoin_activity_per_day.sql # daily USDT/USDC transfer volume
│   ├── token_transfer_agg.sql      # ephemeral aggregation of token transfers per tx
│   └── sources.yml                 # source definitions (eth.contracts, token_transfers, transactions)
├── macros/
│   └── conversion_utils.sql        # ethereum_conversion() / stablecoin_conversion() unit helpers
├── seeds/
├── snapshots/
├── analyses/
├── tests/
└── dbt_project.yml
```

### Data flow

1. **Sources** (`eth.contracts`, `eth.token_transfers`, `eth.transactions`) are raw tables loaded into Snowflake.
2. **Staging models** (`stg_*`) select and lightly clean the source data. `stg_transactions` is incremental (merge on `hash`).
3. **Intermediate model** (`int_transactions_enriched`) joins transactions to a token-transfer aggregate and categorizes each transaction (`contract_creation`, `token_transfer`, `plain_eth_transfer`, `other`). It's incremental (append), tagged `daily`.
4. **Marts** aggregate enriched data into daily reporting tables:
   - `eth_activity_per_day` — transaction counts and ETH volume by day/category (tagged `daily`).
   - `stablecoin_activity_per_day` — USDT/USDC transfer volume by day.

## Setup

```bash
# create and activate a virtual environment
python -m venv venv
venv\Scripts\activate          # Windows PowerShell

# install dbt
pip install dbt-core==1.9.4 dbt-snowflake==1.9.4
dbt --version

# initialize your profile (creates ~/.dbt/profiles.yml)
dbt init

# verify the connection to Snowflake
dbt debug
```

Snowflake connection uses [key pair authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth):

```bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
```

## Usage

Run all commands from inside the `eth/` directory.

```bash
# run everything
dbt run

# run only the models tagged for the daily job
dbt run -s tag:daily

# run tests
dbt test
```

## Resources

- Daniel Weigel's dbt Udemy course — *"dbt (Data Build Tool) - Complete Analytics Engineering Course"*
- [dbt docs](https://docs.getdbt.com/docs/introduction)
- [dbt Discourse](https://discourse.getdbt.com/)
