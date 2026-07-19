select
date,
token_address,
{{ stablecoin_conversion('value') }} as total_usd_value

from
{{ ref('stg_token_transfers') }} 

where
lower(token_address) in ('0xdac17f958d2ee523a2206206994597c13d831ec7','0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48')

group by
date,
token_address