-- NYC Taxi Trip Analytics
-- 06: Revenue / Gross Trip Amount Analysis
--
-- Gross Trip Amount:
-- Sum of positive total_amount values for analytically valid trips.


-- =========================================================
-- 1. Overall financial KPIs
-- =========================================================

SELECT
    COUNT(*) AS revenue_valid_trips,
    ROUND(SUM(total_amount), 2) AS gross_trip_amount,
    ROUND(AVG(total_amount), 2) AS avg_total_amount,
    ROUND(AVG(fare_amount), 2) AS avg_fare_amount,
    ROUND(AVG(tip_amount), 2) AS avg_tip_amount
FROM trips_enriched
WHERE valid_revenue = TRUE;


-- =========================================================
-- 2. Gross trip amount by pickup date
-- =========================================================

SELECT
    pickup_date,
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS gross_trip_amount,
    ROUND(AVG(total_amount), 2) AS avg_trip_amount
FROM trips_enriched
WHERE valid_revenue = TRUE
GROUP BY pickup_date
ORDER BY pickup_date;


-- =========================================================
-- 3. Revenue by pickup hour
-- =========================================================

SELECT
    pickup_hour,
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS gross_trip_amount,
    ROUND(AVG(total_amount), 2) AS avg_trip_amount
FROM trips_enriched
WHERE valid_revenue = TRUE
GROUP BY pickup_hour
ORDER BY gross_trip_amount DESC;


-- =========================================================
-- 4. Top pickup zones by gross trip amount
-- =========================================================

SELECT
    pickup_borough,
    pickup_zone,
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS gross_trip_amount,
    ROUND(AVG(total_amount), 2) AS avg_trip_amount
FROM trips_enriched
WHERE valid_revenue = TRUE
GROUP BY
    pickup_borough,
    pickup_zone
ORDER BY gross_trip_amount DESC
LIMIT 20;


-- =========================================================
-- 5. Gross trip amount by borough
-- =========================================================

SELECT
    pickup_borough,
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS gross_trip_amount,
    ROUND(
        100.0 * SUM(total_amount)
        / SUM(SUM(total_amount)) OVER (),
        2
    ) AS pct_of_gross_amount,
    ROUND(AVG(total_amount), 2) AS avg_trip_amount
FROM trips_enriched
WHERE valid_revenue = TRUE
GROUP BY pickup_borough
ORDER BY gross_trip_amount DESC;
