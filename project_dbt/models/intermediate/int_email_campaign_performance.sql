WITH email AS (
    SELECT
        utm_campaign,
        campaign_date,
        SUM(recipients) AS total_recipients,
        SUM(conversions) AS email_conversions,
        SUM(revenue) AS email_revenue,
        AVG(open_rate) AS avg_open_rate,
        AVG(click_rate) AS avg_click_rate
    FROM {{ ref('stg_email_campaigns') }}
    GROUP BY utm_campaign, campaign_date
),

crm AS (
    SELECT
        utm_campaign,
        COUNT(*) AS total_leads,
        SUM(CAST(is_converted AS INT64)) AS converted_leads,
        SUM(revenue) AS crm_revenue
    FROM {{ ref('stg_crm_leads') }}
    WHERE utm_source = 'email'
    GROUP BY utm_campaign
)

SELECT
    e.utm_campaign,
    'email' AS source,
    e.campaign_date,
    e.total_recipients,
    e.email_conversions,
    e.email_revenue,
    e.avg_open_rate,
    e.avg_click_rate,

    c.total_leads,
    c.converted_leads,
    c.crm_revenue,

    SAFE_DIVIDE(c.crm_revenue, NULLIF(e.email_revenue, 0)) AS roas_email_vs_crm,
    SAFE_DIVIDE(e.email_revenue, c.converted_leads) AS average_revenue_per_conversion

FROM email e
LEFT JOIN crm c
  ON e.utm_campaign = c.utm_campaign
