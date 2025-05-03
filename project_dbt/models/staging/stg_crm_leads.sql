WITH source AS (

    SELECT * 
    FROM {{ source('marketing', 'raw_crm_leads') }}

),

stg_crm_leads AS (

    SELECT
        lead_id,
        user_id,
        DATE(date_created) AS date_created,
        LOWER(status) AS status,
        LOWER(deal_stage) AS deal_stage,
        CAST(revenue AS FLOAT64) AS revenue,
        LOWER(utm_source) AS utm_source,
        LOWER(utm_medium) AS utm_medium,
        LOWER(utm_campaign) AS utm_campaign,
        -- booléen pratique pour les conversions
        CASE 
            WHEN LOWER(status) = 'converted' THEN TRUE 
            ELSE FALSE 
        END AS is_converted

    FROM source

)

SELECT *
FROM stg_crm_leads
