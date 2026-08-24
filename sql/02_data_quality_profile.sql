-- NYC Taxi Trip Analytics
-- 02: Data Quality Profiling
-- Dataset: NYC Yellow Taxi Trip Records, January 2024

WITH trips AS (
    SELECT *
    FROM read_parquet('data/raw/yellow_tripdata_2024-01.parquet')
)

SELECT
    COUNT(*) AS total_raw_trips,

    -- Date validation
    COUNT(*) FILTER (
        WHERE tpep_pickup_datetime < TIMESTAMP '2024-01-01 00:00:00'
           OR tpep_pickup_datetime >= TIMESTAMP '2024-02-01 00:00:00'
    ) AS pickup_outside_january,

    -- Distance validation
    COUNT(*) FILTER (
        WHERE trip_distance <= 0
    ) AS non_positive_distance,

    COUNT(*) FILTER (
        WHERE trip_distance > 100
    ) AS distance_over_100_miles,

    -- Financial validation
    COUNT(*) FILTER (
        WHERE total_amount <= 0
    ) AS non_positive_total_amount,

    COUNT(*) FILTER (
        WHERE fare_amount < 0
    ) AS negative_fare_amount,

    -- Duration validation
    COUNT(*) FILTER (
        WHERE tpep_dropoff_datetime <= tpep_pickup_datetime
    ) AS invalid_duration,

    COUNT(*) FILTER (
        WHERE tpep_dropoff_datetime - tpep_pickup_datetime
              > INTERVAL '24 hours'
    ) AS duration_over_24_hours,

    -- Passenger validation
    COUNT(*) FILTER (
        WHERE passenger_count IS NULL
    ) AS missing_passenger_count,

    COUNT(*) FILTER (
        WHERE passenger_count = 0
    ) AS zero_passenger_count,

    COUNT(*) FILTER (
        WHERE passenger_count > 6
    ) AS passenger_count_over_6,

    -- Location validation
    COUNT(*) FILTER (
        WHERE PULocationID IS NULL
    ) AS missing_pickup_location,

    COUNT(*) FILTER (
        WHERE DOLocationID IS NULL
    ) AS missing_dropoff_location

FROM trips;
