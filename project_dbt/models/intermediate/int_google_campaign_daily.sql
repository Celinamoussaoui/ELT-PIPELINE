SELECT
    utm_campaign,
    'google' AS source,
    campaign_date,
    SUM(clicks) AS total_clicks,
    SUM(impressions) AS total_impressions,
    SUM(conversions) AS total_conversions,
    SUM(cost) AS total_cost,
    SAFE_DIVIDE(SUM(clicks), SUM(impressions)) AS ctr,
    SAFE_DIVIDE(SUM(cost), SUM(clicks)) AS cpc
FROM {{ ref('stg_google_ads_campaigns') }}
GROUP BY utm_campaign, campaign_date
