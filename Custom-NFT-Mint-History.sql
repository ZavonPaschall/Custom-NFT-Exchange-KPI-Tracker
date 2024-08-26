-- This query is used to find the Mint history of the user provided {{Address}} across multiple years.
-- A CASE WHEN was implemented to ensure that that the mint currency was displayed correctly. 
-- Dashboard Link: https://flipsidecrypto.xyz/HitmonleeCrypto/your-total-sol-nft-volume-txn-count-more-checker-PqwgF9

select
  mi.block_timestamp,
  me.nft_collection_name,
  me.nft_name,
  mi.mint_price as mint_price,
CASE 
    WHEN mi.mint_currency = 'So11111111111111111111111111111111111111111' THEN 'SOL'
    ELSE mi.mint_currency
  END as mint_currency,
  SUM(
    CASE 
      WHEN mi.mint_currency = 'So11111111111111111111111111111111111111111' THEN mi.mint_price
      ELSE 0
    END
  ) OVER (ORDER BY mi.block_timestamp DESC) as running_total_mint_price,
  mi.is_compressed,
  SUM(mi.mint_price) OVER (ORDER BY mi.block_timestamp) as running_total_mint_sol_paid,
  ROW_NUMBER() OVER (ORDER BY mi.block_timestamp) as total_mint_count,
  mi.mint,
  me.collection_id,
  me.metadata,
  -- Sum of mint price paid in 2024
  SUM(CASE WHEN EXTRACT(YEAR FROM mi.block_timestamp) = 2024 THEN mi.mint_price ELSE 0 END) 
  OVER () as sol_mint_cost_2024,
  
  -- Sum of mint price paid in 2023
  SUM(CASE WHEN EXTRACT(YEAR FROM mi.block_timestamp) = 2023 THEN mi.mint_price ELSE 0 END) 
  OVER () as sol_mint_cost_2023,
  
  -- Sum of mint price paid in 2022 or prior
  SUM(CASE WHEN EXTRACT(YEAR FROM mi.block_timestamp) <= 2022 THEN mi.mint_price ELSE 0 END) 
  OVER () as sol_mint_cost_2022_or_prior,
  
  -- Count of rows in 2024
  COUNT(CASE WHEN EXTRACT(YEAR FROM mi.block_timestamp) = 2024 THEN 1 ELSE NULL END) 
  OVER () as mint_count_2024,
  
  -- Count of rows in 2023
  COUNT(CASE WHEN EXTRACT(YEAR FROM mi.block_timestamp) = 2023 THEN 1 ELSE NULL END) 
  OVER () as mint_count_2023,
  
  -- Count of rows in 2022 or prior
  COUNT(CASE WHEN EXTRACT(YEAR FROM mi.block_timestamp) <= 2022 THEN 1 ELSE NULL END) 
  OVER () as mint_count_2022_or_prior,
from
  solana.nft.fact_nft_mints mi
  JOIN solana.nft.dim_nft_metadata me 
  ON mi.mint = me.mint
where
  purchaser = '{{Address}}'
order by
  block_timestamp DESC
