{{ config(
    materialized='table',
    tags=['daily']
) }}

select
    date,
    transaction_category,
    count(*) as txn_count,
    {{ ethereum_conversion('value') }} as sum_eth_value

from  {{ ref('int_transactions_enriched') }} 

group by
date,
transaction_category