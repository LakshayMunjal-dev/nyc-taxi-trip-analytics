-- NYC Taxi Trip Analytics
-- 05: Demand Analysis
--
-- Business question:
-- When and where is NYC Yellow Taxi demand highest?


-- =========================================================
-- 1. Trips by pickup hour
-- =========================================================

SELECT
    pickup_hour,
    COUNT(*) AS total_trips,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_trips
FROM trips_enriched
GROUP BY pickup_hour
ORDER BY pickup_hour;


-- =========================================================
-- 2. Average daily demand by day of week
-- =========================================================

WITH daily_demand AS (
    SELECT
        pickup_date,
        pickup_day_of_week,
        STRFTIME(pickup_datetime, '%A') AS day_name,
        COUNT(*) AS daily_trips
    FROM trips_enriched
    GROUP BY
        pickup_date,
        pickup_day_of_week,
        STRFTIME(pickup_datetime, '%A')
)

SELECT
    pickup_day_of_week,
    day_name,
    COUNT(*) AS number_of_days,
    SUM(daily_trips) AS total_monthly_trips,
    ROUND(AVG(daily_trips), 0) AS avg_daily_trips
FROM daily_demand
GROUP BY
    pickup_day_of_week,
    day_name
ORDER BY avg_daily_trips DESC;


-- =========================================================
-- 3. Top 20 pickup zones by demand
-- =========================================================

SELECT
    pickup_borough,
    pickup_zone,
    COUNT(*) AS total_trips,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_all_trips
FROM trips_enriched
GROUP BY
    pickup_borough,
    pickup_zone
ORDER BY total_trips DESC
LIMIT 20;


-- =========================================================
-- 4. Demand by borough
-- =========================================================

SELECT
    pickup_borough,
    COUNT(*) AS total_trips,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_trips
FROM trips_enriched
GROUP BY pickup_borough
ORDER BY total_trips DESC;


-- =========================================================
-- 5. Top 20 pickup-to-dropoff routes
-- =========================================================

SELECT
    pickup_zone || ' → ' || dropoff_zone AS route,
    pickup_borough,
    dropoff_borough,
    COUNT(*) AS total_trips
FROM trips_enriched
GROUP BY
    pickup_zone,
    dropoff_zone,
    pickup_borough,
    dropoff_borough
ORDER BY total_trips DESC
LIMIT 20;
