select
transaction_hash,
date,
token_address,
value

from {{ source('eth','token_transfers') }}