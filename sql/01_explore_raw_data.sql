-- NYC Taxi Trip Analytics
-- 01: Raw Data Exploration
-- Dataset: NYC Yellow Taxi Trip Records, January 2024

-- =========================================================
-- 1. Total raw records
-- =========================================================

SELECT
    COUNT(*) AS total_raw_trips
FROM read_parquet('data/raw/yellow_tripdata_2024-01.parquet');


-- =========================================================
-- 2. Date range
-- =========================================================

SELECT
    MIN(tpep_pickup_datetime) AS earliest_pickup,
    MAX(tpep_pickup_datetime) AS latest_pickup,
    MIN(tpep_dropoff_datetime) AS earliest_dropoff,
    MAX(tpep_dropoff_datetime) AS latest_dropoff
FROM read_parquet('data/raw/yellow_tripdata_2024-01.parquet');


-- =========================================================
-- 3. Basic trip metrics
-- =========================================================

SELECT
    COUNT(*) AS total_trips,
    ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
    ROUND(AVG(total_amount), 2) AS avg_total_amount,
    ROUND(AVG(passenger_count), 2) AS avg_passenger_count
FROM read_parquet('data/raw/yellow_tripdata_2024-01.parquet');


-- =========================================================
-- 4. Initial data-quality checks
-- =========================================================

SELECT
    SUM(CASE WHEN trip_distance <= 0 THEN 1 ELSE 0 END)
        AS non_positive_distance,

    SUM(CASE WHEN total_amount <= 0 THEN 1 ELSE 0 END)
        AS non_positive_total_amount,

    SUM(
        CASE
            WHEN tpep_dropoff_datetime <= tpep_pickup_datetime
            THEN 1 ELSE 0
        END
    ) AS invalid_trip_duration,

    SUM(CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END)
        AS missing_passenger_count,

    SUM(CASE WHEN PULocationID IS NULL THEN 1 ELSE 0 END)
        AS missing_pickup_zone,

    SUM(CASE WHEN DOLocationID IS NULL THEN 1 ELSE 0 END)
        AS missing_dropoff_zone

FROM read_parquet('data/raw/yellow_tripdata_2024-01.parquet');
