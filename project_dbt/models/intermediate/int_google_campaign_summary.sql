WITH ads AS (
    SELECT
        utm_campaign,
        SUM(clicks) AS total_clicks,
        SUM(impressions) AS total_impressions,
        SUM(conversions) AS total_conversions,
        SUM(cost) AS total_cost
    FROM {{ ref('stg_google_ads_campaigns') }}
    GROUP BY utm_campaign
),

crm AS (
    SELECT
        utm_campaign,
        COUNT(*) AS total_leads,
        SUM(CAST(is_converted AS INT64)) AS converted_leads,
        SUM(revenue) AS crm_revenue
    FROM {{ ref('stg_crm_leads') }}
    WHERE utm_source = 'google'
    GROUP BY utm_campaign
)

SELECT
    a.utm_campaign,
    'google' AS source,
    a.total_clicks,
    a.total_impressions,
    a.total_conversions,
    a.total_cost,
    
    c.total_leads,
    c.converted_leads,
    c.crm_revenue,

    -- KPIs
    SAFE_DIVIDE(a.total_clicks, a.total_impressions) AS ctr,
    SAFE_DIVIDE(a.total_cost, a.total_clicks) AS cpc,
    SAFE_DIVIDE(a.total_cost, c.converted_leads) AS cpa,
    SAFE_DIVIDE(c.crm_revenue, a.total_cost) AS roas

FROM ads a
LEFT JOIN crm c
  ON a.utm_campaign = c.utm_campaign
