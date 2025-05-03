WITH source AS (

    SELECT * 
    FROM {{ source('marketing', 'raw_google_ads_campaigns') }}

),

stg_google_ads_campaigns AS (

    SELECT
        CAST(`campaign_id` AS STRING) AS campaign_id,
        `campaign_name` AS campaign_name,
        `ad_group_name` AS ad_group_name,
        `segments_keyword_info_text` AS keyword,
        `segments_keyword_info_match_type` AS match_type,
        `segments_device` AS device,
        CAST(`segments_date` AS DATE) AS campaign_date,
        CAST(`metrics_clicks` AS INT64) AS clicks,
        CAST(`metrics_impressions` AS INT64) AS impressions,
        CAST(`metrics_cost_micros` AS INT64) / 1000000 AS cost,
        CAST(`metrics_conversions` AS INT64) AS conversions,
        LOWER(utm_campaign) AS utm_campaign,
        'google' AS source

    FROM source

)

SELECT *
FROM stg_google_ads_campaigns
