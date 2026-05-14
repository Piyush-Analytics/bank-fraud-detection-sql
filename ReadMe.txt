# 🏦 Bank Transaction Fraud Detection (PostgreSQL)

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![Queries](https://img.shields.io/badge/Queries-44+-green)

## 📌 Overview
End-to-end Bank Transaction Fraud Detection System built in PostgreSQL — 
analysing 1.2M+ credit card transactions to detect fraud patterns, 
high-risk customers, geographic anomalies and suspicious behaviour 
using 44+ SQL queries across 6 complexity levels.

## 🔍 Key Findings
- Overall fraud rate: ~0.58% of all transactions
- Night time (12AM–6AM) has highest fraud rate
- Shopping/misc categories show highest fraud counts
- Customers spending 3x their average flagged as high risk
- Rapid successive transactions (< 5 min gap) strong fraud indicator
- Geographic distance between customer and merchant correlates with fraud

## 📊 Query Categories (44+ Queries)

| Section | Type | Queries | Concepts Covered |
|---------|------|---------|-----------------|
| Section 1 | Basic Exploration | 1–8 | SELECT, GROUP BY, ORDER BY, LIMIT |
| Section 2 | Intermediate Analysis | 9–18 | HAVING, CASE WHEN, DATE functions, JOINs |
| Section 3 | Window Functions | 19–27 | ROW_NUMBER, RANK, LAG, LEAD, NTILE, PERCENT_RANK |
| Section 4 | CTEs & Subqueries | 28–34 | WITH, recursive CTEs, EXISTS, NOT EXISTS |
| Section 5 | Fraud Detection | 35–42 | Velocity checks, anomaly detection, risk scoring |
| Section 6 | Export | 43–44 | COPY TO, CSV export |

## 🚨 Fraud Detection Logic Built
- **Velocity Check** — flags 3+ transactions within same hour
- **Geographic Anomaly** — calculates distance between customer & merchant
- **Spending Anomaly** — flags transactions 3x above customer average
- **Risk Scorecard** — labels customers as HIGH/MEDIUM/LOW risk
- **Time Pattern Analysis** — night vs day, weekday vs weekend fraud rates
- **Rapid Transaction Detection** — flags < 5 minute gaps between transactions

## 🛠️ SQL Concepts Covered
| Concept | Queries Used |
|---------|-------------|
| Window Functions | ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, NTILE, PERCENT_RANK, CUME_DIST |
| CTEs | Simple CTEs, Multi-level CTEs, Recursive CTEs |
| Subqueries | Correlated, EXISTS, NOT EXISTS, Scalar |
| Aggregations | SUM, COUNT, AVG, MIN, MAX, STDDEV |
| Date Functions | DATE_PART, DATE_TRUNC, AGE, EXTRACT, TO_CHAR |
| String Functions | CONCAT (||), UPPER, LOWER |
| Math Functions | ROUND, NULLIF, CAST, DEGREES, ACOS, COS, SIN |
| Filtering | WHERE, HAVING, BETWEEN, IN, LIKE |
| Joins | Self JOIN, implicit JOIN |
| Export | COPY TO CSV |

## 📁 Project Structure




## 🚀 How to Run
1. Install PostgreSQL and pgAdmin
2. Create database: `bank_fraud_db`
3. Run `schema.sql` to create tables
4. Load data using COPY command
5. Run `fraud_detection_queries.sql` section by section

## 📂 Dataset
[Credit Card Fraud Detection — Kaggle](https://www.kaggle.com/datasets/kartik2112/fraud-detection)
- 1.2M+ transactions
- 23 columns
- Real fraud/non-fraud labels

## 💼 Resume Bullet Point
> "Built a Bank Transaction Fraud Detection system in PostgreSQL — 
> wrote 44+ queries across 6 complexity levels covering window functions, 
> recursive CTEs, correlated subqueries, geographic anomaly detection 
> and customer risk scoring on 1.2M+ transactions."