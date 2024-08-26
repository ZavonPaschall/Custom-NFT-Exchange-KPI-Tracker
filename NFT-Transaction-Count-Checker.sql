-- This query was focused on collected the transaction count and volume for the user provided {{Address}} by summing the various CASE WHEN statements. 
-- Dashboard Link: https://flipsidecrypto.xyz/HitmonleeCrypto/your-total-sol-nft-volume-txn-count-more-checker-PqwgF9

SELECT
  DATE_TRUNC('month', s.block_timestamp) AS month_start,
  SUM(CASE WHEN s.purchaser = '{{Address}}' THEN s.sales_amount ELSE 0 END) AS total_buy_volume,
  SUM(SUM(CASE WHEN s.purchaser = '{{Address}}' THEN s.sales_amount ELSE 0 END)) 
    OVER (ORDER BY DATE_TRUNC('month', s.block_timestamp)) AS running_total_buy_volume,
  SUM(CASE WHEN s.seller = '{{Address}}' THEN s.sales_amount ELSE 0 END) AS total_sell_volume,
  SUM(SUM(CASE WHEN s.seller = '{{Address}}' THEN s.sales_amount ELSE 0 END)) 
    OVER (ORDER BY DATE_TRUNC('month', s.block_timestamp)) AS running_total_sell_volume,
  (SUM(CASE WHEN s.purchaser = '{{Address}}' THEN s.sales_amount ELSE 0 END) + 
   SUM(CASE WHEN s.seller = '{{Address}}' THEN s.sales_amount ELSE 0 END)) AS monthly_total_volume,
  SUM(SUM(CASE WHEN s.purchaser = '{{Address}}' THEN s.sales_amount ELSE 0 END + 
          CASE WHEN s.seller = '{{Address}}' THEN s.sales_amount ELSE 0 END)) 
    OVER (ORDER BY DATE_TRUNC('month', s.block_timestamp)) AS running_total_monthly_volume,
  COUNT(CASE WHEN s.purchaser = '{{Address}}' THEN 1 ELSE NULL END) AS total_buy_transactions,
  SUM(COUNT(CASE WHEN s.purchaser = '{{Address}}' THEN 1 ELSE NULL END)) 
    OVER (ORDER BY DATE_TRUNC('month', s.block_timestamp)) AS running_total_buy_transactions,
  COUNT(CASE WHEN s.seller = '{{Address}}' THEN 1 ELSE NULL END) AS total_sell_transactions,
  SUM(COUNT(CASE WHEN s.seller = '{{Address}}' THEN 1 ELSE NULL END)) 
    OVER (ORDER BY DATE_TRUNC('month', s.block_timestamp)) AS running_total_sell_transactions,
  (COUNT(CASE WHEN s.purchaser = '{{Address}}' THEN 1 ELSE NULL END) +
   COUNT(CASE WHEN s.seller = '{{Address}}' THEN 1 ELSE NULL END)) AS monthly_total_transactions,
  SUM(COUNT(CASE WHEN s.purchaser = '{{Address}}' THEN 1 ELSE NULL END) +
      COUNT(CASE WHEN s.seller = '{{Address}}' THEN 1 ELSE NULL END)) 
    OVER (ORDER BY DATE_TRUNC('month', s.block_timestamp)) AS running_total_monthly_transactions
FROM
  solana.nft.fact_nft_sales s
WHERE
  s.seller = '{{Address}}'
  OR s.purchaser = '{{Address}}'
GROUP BY
  DATE_TRUNC('month', s.block_timestamp)
ORDER BY
  month_start DESC;
