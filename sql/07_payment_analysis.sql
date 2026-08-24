-- NYC Taxi Trip Analytics
-- 07: Payment Method Analysis


-- =========================================================
-- 1. Payment method distribution
--
-- TLC Yellow Taxi payment_type:
-- 0 = Flex Fare trip
-- 1 = Credit card
-- 2 = Cash
-- 3 = No charge
-- 4 = Dispute
-- 5 = Unknown
-- 6 = Voided trip
-- =========================================================

WITH payment_data AS (
    SELECT
        CASE payment_type
            WHEN 0 THEN 'Flex Fare'
            WHEN 1 THEN 'Credit Card'
            WHEN 2 THEN 'Cash'
            WHEN 3 THEN 'No Charge'
            WHEN 4 THEN 'Dispute'
            WHEN 5 THEN 'Unknown'
            WHEN 6 THEN 'Voided Trip'
            ELSE 'Other'
        END AS payment_method,

        total_amount,
        fare_amount,
        tip_amount

    FROM trips_enriched
)

SELECT
    payment_method,
    COUNT(*) AS total_trips,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_trips

FROM payment_data
GROUP BY payment_method
ORDER BY total_trips DESC;


-- =========================================================
-- 2. Payment method financial metrics
-- =========================================================

WITH payment_data AS (
    SELECT
        CASE payment_type
            WHEN 0 THEN 'Flex Fare'
            WHEN 1 THEN 'Credit Card'
            WHEN 2 THEN 'Cash'
            WHEN 3 THEN 'No Charge'
            WHEN 4 THEN 'Dispute'
            WHEN 5 THEN 'Unknown'
            WHEN 6 THEN 'Voided Trip'
            ELSE 'Other'
        END AS payment_method,

        total_amount,
        fare_amount,
        tip_amount

    FROM trips_enriched
    WHERE valid_revenue = TRUE
)

SELECT
    payment_method,
    COUNT(*) AS total_trips,
    ROUND(SUM(total_amount), 2) AS gross_trip_amount,
    ROUND(AVG(total_amount), 2) AS avg_trip_amount,
    ROUND(AVG(tip_amount), 2) AS avg_tip_amount

FROM payment_data
GROUP BY payment_method
ORDER BY total_trips DESC;


-- =========================================================
-- 3. Credit-card tipping behavior
-- =========================================================

WITH credit_card_trips AS (
    SELECT
        tip_amount,
        total_amount,
        total_amount - tip_amount AS pre_tip_amount
    FROM trips_enriched
    WHERE
        payment_type = 1
        AND valid_revenue = TRUE
        AND total_amount - tip_amount > 0
)

SELECT
    COUNT(*) AS credit_card_trips,

    ROUND(AVG(tip_amount), 2) AS avg_tip_amount,

    ROUND(
        100.0 * SUM(tip_amount) / SUM(pre_tip_amount),
        2
    ) AS overall_tip_rate,

    ROUND(
        100.0 *
        COUNT(*) FILTER (WHERE tip_amount > 0)
        / COUNT(*),
        2
    ) AS pct_with_recorded_tip

FROM credit_card_trips;