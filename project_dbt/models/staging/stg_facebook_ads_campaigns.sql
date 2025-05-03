WITH source AS (

    SELECT * 
    FROM {{ source('marketing', 'raw_facebook_ads_campaigns') }}

),

stg_facebook_ads_campaigns AS (

    SELECT
        CAST(ad_id AS STRING) AS ad_id,
        CAST(adset_id AS STRING) AS adset_id,
        CAST(campaign_id AS STRING) AS campaign_id,
        campaign_name,
        adset_name,
        DATE(date_start) AS campaign_date,
        publisher_platform,
        platform_position,
        CAST(impressions AS INT64) AS impressions,
        CAST(clicks AS INT64) AS clicks,
        CAST(spend AS FLOAT64) AS cost,
        CAST(conversions AS INT64) AS conversions,
        LOWER(utm_campaign) AS utm_campaign,
        'facebook' AS source

    FROM source

)

SELECT *
FROM stg_facebook_ads_campaigns
