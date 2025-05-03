WITH keyword_metrics AS (
    SELECT
        LOWER(keyword) AS keyword,
        match_type,
        COUNT(*) AS nb_rows,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(conversions) AS conversions,
        SUM(cost) AS cost,

        SAFE_DIVIDE(SUM(clicks), SUM(impressions)) AS ctr,
        SAFE_DIVIDE(SUM(cost), SUM(clicks)) AS cpc,
        SAFE_DIVIDE(SUM(conversions), SUM(clicks)) AS conversion_rate,
        SAFE_DIVIDE(SUM(cost), SUM(conversions)) AS cpa

    FROM {{ ref('stg_google_ads_campaigns') }}
    WHERE keyword IS NOT NULL
    GROUP BY keyword, match_type
)

SELECT * FROM keyword_metrics
