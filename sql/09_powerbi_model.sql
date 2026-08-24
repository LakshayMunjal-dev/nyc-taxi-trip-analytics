-- NYC Taxi Trip Analytics
-- 09: Power BI Semantic Model
--
-- Creates clean dimension and fact views/tables
-- for downstream dashboarding.


-- =========================================================
-- 1. Date Dimension
-- =========================================================

CREATE OR REPLACE TABLE dim_date AS

SELECT DISTINCT
    pickup_date AS date,
    EXTRACT(YEAR FROM pickup_date) AS year,
    EXTRACT(MONTH FROM pickup_date) AS month_number,
    STRFTIME(pickup_date, '%B') AS month_name,
    EXTRACT(DAY FROM pickup_date) AS day_of_month,
    EXTRACT(DOW FROM pickup_date) AS day_of_week_number,
    STRFTIME(pickup_date, '%A') AS day_name,

    CASE
        WHEN EXTRACT(DOW FROM pickup_date) IN (0, 6)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type

FROM fact_trips

ORDER BY date;


-- =========================================================
-- 2. Payment Dimension
-- =========================================================

CREATE OR REPLACE TABLE dim_payment AS

SELECT * FROM (
    VALUES
        (0, 'Flex Fare'),
        (1, 'Credit Card'),
        (2, 'Cash'),
        (3, 'No Charge'),
        (4, 'Dispute'),
        (5, 'Unknown'),
        (6, 'Voided Trip')
) AS p(payment_type, payment_method);


-- =========================================================
-- 3. Pickup Zone Dimension
-- =========================================================

CREATE OR REPLACE TABLE dim_pickup_zone AS

SELECT
    location_id AS pickup_location_id,
    borough AS pickup_borough,
    zone AS pickup_zone,
    service_zone AS pickup_service_zone
FROM dim_zone;


-- =========================================================
-- 4. Dropoff Zone Dimension
-- =========================================================

CREATE OR REPLACE TABLE dim_dropoff_zone AS

SELECT
    location_id AS dropoff_location_id,
    borough AS dropoff_borough,
    zone AS dropoff_zone,
    service_zone AS dropoff_service_zone
FROM dim_zone;

-- =========================================================
-- 5. Dashboard Fact View
-- =========================================================

CREATE OR REPLACE VIEW fact_trip_analytics AS

SELECT
    ROW_NUMBER() OVER () AS trip_id,

    pickup_date,

    pickup_datetime,
    dropoff_datetime,

    pickup_hour,
    pickup_day_of_week,

    pickup_location_id,
    dropoff_location_id,

    payment_type,

    passenger_count,
    trip_distance,
    trip_duration_minutes,

    fare_amount,
    tip_amount,
    tolls_amount,
    total_amount,

    valid_distance,
    valid_revenue,
    valid_passenger_count,
    extreme_distance_flag

FROM fact_trips;
