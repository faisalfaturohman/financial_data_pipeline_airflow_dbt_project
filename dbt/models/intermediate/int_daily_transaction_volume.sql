{{ config(materialized='view') }}

SELECT 
    account_id,
    transaction_date,
    transaction_type,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount,
    SUM(amount_usd) as total_amount_usd,
    AVG(amount) as avg_amount,
    MIN(amount) as min_amount,
    MAX(amount) as max_amount,
    COUNT(CASE WHEN amount > 0 THEN 1 END) as credit_count,
    COUNT(CASE WHEN amount < 0 THEN 1 END) as debit_count,
    SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) as total_credits,
    SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) as total_debits

FROM {{ ref('int_transactions_with_accounts') }}
GROUP BY 
    account_id,
    transaction_date,
    transaction_type