{{ config(materialized='table') }}

WITH transaction_fact AS (
    SELECT 
        t.transaction_id,
        t.transaction_date,
        t.amount,
        t.currency,
        t.amount_usd,
        t.transaction_type,
        t.transaction_direction,
        t.merchant_id,
        t.account_id,
        t.account_type,
        t.account_opening_date,
        t.account_age_category,
        c.customer_id,
        c.full_name as customer_name,
        c.age as customer_age,
        c.age_category as customer_age_category,
        c.city as customer_city,
        c.province as customer_province,
        EXTRACT(YEAR FROM t.transaction_date) as transaction_year,
        EXTRACT(MONTH FROM t.transaction_date) as transaction_month,
        EXTRACT(DAY FROM t.transaction_date) as transaction_day,
        EXTRACT(DOW FROM t.transaction_date) as transaction_dow,
        TO_CHAR(t.transaction_date, 'YYYY-MM') as transaction_year_month,
        ABS(t.amount_usd) as absolute_amount_usd,
        CASE 
            WHEN ABS(t.amount_usd) >= 1000 THEN 'HIGH'
            WHEN ABS(t.amount_usd) >= 100 THEN 'MEDIUM'
            ELSE 'LOW'
        END as transaction_size_category,
        t.is_zero_amount,
        t.is_future_date,
        t.loaded_at,
        CURRENT_TIMESTAMP as transformed_at
    FROM {{ ref('int_transactions_with_accounts') }} t
    LEFT JOIN {{ ref('stg_customers') }} c 
        ON t.customer_id = c.customer_id
)

SELECT * FROM transaction_fact