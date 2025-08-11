{{ config(materialized='view') }}

WITH source_data AS (
    SELECT 
        account_id,
        customer_id,
        opening_date,
        UPPER(account_type) as account_type,
        balance,
        loaded_at
    FROM {{ source('raw', 'accounts') }}
)

SELECT 
    account_id,
    customer_id,
    opening_date,
    account_type,
    balance,
    loaded_at,
    CASE 
        WHEN opening_date <= CURRENT_DATE - INTERVAL '365 days' THEN 'MATURE'
        WHEN opening_date <= CURRENT_DATE - INTERVAL '90 days' THEN 'ESTABLISHED'
        ELSE 'NEW'
    END as account_age_category

FROM source_data
WHERE account_id IS NOT NULL