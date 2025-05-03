WITH google AS (
    SELECT
        utm_campaign,
        'google' AS source,
        total_clicks,
        total_impressions,
        total_conversions,
        total_cost,
        total_leads,
        converted_leads,
        crm_revenue,
        ctr,
        cpc,
        cpa,
        roas,
        NULL AS recipients,
        NULL AS avg_open_rate,
        NULL AS avg_click_rate,
        NULL AS email_revenue
    FROM {{ ref('int_google_campaign_summary') }}
),

facebook AS (
    SELECT
        utm_campaign,
        source,
        total_clicks,
        total_impressions,
        total_conversions,
        total_cost,
        total_leads,
        converted_leads,
        crm_revenue,
        ctr,
        cpc,
        cpa,
        roas,
        NULL AS recipients,
        NULL AS avg_open_rate,
        NULL AS avg_click_rate,
        NULL AS email_revenue
    FROM {{ ref('int_facebook_campaign_performance') }}
),

email AS (
    SELECT
        utm_campaign,
        source,
        NULL AS total_clicks,
        NULL AS total_impressions,
        email_conversions AS total_conversions,
        NULL AS total_cost,
        total_leads,
        converted_leads,
        crm_revenue,
        NULL AS ctr,
        NULL AS cpc,
        NULL AS cpa,
        roas_email_vs_crm AS roas,
        total_recipients AS recipients,
        avg_open_rate,
        avg_click_rate,
        email_revenue
    FROM {{ ref('int_email_campaign_performance') }}
)

SELECT * FROM google
UNION ALL
SELECT * FROM facebook
UNION ALL
SELECT * FROM email
