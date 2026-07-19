select
address,
block_number,
bytecode,
last_modified

from {{ source('eth', 'contracts') }}