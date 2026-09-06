-- =====================================================
-- CHURNWATCH
-- WEEK 1: DATA VALIDATION & BASELINE METRICS
-- =====================================================
USE churnwatch;
-- 1. Check total rows
SELECT COUNT(*) AS total_rows
FROM customers;
-- 2. Count unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM customers;
-- 3. Check missing customer IDs
SELECT COUNT(*) AS missing_customer_ids
FROM customers
WHERE customer_id IS NULL
   OR TRIM(customer_id) = '';
   -- 4. Check missing and zero total charges
SELECT
    SUM(total_charges IS NULL) AS missing_total_charges,
    SUM(total_charges = 0) AS zero_total_charges
FROM customers;
-- 5. Churn distribution
SELECT
    churn,
    COUNT(*) AS customer_count
FROM customers
GROUP BY churn;
-- 6. Overall churn KPI
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN churn = 'Yes'
        THEN customer_id
    END) AS churned_customers,

    COUNT(DISTINCT CASE
        WHEN churn = 'No'
        THEN customer_id
    END) AS retained_customers,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN churn = 'Yes'
            THEN customer_id
        END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate

FROM customers;
-- 7. Churn by contract
SELECT
    contract,

    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN churn = 'Yes'
        THEN customer_id
    END) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN churn = 'Yes'
            THEN customer_id
        END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate

FROM customers

GROUP BY contract

ORDER BY churn_rate DESC;
-- 8. Churn by tenure
SELECT

    CASE
        WHEN tenure <= 3
            THEN '0-3 Months'

        WHEN tenure <= 6
            THEN '4-6 Months'

        WHEN tenure <= 12
            THEN '7-12 Months'

        WHEN tenure <= 24
            THEN '13-24 Months'

        ELSE '25+ Months'
    END AS tenure_group,

    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN churn = 'Yes'
        THEN customer_id
    END) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN churn = 'Yes'
            THEN customer_id
        END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate

FROM customers

GROUP BY tenure_group

ORDER BY churn_rate DESC;
-- 9. Churn by payment method
SELECT

    payment_method,

    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN churn = 'Yes'
        THEN customer_id
    END) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN churn = 'Yes'
            THEN customer_id
        END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate

FROM customers

GROUP BY payment_method

ORDER BY churn_rate DESC;
-- 10. Churn by Internet Service
SELECT

    internet_service,

    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN churn = 'Yes'
        THEN customer_id
    END) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN churn = 'Yes'
        THEN customer_id
        END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate

FROM customers

GROUP BY internet_service

ORDER BY churn_rate DESC;
-- 11. Churn by senior citizen
SELECT

    senior_citizen,

    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN churn = 'Yes'
        THEN customer_id
    END) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN churn = 'Yes'
            THEN customer_id
        END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate

FROM customers

GROUP BY senior_citizen

ORDER BY churn_rate DESC;
