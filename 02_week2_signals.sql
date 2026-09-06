-- ==========================================
-- CHURNWATCH - WEEK 2
-- CHURN SIGNAL ANALYSIS
-- ==========================================

USE churnwatch;
# Create ONE simple view
CREATE OR REPLACE VIEW customer_signals AS

SELECT
    customer_id,
    tenure,
    contract,
    monthly_charges,
    payment_method,
    churn,

    CASE
        WHEN contract = 'Month-to-month'
        THEN 3
        ELSE 1
    END AS contract_risk,

    CASE
        WHEN tenure <= 3
        THEN 3
        WHEN tenure <= 6
        THEN 2
        ELSE 1
    END AS tenure_risk,

    CASE
        WHEN monthly_charges > 80
        THEN 3
        WHEN monthly_charges >= 60
        THEN 2
        ELSE 1
    END AS charge_risk,

    CASE
        WHEN payment_method = 'Electronic check'
        THEN 3
        ELSE 1
    END AS payment_risk

FROM customers
WHERE customer_id IS NOT NULL;

SELECT *
FROM customer_signals
LIMIT 10;

--Calculate the signal score
SELECT
    *,
    
    contract_risk +
    tenure_risk +
    charge_risk +
    payment_risk AS signal_score

FROM customer_signals
LIMIT 20;

--Create risk levels
SELECT
    *,
    
    contract_risk +
    tenure_risk +
    charge_risk +
    payment_risk AS signal_score,

    CASE
        WHEN contract_risk +
             tenure_risk +
             charge_risk +
             payment_risk >= 11
            THEN 'Critical'

        WHEN contract_risk +
             tenure_risk +
             charge_risk +
             payment_risk >= 8
            THEN 'High'

        WHEN contract_risk +
             tenure_risk +
             charge_risk +
             payment_risk >= 5
            THEN 'Medium'

        ELSE 'Low'
    END AS risk_band

FROM customer_signals
LIMIT 20;

--final Week 2 view
CREATE OR REPLACE VIEW customer_risk AS

SELECT
    *,
    
    contract_risk +
    tenure_risk +
    charge_risk +
    payment_risk AS risk_score,

    CASE
        WHEN contract_risk +
             tenure_risk +
             charge_risk +
             payment_risk >= 11
            THEN 'Critical'

        WHEN contract_risk +
             tenure_risk +
             charge_risk +
             payment_risk >= 8
            THEN 'High'

        WHEN contract_risk +
             tenure_risk +
             charge_risk +
             payment_risk >= 5
            THEN 'Medium'

        ELSE 'Low'
    END AS risk_band

FROM customer_signals;

SELECT *
FROM customer_risk
LIMIT 20;

--how many customers are in each risk level
SELECT
    risk_band,
    COUNT(*) AS customers
FROM customer_risk
GROUP BY risk_band
ORDER BY
    CASE risk_band
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END;

--Check whether our risk score makes sense
SELECT
    risk_band,

    COUNT(*) AS customers,

    SUM(churn = 'Yes') AS churned,

    ROUND(
        100 * SUM(churn = 'Yes') / COUNT(*),
        2
    ) AS churn_rate

FROM customer_risk

GROUP BY risk_band

ORDER BY
    CASE risk_band
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END;

--Add one simple retention action
SELECT
    *,
    
    CASE
        WHEN risk_band = 'Critical'
            THEN 'Immediate customer call'

        WHEN risk_band = 'High'
            THEN 'Contact customer within 2 days'

        WHEN risk_band = 'Medium'
            THEN 'Send retention offer'

        ELSE
            'Regular monitoring'
    END AS recommended_action

FROM customer_risk
LIMIT 20;
