-- ==========================================
-- CHURNWATCH - WEEK 3
-- FINAL CHURN RISK SCORING
-- ==========================================

USE churnwatch;
--Create the final risk view
CREATE OR REPLACE VIEW churn_risk AS

SELECT
    customer_id,
    tenure,
    tenure_group,
    contract,
    monthly_charges,
    payment_method,
    churn,

    contract_risk,
    tenure_risk,
    charge_risk,
    payment_risk,

    -- Original score
    (
        contract_risk +
        tenure_risk +
        charge_risk +
        payment_risk
    ) AS signal_score,

    -- Convert to 0-100
    ROUND(
        100.0 *
        (
            contract_risk +
            tenure_risk +
            charge_risk +
            payment_risk
        ) / 12,
        2
    ) AS risk_score

FROM customer_signals;
--Check your score
SELECT *
FROM churn_risk
LIMIT 20;
--Create risk bands
CREATE OR REPLACE VIEW final_customer_risk AS

SELECT
    *,

    CASE
        WHEN risk_score >= 80
            THEN 'Critical'

        WHEN risk_score >= 60
            THEN 'High'

        WHEN risk_score >= 30
            THEN 'Medium'

        ELSE 'Low'
    END AS risk_band

FROM churn_risk;
--check your risk bands
SELECT
    customer_id,
    risk_score,
    risk_band,
    churn
FROM final_customer_risk
LIMIT 20;
--Count customers by risk
SELECT
    risk_band,
    COUNT(*) AS customers
FROM final_customer_risk
GROUP BY risk_band
ORDER BY
    CASE risk_band
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END;
--Calculate actual churn for each risk group
SELECT
    risk_band,

    COUNT(*) AS customers,

    SUM(churn = 'Yes') AS churned_customers,

    ROUND(
        100.0 * SUM(churn = 'Yes') / COUNT(*),
        2
    ) AS actual_churn_rate

FROM final_customer_risk

GROUP BY risk_band

ORDER BY
    CASE risk_band
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END;
--Calculate Revenue at Risk
SELECT
    customer_id,
    monthly_charges,
    risk_score,

    ROUND(
        monthly_charges * risk_score / 100,
        2
    ) AS revenue_at_risk

FROM final_customer_risk

ORDER BY revenue_at_risk DESC;
--Create the final business view
CREATE OR REPLACE VIEW churnwatch_final AS

SELECT

    customer_id,

    tenure,

    tenure_group,

    contract,

    monthly_charges,

    payment_method,

    churn,

    contract_risk,

    tenure_risk,

    charge_risk,

    payment_risk,

    ROUND(
        100.0 *
        (
            contract_risk +
            tenure_risk +
            charge_risk +
            payment_risk
        ) / 12,
        2
    ) AS risk_score,

    CASE

        WHEN (
            contract_risk +
            tenure_risk +
            charge_risk +
            payment_risk
        ) * 100.0 / 12 >= 80

            THEN 'Critical'

        WHEN (
            contract_risk +
            tenure_risk +
            charge_risk +
            payment_risk
        ) * 100.0 / 12 >= 60

            THEN 'High'

        WHEN (
            contract_risk +
            tenure_risk +
            charge_risk +
            payment_risk
        ) * 100.0 / 12 >= 30

            THEN 'Medium'

        ELSE 'Low'

    END AS risk_band,

    ROUND(
        monthly_charges *
        (
            contract_risk +
            tenure_risk +
            charge_risk +
            payment_risk
        ) / 12,
        2
    ) AS revenue_at_risk,

    CASE

        WHEN (
            contract_risk +
            tenure_risk +
            charge_risk +
            payment_risk
        ) * 100.0 / 12 >= 80

            THEN 'Immediate retention call'

        WHEN (
            contract_risk +
            tenure_risk +
            charge_risk +
            payment_risk
        ) * 100.0 / 12 >= 60

            THEN 'Contact within 2 days'

        WHEN (
            contract_risk +
            tenure_risk +
            charge_risk +
            payment_risk
        ) * 100.0 / 12 >= 30

            THEN 'Send retention offer'

        ELSE 'Regular monitoring'

    END AS recommended_action

FROM customer_signals;
--Check your FINAL ChurnWatch table
SELECT *
FROM churnwatch_final
LIMIT 20;
--Find the top 20 customers to save
SELECT
    customer_id,
    contract,
    tenure,
    monthly_charges,
    risk_score,
    risk_band,
    revenue_at_risk,
    recommended_action

FROM churnwatch_final

WHERE risk_band IN ('Critical', 'High')

ORDER BY revenue_at_risk DESC

LIMIT 20;
--Calculate total revenue at risk
SELECT
    ROUND(
        SUM(revenue_at_risk),
        2
    ) AS total_revenue_at_risk

FROM churnwatch_final
WHERE risk_band IN ('High', 'Critical');
--Calculate revenue at risk by band
SELECT
    risk_band,

    COUNT(*) AS customers,

    ROUND(
        SUM(revenue_at_risk),
        2
    ) AS revenue_at_risk

FROM churnwatch_final

GROUP BY risk_band

ORDER BY
    CASE risk_band
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END;

