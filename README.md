# ChurnWatch — Customer Churn Risk Analytics System

## Overview

ChurnWatch is an end-to-end customer churn analytics system built as part of a data analytics internship project. The system ingests raw telecom customer data, processes it through a relational database layer, applies a custom weighted risk-scoring model to flag customers likely to churn, and presents the findings through an interactive Power BI dashboard. The goal of this project is to demonstrate a complete analytics workflow — from raw data to actionable business insight — using tools commonly found in real-world data teams: SQL for data modeling and transformation, and Power BI for visualization and reporting.

Customer churn is one of the most costly problems for subscription-based businesses like telecom providers, where acquiring a new customer is significantly more expensive than retaining an existing one. ChurnWatch addresses this by not just reporting historical churn, but by scoring *current* customers on their risk of churning, so that retention efforts can be prioritized proactively rather than reactively.

## Data Source

This project uses the **Telco Customer Churn dataset** from Kaggle: [https://www.kaggle.com/datasets/blastchar/telco-customer-churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)

The dataset contains records for approximately **7,043 customers** of a fictional telecom company, with **21 attributes** per customer, including:

- **Demographics:** gender, senior citizen status, partner, dependents
- **Account information:** tenure (months with company), contract type, paperless billing, payment method
- **Services subscribed:** phone service, multiple lines, internet service, online security, online backup, device protection, tech support, streaming TV, streaming movies
- **Billing:** monthly charges, total charges
- **Target variable:** churn (Yes/No)

## Tech Stack

| Layer | Tool |
|---|---|
| Database Engine | MariaDB (bundled with XAMPP) |
| Database Administration | phpMyAdmin |
| Data Source | Excel (.xlsx) / CSV |
| Data Modeling & Scoring Logic | SQL (views, CASE-based weighted scoring) |
| Visualization | Microsoft Power BI Desktop |
| Connection Method | ODBC (MySQL ODBC Connector) |
| Version Control | Git & GitHub |

## Pipeline / Methodology

**1. Data Import**
The raw Telco Customer Churn dataset (originally in Excel format) was cleaned and imported into a MariaDB database (`churnwatch`) running locally via XAMPP, using phpMyAdmin's import functionality. The data was loaded into a base `customers` table matching the original schema.

**2. Data Cleaning**
Several data quality issues in the raw dataset were identified and resolved at the SQL level:
- The `TotalCharges` column contained blank string values for customers with zero tenure (new customers who haven't been billed yet). These were converted to proper NULL values and the column was re-typed from text to a numeric DECIMAL type.
- Column types were validated and corrected across the table (e.g., ensuring `SeniorCitizen` is treated as a flag, `tenure` as an integer, etc.).

**3. SQL Layer — KPIs and Risk Scoring**
A set of SQL views was built on top of the cleaned `customers` table to support analysis:
- **`vw_churn_kpis`** — aggregates high-level metrics: total customers, churned customers, retained customers, and overall churn rate.
- **`final_customer_risk`** — a custom weighted risk-scoring view that calculates a **risk score (0–100)** per customer based on four weighted risk factors:
  - **Tenure risk** — customers with shorter tenure are scored as higher risk, since new customers are statistically more likely to churn.
  - **Contract risk** — month-to-month contract customers are scored higher risk than one-year or two-year contract customers, who have more commitment and switching cost.
  - **Payment risk** — payment method is factored in, since certain payment types (e.g., electronic check) correlate with higher churn in this dataset.
  - **Charge risk** — customers with higher monthly charges relative to their tenure/usage are scored as at greater risk of price-sensitivity-driven churn.
  
  These four sub-scores are combined into a single overall `risk_score`, which is then bucketed into a categorical `risk_band` (**Critical / High / Medium / Low**) to make prioritization straightforward for a business audience.

**4. Power BI Dashboard**
Power BI Desktop was connected directly to the live MariaDB database using an ODBC System DSN (rather than a static export), meaning the dashboard reflects the database in near real-time and can be refreshed on demand. All visuals are built directly on top of the SQL views described above rather than raw table calculations, keeping the business logic centralized in SQL and the dashboard focused on presentation.

## Dashboard Pages

**1. Overview**
A high-level executive summary page showing total customer count, number of churned vs. retained customers, and overall churn rate as KPI cards, alongside a churn split donut chart and a breakdown of churn by contract type. This page answers: *"How big is our churn problem right now?"*

**2. Risk Analysis**
A detailed, filterable table listing individual customers with their risk score, risk band, contract type, tenure, and monthly charges — with conditional (color-coded) formatting on the risk score column and a slicer to isolate Critical/High risk segments. This page answers: *"Which specific customers should we act on first?"*

**3. Risk Drivers**
A diagnostic page comparing the average contribution of each of the four risk factors (tenure, contract, payment method, charges) to the overall risk score, alongside a scatter plot of risk score against tenure (colored by churn status) to visualize how risk concentrates among newer customers. This page answers: *"Why are customers at risk — what's driving it?"*

**4. Segmentation**
A breakdown of churn rates by internet service type and payment method, using stacked bar charts to show which customer segments churn most disproportionately. This page answers: *"Which customer segments need the most attention?"*

## Key Insights (fill in with your actual numbers before submitting)

- Overall churn rate across the customer base: **[insert %]**
- Month-to-month contract customers churn at a significantly higher rate than one/two-year contract customers.
- Customers using Electronic Check as a payment method show elevated churn compared to automatic payment methods.
- Fiber optic internet service customers show a higher churn share than DSL customers.
- The majority of "Critical" risk-band customers are concentrated in the low-tenure, month-to-month segment.

## Screenshots

Dashboard screenshots for all four pages are included in this `docs/` folder:
- `overview.png`
- `risk_analysis.png`
- `risk_drivers.png`
- `segmentation.png`

## Project Structure

ChurnWatch/
├── sql/ # SQL scripts, run in order
│ ├── 01_schema.sql
│ ├── 02_clean_data.sql
│ ├── 03_kpi_queries.sql
│ └── 04_risk_score_view.sql
├── data/ # Original Telco Customer Churn dataset
├── powerbi/ # ChurnWatch.pbix dashboard file
└── docs/ # README and dashboard screenshots

## How to Reproduce

1. Import the dataset from `data/` into a MariaDB/MySQL database using phpMyAdmin.
2. Run the SQL scripts in `sql/` in numbered order to recreate the schema, clean the data, and build the KPI and risk-scoring views.
3. Open `powerbi/ChurnWatch.pbix` in Power BI Desktop and connect it to your local database via ODBC (Server: `127.0.0.1:3306`, Database: `churnwatch`).
4. Refresh the data to load the latest results.

## Future Improvements

- Incorporate a machine learning classification model (e.g., logistic regression or random forest) to validate and potentially improve on the rule-based risk score.
- Add time-series churn tracking if longitudinal data becomes available, rather than the current point-in-time snapshot.
- Automate the SQL-to-dashboard refresh pipeline using a scheduled job.