{{ config(materialized='incremental', 
    incremental_strategy='append', 
    on_schema_change='sync_all_columns',
    tags=['daily']
) }}

with token_transfer_agg as (
    select
        transaction_hash,
        count(*) as token_transfer_count
    from {{ ref('stg_token_transfers') }} 
    group by transaction_hash
)

select 
t.hash,
t.block_number,
t.date,
t.from_address,
t.to_address,
t.value,
t.receipt_contract_address,
t.input,
tt.token_transfer_count,
1 as new_field,

CASE
    WHEN t.receipt_contract_address != '' THEN 'contract_creation'
    WHEN tt.transaction_hash is not null then 'token_transfer'
    WHEN t.input = '0x' and t.value > 0 THEN 'plain_eth_transfer'
    ELSE 'other'
end as transaction_category

from {{ ref('stg_transactions') }} t

left join token_transfer_agg tt

on t.hash = tt.transaction_hash

{% if is_incremental() %}
where t.date >= (select max(date) from {{ this }})
{% endif %}