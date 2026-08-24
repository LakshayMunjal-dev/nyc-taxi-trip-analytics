-- NYC Taxi Trip Analytics
-- 08: Trip Distance Analysis
--
-- Uses trips with positive, non-extreme distance.
-- Distances above 100 miles were previously flagged for separate review.


-- =========================================================
-- 1. Overall distance metrics
-- =========================================================

SELECT
    COUNT(*) AS distance_valid_trips,
    ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_trip_distance,
    ROUND(MIN(trip_distance), 2) AS min_trip_distance,
    ROUND(MAX(trip_distance), 2) AS max_trip_distance
FROM trips_enriched
WHERE
    valid_distance = TRUE
    AND extreme_distance_flag = FALSE;


-- =========================================================
-- 2. Trip-distance distribution
-- =========================================================

WITH distance_buckets AS (
    SELECT
        CASE
            WHEN trip_distance < 1 THEN '< 1 mile'
            WHEN trip_distance < 2 THEN '1–2 miles'
            WHEN trip_distance < 3 THEN '2–3 miles'
            WHEN trip_distance < 5 THEN '3–5 miles'
            WHEN trip_distance < 10 THEN '5–10 miles'
            WHEN trip_distance < 20 THEN '10–20 miles'
            ELSE '20–100 miles'
        END AS distance_bucket,

        CASE
            WHEN trip_distance < 1 THEN 1
            WHEN trip_distance < 2 THEN 2
            WHEN trip_distance < 3 THEN 3
            WHEN trip_distance < 5 THEN 4
            WHEN trip_distance < 10 THEN 5
            WHEN trip_distance < 20 THEN 6
            ELSE 7
        END AS bucket_order

    FROM trips_enriched
    WHERE
        valid_distance = TRUE
        AND extreme_distance_flag = FALSE
)

SELECT
    distance_bucket,
    COUNT(*) AS total_trips,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_trips
FROM distance_buckets
GROUP BY
    distance_bucket,
    bucket_order
ORDER BY bucket_order;


-- =========================================================
-- 3. Distance vs trip amount
-- =========================================================

WITH distance_buckets AS (
    SELECT
        CASE
            WHEN trip_distance < 1 THEN '< 1 mile'
            WHEN trip_distance < 2 THEN '1–2 miles'
            WHEN trip_distance < 3 THEN '2–3 miles'
            WHEN trip_distance < 5 THEN '3–5 miles'
            WHEN trip_distance < 10 THEN '5–10 miles'
            WHEN trip_distance < 20 THEN '10–20 miles'
            ELSE '20–100 miles'
        END AS distance_bucket,

        CASE
            WHEN trip_distance < 1 THEN 1
            WHEN trip_distance < 2 THEN 2
            WHEN trip_distance < 3 THEN 3
            WHEN trip_distance < 5 THEN 4
            WHEN trip_distance < 10 THEN 5
            WHEN trip_distance < 20 THEN 6
            ELSE 7
        END AS bucket_order,

        trip_distance,
        total_amount

    FROM trips_enriched
    WHERE
        valid_distance = TRUE
        AND extreme_distance_flag = FALSE
        AND valid_revenue = TRUE
)

SELECT
    distance_bucket,
    COUNT(*) AS total_trips,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(total_amount), 2) AS avg_trip_amount,
    ROUND(SUM(total_amount), 2) AS gross_trip_amount
FROM distance_buckets
GROUP BY
    distance_bucket,
    bucket_order
ORDER BY bucket_order;


-- =========================================================
-- 4. Average trip distance by pickup borough
-- =========================================================

SELECT
    pickup_borough,
    COUNT(*) AS total_trips,
    ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_trip_distance
FROM trips_enriched
WHERE
    valid_distance = TRUE
    AND extreme_distance_flag = FALSE
GROUP BY pickup_borough
ORDER BY avg_trip_distance DESC;


-- =========================================================
-- 5. Airport vs non-airport trip comparison
-- =========================================================

SELECT
    CASE
        WHEN pickup_zone IN ('JFK Airport', 'LaGuardia Airport')
            THEN 'Airport Pickup'
        ELSE 'Non-Airport Pickup'
    END AS pickup_type,

    COUNT(*) AS total_trips,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_distance,
    ROUND(AVG(total_amount), 2) AS avg_trip_amount

FROM trips_enriched

WHERE
    valid_distance = TRUE
    AND extreme_distance_flag = FALSE
    AND valid_revenue = TRUE

GROUP BY pickup_type
ORDER BY avg_distance DESC;
