{{ config(materialized='view') }}

WITH source_data AS (
    SELECT 
        transaction_id,
        account_id,
        transaction_date,
        amount,
        UPPER(currency) as currency,
        UPPER(transaction_type) as transaction_type,
        merchant_id,
        loaded_at
    FROM {{ source('raw', 'transactions') }}
)

SELECT 
    transaction_id,
    account_id,
    transaction_date,
    amount,
    currency,
    transaction_type,
    merchant_id,
    loaded_at,
    CASE 
        WHEN amount = 0 THEN TRUE 
        ELSE FALSE 
    END as is_zero_amount,
    
    CASE 
        WHEN transaction_date > CURRENT_DATE THEN TRUE 
        ELSE FALSE 
    END as is_future_date

FROM source_data
WHERE transaction_id IS NOT NULL