-- NYC Taxi Trip Analytics
-- 03: Create Analytics View
--
-- Strategy:
-- Remove only records that are clearly invalid for January 2024 analysis.
-- Preserve questionable values and expose quality flags so individual
-- analyses can apply the appropriate filters.

CREATE OR REPLACE VIEW fact_trips AS

SELECT
    -- Original fields
    VendorID AS vendor_id,
    tpep_pickup_datetime AS pickup_datetime,
    tpep_dropoff_datetime AS dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID AS rate_code_id,
    store_and_fwd_flag,
    PULocationID AS pickup_location_id,
    DOLocationID AS dropoff_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    Airport_fee AS airport_fee,

    -- Derived date/time fields
    CAST(tpep_pickup_datetime AS DATE) AS pickup_date,
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    EXTRACT(DOW FROM tpep_pickup_datetime) AS pickup_day_of_week,

    -- Trip duration
    DATE_DIFF(
        'minute',
        tpep_pickup_datetime,
        tpep_dropoff_datetime
    ) AS trip_duration_minutes,

    -- Quality flags
    CASE
        WHEN trip_distance > 0
        THEN TRUE
        ELSE FALSE
    END AS valid_distance,

    CASE
        WHEN total_amount > 0
        THEN TRUE
        ELSE FALSE
    END AS valid_revenue,

    CASE
        WHEN passenger_count IS NOT NULL
             AND passenger_count BETWEEN 1 AND 6
        THEN TRUE
        ELSE FALSE
    END AS valid_passenger_count,

    CASE
        WHEN trip_distance > 100
        THEN TRUE
        ELSE FALSE
    END AS extreme_distance_flag

FROM read_parquet(
    'data/raw/yellow_tripdata_2024-01.parquet'
)

WHERE
    -- Analyze trips that actually began in January 2024
    tpep_pickup_datetime >= TIMESTAMP '2024-01-01 00:00:00'
    AND tpep_pickup_datetime < TIMESTAMP '2024-02-01 00:00:00'

    -- Trip must have positive duration
    AND tpep_dropoff_datetime > tpep_pickup_datetime

    -- Exclude implausibly long trips
    AND tpep_dropoff_datetime - tpep_pickup_datetime
        <= INTERVAL '24 hours';
