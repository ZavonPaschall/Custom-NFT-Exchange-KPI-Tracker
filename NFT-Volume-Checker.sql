-- This query will calculate the Buy, Sell, and total volume for the user provided {{Address}}. Then it will calculate the running totals as well as the volume per year. 

select
  s.MARKETPLACE,
  CASE 
    WHEN s.PURCHASER = '{{Address}}' THEN 'Buy'
    WHEN s.SELLER = '{{Address}}' THEN 'Sell'
  END as "Buy or Sell",
  s.BLOCK_TIMESTAMP,
  m.NFT_COLLECTION_NAME,
  m.NFT_NAME,
  s.SALES_AMOUNT as SOL_SALES_AMOUNT,
  SUM(CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) OVER (ORDER BY s.BLOCK_TIMESTAMP) as RUNNING_BUY_VOLUME,
  SUM(CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) OVER (ORDER BY s.BLOCK_TIMESTAMP) as RUNNING_SELL_VOLUME,
  SUM(CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END + CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) OVER (ORDER BY s.BLOCK_TIMESTAMP) as RUNNING_TOTAL_VOLUME,
  SUM(CASE WHEN s.PURCHASER = '{{Address}}' THEN 1 ELSE 0 END) OVER (ORDER BY s.BLOCK_TIMESTAMP) as RUNNING_BUY_TRANSACTIONS,
  SUM(CASE WHEN s.SELLER = '{{Address}}' THEN 1 ELSE 0 END) OVER (ORDER BY s.BLOCK_TIMESTAMP) as RUNNING_SELL_TRANSACTIONS,
  ROW_NUMBER() OVER (ORDER BY s.BLOCK_TIMESTAMP) as RUNNING_TOTAL_TXNs,
  s.PURCHASER,
  s.SELLER,
  m.mint,
  m.METADATA,
  m.IMAGE_URL,
  m.METADATA_URI,
  s.BLOCK_ID,
  s.TX_ID,
  s.SUCCEEDED,
  s.IS_COMPRESSED,
  -- Sum of combined buy and sell volume in 2024
  SUM(CASE WHEN EXTRACT(YEAR FROM s.BLOCK_TIMESTAMP) = 2024 THEN 
          CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END + 
          CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END 
      ELSE 0 END) 
  OVER () as sum_total_volume_2024,
  
  -- Sum of combined buy and sell volume in 2023
  SUM(CASE WHEN EXTRACT(YEAR FROM s.BLOCK_TIMESTAMP) = 2023 THEN 
          CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END + 
          CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END 
      ELSE 0 END) 
  OVER () as sum_total_volume_2023,
  
  -- Sum of combined buy and sell volume in 2022 or prior
  SUM(CASE WHEN EXTRACT(YEAR FROM s.BLOCK_TIMESTAMP) <= 2022 THEN 
          CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END + 
          CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END 
      ELSE 0 END) 
  OVER () as sum_total_volume_2022_or_prior,
  
  -- Count of rows in 2024
  COUNT(CASE WHEN EXTRACT(YEAR FROM s.BLOCK_TIMESTAMP) = 2024 THEN 1 ELSE NULL END) 
  OVER () as count_rows_2024,
  
  -- Count of rows in 2023
  COUNT(CASE WHEN EXTRACT(YEAR FROM s.BLOCK_TIMESTAMP) = 2023 THEN 1 ELSE NULL END) 
  OVER () as count_rows_2023,
  
  -- Count of rows in 2022 or prior
  COUNT(CASE WHEN EXTRACT(YEAR FROM s.BLOCK_TIMESTAMP) <= 2022 THEN 1 ELSE NULL END) 
  OVER () as count_rows_2022_or_prior,

  -- Percentage of total volume that is buy
  (SUM(CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) 
   OVER (ORDER BY s.BLOCK_TIMESTAMP) * 100.0) / 
   SUM(CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END + 
            CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) 
   OVER (ORDER BY s.BLOCK_TIMESTAMP) as PCT_BUY_VOLUME,

  -- Percentage of total volume that is sell
  (SUM(CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) 
   OVER (ORDER BY s.BLOCK_TIMESTAMP) * 100.0) / 
   SUM(CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END + 
            CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) 
   OVER (ORDER BY s.BLOCK_TIMESTAMP) as PCT_SELL_VOLUME
from
  solana.nft.fact_nft_sales s
  JOIN solana.nft.dim_nft_metadata m ON s.mint = m.mint
where
  s.seller = '{{Address}}'
  OR s.purchaser = '{{Address}}'
order BY
  s.block_timestamp DESC
