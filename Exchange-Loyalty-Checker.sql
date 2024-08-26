-- This query was used to create a Pie chart that will display the "loyalty" of a wallet to a specific exchange. 
-- Magic eden has various versions to their program_id so an ILIKE was used to ensure that all of them we're input correctly. 
-- Dashboard Link: https://flipsidecrypto.xyz/HitmonleeCrypto/your-total-sol-nft-volume-txn-count-more-checker-PqwgF9

select
  case 
    when s.marketplace ILIKE '%magic%' then 'Magic Eden'
    else s.marketplace
  end as marketplace,
  count(*) as marketplace_count,
  concat(ROUND(count(*) * 100.0 / sum(count(*)) over (), 2), '%') as percent_share
from
  solana.nft.fact_nft_sales s
  JOIN solana.nft.dim_nft_metadata m ON s.mint = m.mint
where
  s.seller = '{{Address}}'
  OR s.purchaser = '{{Address}}'
group by
  case 
    when s.marketplace ILIKE '%magic%' then 'Magic Eden'
    else s.marketplace
  end
order by
  marketplace_count desc;
