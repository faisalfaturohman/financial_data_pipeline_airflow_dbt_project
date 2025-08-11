{{ config(materialized='view') }}

WITH source_data AS (
    SELECT 
        customer_id,
        TRIM(first_name) as first_name,
        TRIM(last_name) as last_name,
        date_of_birth,
        address,
        city,
        UPPER(province) as province,
        loaded_at
    FROM {{ source('raw', 'customers') }}
)

SELECT 
    customer_id,
    first_name,
    last_name,
    date_of_birth,
    address,
    city,
    province,
    loaded_at,
    -- Calculated fields
    CONCAT(first_name, ' ', last_name) as full_name,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) as age,
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) >= 65 THEN 'SENIOR'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) >= 18 THEN 'ADULT'
        ELSE 'MINOR'
    END as age_category

FROM source_data
WHERE customer_id IS NOT NULL