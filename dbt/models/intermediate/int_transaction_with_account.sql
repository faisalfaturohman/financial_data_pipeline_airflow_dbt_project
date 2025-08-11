{{ config(materialized='view') }}

WITH transactions_enhanced AS (
    SELECT 
        t.*,
        a.customer_id,
        a.account_type,
        a.opening_date as account_opening_date,
        a.account_age_category
    FROM {{ ref('stg_transactions') }} t
    LEFT JOIN {{ ref('stg_accounts') }} a 
        ON t.account_id = a.account_id
)

SELECT 
    *,
    CASE 
        WHEN currency = 'USD' THEN amount
        WHEN currency = 'EUR' THEN amount * 1.1
        WHEN currency = 'CAD' THEN amount * 0.75
        ELSE amount
    END as amount_usd,
    
    -- Transaction categorization
    CASE 
        WHEN amount > 0 THEN 'CREDIT'
        WHEN amount < 0 THEN 'DEBIT'
        ELSE 'ZERO'
    END as transaction_direction

FROM transactions_enhanced