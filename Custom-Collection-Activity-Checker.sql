-- this query will monitor the volume and transaction history for the user provided {{Address}} accross the various m.collection_id that they traded over the years. 
-- A link was also provided to each individual collection link so that users can further investigate. 
-- Dashboard Link: https://flipsidecrypto.xyz/HitmonleeCrypto/your-total-sol-nft-volume-txn-count-more-checker-PqwgF9

select
  m.NFT_COLLECTION_NAME,
  SUM(CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) as TOTAL_SOL_BUY_VOLUME,
  SUM(CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) as TOTAL_SOL_SELL_VOLUME,
  SUM(CASE WHEN s.PURCHASER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END + CASE WHEN s.SELLER = '{{Address}}' THEN s.SALES_AMOUNT ELSE 0 END) as TOTAL_SOL_VOLUME,
  COUNT(CASE WHEN s.PURCHASER = '{{Address}}' THEN 1 ELSE NULL END) as TOTAL_BUY_TRANSACTIONS,
  COUNT(CASE WHEN s.SELLER = '{{Address}}' THEN 1 ELSE NULL END) as TOTAL_SELL_TRANSACTIONS,
  COUNT(*) as TOTAL_TRANSACTIONS,
  COUNT(DISTINCT m.mint) as UNIQUE_NFTS_TRADED,
  m.collection_id,
  CONCAT('https://solscan.io/token/', m.collection_id) as Link_To_Collection_URL

from
  solana.nft.fact_nft_sales s
  JOIN solana.nft.dim_nft_metadata m ON s.mint = m.mint
where
  s.seller = '{{Address}}'
  OR s.purchaser = '{{Address}}'
group by
  m.NFT_COLLECTION_NAME, m.collection_id
order by
  TOTAL_SOL_VOLUME DESC
