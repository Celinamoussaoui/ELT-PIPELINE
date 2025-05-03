WITH source AS (

    SELECT * 
    FROM {{ source('marketing', 'raw_email_campaigns') }}

),

stg_email_campaigns AS (

    SELECT
        campaign_id,
        subject,
        LOWER(utm_campaign) AS utm_campaign,
        DATE(date_sent) AS campaign_date,
        CAST(recipients AS INT64) AS recipients,
        CAST(open_rate AS FLOAT64) AS open_rate,
        CAST(click_rate AS FLOAT64) AS click_rate,
        CAST(unsubscribes AS INT64) AS unsubscribes,
        CAST(conversions AS INT64) AS conversions,
        CAST(revenue AS FLOAT64) AS revenue,
        'email' AS source

    FROM source

)

SELECT *
FROM stg_email_campaigns
