{{ config(materialized='view') }}

-- Transactions with amount less than or equal to 500
SELECT *
FROM {{ source('public', 'transactions') }}
WHERE amount <= 500
