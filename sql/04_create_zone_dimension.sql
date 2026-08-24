-- NYC Taxi Trip Analytics
-- 04: Taxi Zone Dimension
--
-- Creates a reusable dimension table from the
-- official NYC TLC Taxi Zone lookup.

CREATE OR REPLACE TABLE dim_zone AS

SELECT
    LocationID AS location_id,
    Borough AS borough,
    Zone AS zone,
    service_zone
FROM read_csv_auto(
    'data/reference/taxi_zone_lookup.csv'
);


-- Enriched trip view with readable pickup/dropoff locations

CREATE OR REPLACE VIEW trips_enriched AS

SELECT
    f.*,

    pu.borough AS pickup_borough,
    pu.zone AS pickup_zone,
    pu.service_zone AS pickup_service_zone,

    dz.borough AS dropoff_borough,
    dz.zone AS dropoff_zone,
    dz.service_zone AS dropoff_service_zone

FROM fact_trips f

LEFT JOIN dim_zone pu
    ON f.pickup_location_id = pu.location_id

LEFT JOIN dim_zone dz
    ON f.dropoff_location_id = dz.location_id;
