{{ config(materialized='view') }}

-- Transactions with amount greater than 500
SELECT *
FROM {{ source('public', 'transactions') }}
WHERE amount > 500
