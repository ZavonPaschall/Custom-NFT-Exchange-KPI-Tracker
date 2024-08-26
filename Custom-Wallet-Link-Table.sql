-- this was a simple query that would provide a link for the user provided {{Address}} so that they can dig deeper into their activity. 
-- FROM was not needed as none of the data is coming from a table, it is all coming from the user inputed {{Address}} and the CONCAT function. 
-- Dashboard Link: https://flipsidecrypto.xyz/HitmonleeCrypto/your-total-sol-nft-volume-txn-count-more-checker-PqwgF9

SELECT
    '{{Address}}' AS "Address You Provided",
    CONCAT('https://www.tensor.trade/portfolio?wallet=', '{{Address}}') AS "Your Tensor Portfolio Link",
    CONCAT('https://magiceden.io/u/', '{{Address}}') AS "Your Magic Eden Portfolio Link"
