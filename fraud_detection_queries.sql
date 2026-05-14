CREATE TABLE transactions_staging (
    idx             INTEGER,
    trans_date_time TIMESTAMP,
    cc_num          BIGINT,
    merchant        VARCHAR(200),
    category        VARCHAR(100),
    amt             DECIMAL(10,2),
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    gender          VARCHAR(10),
    street          VARCHAR(200),
    city            VARCHAR(100),
    state           VARCHAR(50),
    zip             VARCHAR(20),
    lat             DECIMAL(10,6),
    long            DECIMAL(10,6),
    city_pop        INTEGER,
    job             VARCHAR(200),
    dob             DATE,
    trans_num       VARCHAR(100),
    unix_time       BIGINT,
	merch_lat       DECIMAL(10,6),
    merch_long      DECIMAL(10,6),
    is_fraud        INTEGER
);

SELECT *FROM transactions_staging;

COPY transactions_staging
FROM 'C:/temp/fraudTrain.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO transactions (
    trans_date_time, cc_num, merchant, category, amt,
    first_name, last_name, gender, street, city, state,
    zip, lat, long, city_pop, job, dob, trans_num,
    unix_time, merch_lat, merch_long, is_fraud
)
SELECT 
    trans_date_time, cc_num, merchant, category, amt,
    first_name, last_name, gender, street, city, state,
    zip, lat, long, city_pop, job, dob, trans_num,
    unix_time, merch_lat, merch_long, is_fraud
FROM transactions_staging;

SELECT COUNT(*) AS total_rows FROM transactions;


SELECT *FROM transactions_staging;

-- Query 1: Total transactions and fraud overview

SELECT 
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_fraud,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM transactions;

-- Query 2: First look at data
SELECT * FROM transactions LIMIT 50;

-- Query 3: Total transaction amount
SELECT 
    ROUND(SUM(amt), 2) AS total_amount,
    ROUND(AVG(amt), 2) AS avg_amount,
    ROUND(MIN(amt), 2) AS min_amount,
    ROUND(MAX(amt), 2) AS max_amount
FROM transactions;

-- Query 4: Transaction count by gender
SELECT 
    gender,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY gender
ORDER BY fraud_rate_pct DESC;


-- Query 5: Top 10 merchants by transaction count
SELECT 
    merchant,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amt), 2) AS total_amount
FROM transactions
GROUP BY merchant
ORDER BY total_transactions DESC
LIMIT 10;


-- Query 6: Transaction count by category
SELECT 
    category,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amt), 2) AS total_amount,
    SUM(is_fraud) AS fraud_count
FROM transactions
GROUP BY category
ORDER BY total_transactions DESC;

-- Query 7: Top 10 states by transaction volume
SELECT 
    state,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amt), 2) AS total_amount
FROM transactions
GROUP BY state
ORDER BY total_transactions DESC
LIMIT 10;

-- Query 8: Daily transaction count
SELECT 
    DATE(trans_date_time) AS trans_date,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amt), 2) AS total_amount,
    SUM(is_fraud) AS fraud_count
FROM transactions
GROUP BY trans_date
ORDER BY trans_date;



-- SECTION 2: INTERMEDIATE ANALYSIS


-- Query 9: Fraud rate by category
SELECT 
    category,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS fraud_amount
FROM transactions
GROUP BY category
ORDER BY fraud_rate_pct DESC;


-- Query 10: High value fraud transactions (above $500)
SELECT 
    trans_num,
    first_name || ' ' || last_name AS customer_name,
    merchant,
    category,
    amt,
    trans_date_time
FROM transactions
WHERE is_fraud = 1 AND amt > 500
ORDER BY amt DESC
LIMIT 20;

-- Query 11: Customer age calculation and fraud by age group
SELECT 
    CASE 
        WHEN DATE_PART('year', AGE(dob)) < 25 THEN 'Under 25'
        WHEN DATE_PART('year', AGE(dob)) BETWEEN 25 AND 35 THEN '25-35'
        WHEN DATE_PART('year', AGE(dob)) BETWEEN 36 AND 45 THEN '36-45'
        WHEN DATE_PART('year', AGE(dob)) BETWEEN 46 AND 60 THEN '46-60'
        ELSE 'Over 60'
    END AS age_group,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY age_group
ORDER BY fraud_rate_pct DESC;

-- Query 12: Hourly fraud pattern
SELECT 
    DATE_PART('hour', trans_date_time) AS hour_of_day,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY hour_of_day
ORDER BY fraud_rate_pct DESC;

-- Query 13: Monthly fraud trend
SELECT 
    DATE_TRUNC('month', trans_date_time) AS month,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(amt), 2) AS total_amount,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS fraud_amount
FROM transactions
GROUP BY month
ORDER BY month;

-- Query 14: Top 10 fraud merchants
SELECT 
    merchant,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS fraud_amount
FROM transactions
GROUP BY merchant
HAVING SUM(is_fraud) > 5
ORDER BY fraud_rate_pct DESC
LIMIT 10;

-- Query 15: Fraud by day of week
SELECT 
    TO_CHAR(trans_date_time, 'Day') AS day_of_week,
    DATE_PART('dow', trans_date_time) AS day_num,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY day_of_week, day_num
ORDER BY day_num;

-- Query 16: High risk cities
SELECT 
    city,
    state,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY city, state
HAVING COUNT(*) > 50
ORDER BY fraud_rate_pct DESC
LIMIT 15;

-- Query 17: Transaction amount distribution
SELECT 
    CASE 
        WHEN amt < 10 THEN 'Under $10'
        WHEN amt BETWEEN 10 AND 50 THEN '$10-$50'
        WHEN amt BETWEEN 50 AND 100 THEN '$50-$100'
        WHEN amt BETWEEN 100 AND 500 THEN '$100-$500'
        WHEN amt BETWEEN 500 AND 1000 THEN '$500-$1000'
        ELSE 'Over $1000'
    END AS amount_range,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY amount_range
ORDER BY fraud_rate_pct DESC;

-- Query 18: Top 10 jobs with most fraud
SELECT 
    job,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY job
HAVING COUNT(*) > 100
ORDER BY fraud_rate_pct DESC
LIMIT 10;



-- SECTION 3: ADVANCED WINDOW FUNCTIONS

-- Query 19: Running total of fraud amount per category
SELECT 
    category,
    DATE(trans_date_time) AS trans_date,
    SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END) AS daily_fraud_amt,
    SUM(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END)) 
        OVER (PARTITION BY category ORDER BY DATE(trans_date_time)) AS running_fraud_total
FROM transactions
GROUP BY category, trans_date
ORDER BY category, trans_date;


-- Query 20: Rank customers by total spend
SELECT 
    first_name || ' ' || last_name AS customer_name,
    cc_num,
    ROUND(SUM(amt), 2) AS total_spend,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    RANK() OVER (ORDER BY SUM(amt) DESC) AS spend_rank
FROM transactions
GROUP BY customer_name, cc_num
ORDER BY spend_rank
LIMIT 20;

-- Query 21: LAG function — time between transactions per customer
SELECT 
    cc_num,
    first_name || ' ' || last_name AS customer_name,
    trans_date_time,
    amt,
    is_fraud,
    LAG(trans_date_time) OVER (PARTITION BY cc_num ORDER BY trans_date_time) AS prev_transaction,
    EXTRACT(EPOCH FROM (trans_date_time - LAG(trans_date_time) 
        OVER (PARTITION BY cc_num ORDER BY trans_date_time)))/60 AS minutes_since_last_trans
FROM transactions
ORDER BY cc_num, trans_date_time
LIMIT 30;

-- Query 22: Detect rapid successive transactions (possible fraud)
WITH transaction_gaps AS (
    SELECT 
        cc_num,
        first_name || ' ' || last_name AS customer_name,
        trans_date_time,
        amt,
        is_fraud,
        EXTRACT(EPOCH FROM (trans_date_time - LAG(trans_date_time) 
            OVER (PARTITION BY cc_num ORDER BY trans_date_time)))/60 AS minutes_gap
    FROM transactions
)
SELECT *
FROM transaction_gaps
WHERE minutes_gap < 5 AND minutes_gap IS NOT NULL
ORDER BY minutes_gap ASC
LIMIT 20;


-- Query 23: LEAD function — next transaction amount
SELECT 
    cc_num,
    trans_date_time,
    amt,
    is_fraud,
    LEAD(amt) OVER (PARTITION BY cc_num ORDER BY trans_date_time) AS next_trans_amt,
    LEAD(is_fraud) OVER (PARTITION BY cc_num ORDER BY trans_date_time) AS next_is_fraud
FROM transactions
ORDER BY cc_num, trans_date_time
LIMIT 20;


-- Query 24: Percentile ranking of transaction amounts
SELECT 
    trans_num,
    amt,
    is_fraud,
    category,
    NTILE(4) OVER (ORDER BY amt) AS quartile,
    PERCENT_RANK() OVER (ORDER BY amt) AS percent_rank,
    CUME_DIST() OVER (ORDER BY amt) AS cumulative_dist
FROM transactions
ORDER BY amt DESC
LIMIT 20;

-- Query 25: Moving average of daily fraud amount
SELECT 
    trans_date,
    daily_fraud_amt,
    ROUND(AVG(daily_fraud_amt) OVER (
        ORDER BY trans_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS seven_day_moving_avg
FROM (
    SELECT 
        DATE(trans_date_time) AS trans_date,
        ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS daily_fraud_amt
    FROM transactions
    GROUP BY trans_date
) daily_fraud
ORDER BY trans_date;


-- Query 26: ROW_NUMBER to get latest transaction per customer
WITH latest_transactions AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY cc_num ORDER BY trans_date_time DESC) AS rn
    FROM transactions
)
SELECT 
    cc_num,
    first_name || ' ' || last_name AS customer_name,
    trans_date_time AS last_transaction,
    amt AS last_amount,
    merchant AS last_merchant,
    is_fraud
FROM latest_transactions
WHERE rn = 1
ORDER BY last_transaction DESC
LIMIT 20;


-- Query 27: DENSE_RANK merchants by fraud amount per state
SELECT 
    state,
    merchant,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS fraud_amount,
    DENSE_RANK() OVER (
        PARTITION BY state 
        ORDER BY SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END) DESC
    ) AS rank_in_state
FROM transactions
GROUP BY state, merchant
HAVING SUM(is_fraud) > 0
ORDER BY state, rank_in_state
LIMIT 30;



-- SECTION 4: CTEs AND SUBQUERIES


-- Query 28: Multi-level CTE — fraud summary
WITH fraud_base AS (
    SELECT 
        category,
        state,
        COUNT(*) AS total_trans,
        SUM(is_fraud) AS fraud_count,
        ROUND(SUM(amt), 2) AS total_amt,
        ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS fraud_amt
    FROM transactions
    GROUP BY category, state
),
fraud_rates AS (
    SELECT *,
        ROUND(fraud_count * 100.0 / total_trans, 2) AS fraud_rate
    FROM fraud_base
),
high_risk AS (
    SELECT * FROM fraud_rates
    WHERE fraud_rate > 10
)
SELECT * FROM high_risk
ORDER BY fraud_rate DESC
LIMIT 20;


-- Query 29: Customers with multiple fraud transactions
WITH fraud_customers AS (
    SELECT 
        cc_num,
        first_name || ' ' || last_name AS customer_name,
        COUNT(*) AS fraud_count,
        ROUND(SUM(amt), 2) AS total_fraud_amount
    FROM transactions
    WHERE is_fraud = 1
    GROUP BY cc_num, customer_name
    HAVING COUNT(*) > 1
)
SELECT * FROM fraud_customers
ORDER BY fraud_count DESC;


-- Query 30: Above average fraud amount transactions
SELECT 
    trans_num,
    merchant,
    category,
    amt,
    is_fraud
FROM transactions
WHERE is_fraud = 1
AND amt > (
    SELECT AVG(amt) FROM transactions WHERE is_fraud = 1
)
ORDER BY amt DESC
LIMIT 20;

-- Query 31: Correlated subquery — customers spending above their avg
SELECT 
    t1.cc_num,
    t1.first_name || ' ' || t1.last_name AS customer_name,
    t1.trans_date_time,
    t1.amt,
    t1.is_fraud
FROM transactions t1
WHERE t1.amt > (
    SELECT AVG(t2.amt) * 3
    FROM transactions t2
    WHERE t2.cc_num = t1.cc_num
)
ORDER BY t1.amt DESC
LIMIT 20;

-- Query 32: Recursive CTE — fraud chain detection
WITH RECURSIVE fraud_chain AS (
    -- Base: first fraud transaction per card
    SELECT 
        cc_num,
        trans_date_time,
        amt,
        merchant,
        1 AS chain_level
    FROM transactions
    WHERE is_fraud = 1
    AND trans_date_time = (
        SELECT MIN(t2.trans_date_time) 
        FROM transactions t2 
        WHERE t2.cc_num = transactions.cc_num 
        AND t2.is_fraud = 1
    )
    LIMIT 100
),
fraud_summary AS (
    SELECT 
        cc_num,
        COUNT(*) OVER (PARTITION BY cc_num) AS total_fraud_count,
        SUM(amt) OVER (PARTITION BY cc_num) AS total_fraud_amt,
        MIN(trans_date_time) OVER (PARTITION BY cc_num) AS first_fraud,
        MAX(trans_date_time) OVER (PARTITION BY cc_num) AS last_fraud
    FROM transactions
    WHERE is_fraud = 1
)
SELECT DISTINCT * FROM fraud_summary
ORDER BY total_fraud_count DESC
LIMIT 20;

-- Query 33: EXISTS — customers who had both fraud and normal transactions
SELECT DISTINCT
    t1.cc_num,
    t1.first_name || ' ' || t1.last_name AS customer_name,
    t1.city,
    t1.state
FROM transactions t1
WHERE EXISTS (
    SELECT 1 FROM transactions t2 
    WHERE t2.cc_num = t1.cc_num AND t2.is_fraud = 1
)
AND EXISTS (
    SELECT 1 FROM transactions t3 
    WHERE t3.cc_num = t1.cc_num AND t3.is_fraud = 0
)
LIMIT 20;


-- Query 34: NOT EXISTS — customers with zero fraud
SELECT DISTINCT
    cc_num,
    first_name || ' ' || last_name AS customer_name,
    city, state
FROM transactions t1
WHERE NOT EXISTS (
    SELECT 1 FROM transactions t2
    WHERE t2.cc_num = t1.cc_num AND t2.is_fraud = 1
)
LIMIT 20;


-- SECTION 5: ADVANCED FRAUD DETECTION LOGIC


-- Query 35: Fraud velocity check — multiple transactions same hour
WITH hourly_trans AS (
    SELECT 
        cc_num,
        first_name || ' ' || last_name AS customer_name,
        DATE_TRUNC('hour', trans_date_time) AS trans_hour,
        COUNT(*) AS transactions_in_hour,
        ROUND(SUM(amt), 2) AS amount_in_hour,
        SUM(is_fraud) AS fraud_in_hour
    FROM transactions
    GROUP BY cc_num, customer_name, trans_hour
)
SELECT * FROM hourly_trans
WHERE transactions_in_hour >= 3
ORDER BY transactions_in_hour DESC
LIMIT 20;

-- Query 36: Geographic anomaly — distance between customer and merchant
SELECT 
    cc_num,
    first_name || ' ' || last_name AS customer_name,
    merchant,
    amt,
    is_fraud,
    ROUND(CAST(
        111.045 * DEGREES(ACOS(LEAST(1.0,
            COS(RADIANS(lat)) * COS(RADIANS(merch_lat)) *
            COS(RADIANS(long) - RADIANS(merch_long)) +
            SIN(RADIANS(lat)) * SIN(RADIANS(merch_lat))
        ))) AS DECIMAL), 2) AS distance_km
FROM transactions
ORDER BY distance_km DESC
LIMIT 20;

-- Query 37: Fraud score card per customer
WITH customer_stats AS (
    SELECT 
        cc_num,
        first_name || ' ' || last_name AS customer_name,
        COUNT(*) AS total_transactions,
        SUM(is_fraud) AS fraud_count,
        ROUND(AVG(amt), 2) AS avg_transaction,
        ROUND(MAX(amt), 2) AS max_transaction,
        ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate,
        COUNT(DISTINCT category) AS categories_used,
        COUNT(DISTINCT merchant) AS merchants_used
    FROM transactions
    GROUP BY cc_num, customer_name
)
SELECT *,
    CASE 
        WHEN fraud_rate > 20 THEN 'HIGH RISK 🔴'
        WHEN fraud_rate BETWEEN 10 AND 20 THEN 'MEDIUM RISK 🟡'
        WHEN fraud_rate BETWEEN 1 AND 10 THEN 'LOW RISK 🟢'
        ELSE 'NO FRAUD ✅'
    END AS risk_label
FROM customer_stats
WHERE fraud_count > 0
ORDER BY fraud_rate DESC
LIMIT 20;

-- Query 38: Unusual spending pattern — 3x above personal average
WITH customer_avg AS (
    SELECT 
        cc_num,
        AVG(amt) AS avg_spend,
        STDDEV(amt) AS stddev_spend
    FROM transactions
    GROUP BY cc_num
)
SELECT 
    t.cc_num,
    t.first_name || ' ' || t.last_name AS customer_name,
    t.trans_date_time,
    t.amt,
    ROUND(ca.avg_spend, 2) AS customer_avg,
    ROUND(t.amt / NULLIF(ca.avg_spend, 0), 2) AS times_above_avg,
    t.is_fraud
FROM transactions t
JOIN customer_avg ca ON t.cc_num = ca.cc_num
WHERE t.amt > ca.avg_spend * 3
ORDER BY times_above_avg DESC
LIMIT 20;

-- Query 39: Weekend vs Weekday fraud comparison
SELECT 
    CASE 
        WHEN DATE_PART('dow', trans_date_time) IN (0, 6) 
        THEN 'Weekend' ELSE 'Weekday' 
    END AS day_type,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(AVG(amt), 2) AS avg_amount,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 2) AS total_fraud_amount
FROM transactions
GROUP BY day_type
ORDER BY fraud_rate_pct DESC;


-- Query 40: Night time fraud analysis (12AM - 6AM)
SELECT 
    CASE 
        WHEN DATE_PART('hour', trans_date_time) BETWEEN 0 AND 5 
        THEN 'Night (12AM-6AM)'
        WHEN DATE_PART('hour', trans_date_time) BETWEEN 6 AND 11 
        THEN 'Morning (6AM-12PM)'
        WHEN DATE_PART('hour', trans_date_time) BETWEEN 12 AND 17 
        THEN 'Afternoon (12PM-6PM)'
        ELSE 'Evening (6PM-12AM)'
    END AS time_of_day,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(AVG(amt), 2) AS avg_amount
FROM transactions
GROUP BY time_of_day
ORDER BY fraud_rate_pct DESC;

-- Query 41: First and last transaction analysis per customer
WITH customer_journey AS (
    SELECT 
        cc_num,
        first_name || ' ' || last_name AS customer_name,
        MIN(trans_date_time) AS first_transaction,
        MAX(trans_date_time) AS last_transaction,
        COUNT(*) AS total_transactions,
        SUM(is_fraud) AS total_fraud,
        ROUND(SUM(amt), 2) AS total_spent
    FROM transactions
    GROUP BY cc_num, customer_name
)
SELECT *,
    DATE_PART('day', last_transaction - first_transaction) AS customer_lifetime_days,
    ROUND(CAST(total_spent / NULLIF(
        DATE_PART('day', last_transaction - first_transaction), 0
    ) AS DECIMAL), 2) AS avg_daily_spend
FROM customer_journey
WHERE total_fraud > 0
ORDER BY total_fraud DESC
LIMIT 20;

-- Query 42: Final Fraud Summary Report
SELECT 
    '📊 FRAUD DETECTION SUMMARY REPORT' AS report_title,
    '' AS value
UNION ALL SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', ''
UNION ALL SELECT 'Total Transactions', COUNT(*)::TEXT FROM transactions
UNION ALL SELECT 'Total Fraud Cases', SUM(is_fraud)::TEXT FROM transactions
UNION ALL SELECT 'Overall Fraud Rate', ROUND(SUM(is_fraud)*100.0/COUNT(*),2)::TEXT || '%' FROM transactions
UNION ALL SELECT 'Total Transaction Amount', '$' || ROUND(SUM(amt),2)::TEXT FROM transactions
UNION ALL SELECT 'Total Fraud Amount', '$' || ROUND(SUM(CASE WHEN is_fraud=1 THEN amt ELSE 0 END),2)::TEXT FROM transactions
UNION ALL SELECT 'Avg Fraud Amount', '$' || ROUND(AVG(CASE WHEN is_fraud=1 THEN amt END),2)::TEXT FROM transactions
UNION ALL SELECT 'Highest Single Fraud', '$' || ROUND(MAX(CASE WHEN is_fraud=1 THEN amt END),2)::TEXT FROM transactions;




-- Query 43: Export fraud transactions to CSV
COPY (
    SELECT * FROM transactions WHERE is_fraud = 1
    ORDER BY amt DESC
)
TO 'C:/temp/fraud_transactions_export.csv'
DELIMITER ','
CSV HEADER;


-- Query 44: Export fraud summary report
COPY (
    SELECT 
        category,
        COUNT(*) AS total_transactions,
        SUM(is_fraud) AS fraud_count,
        ROUND(SUM(is_fraud)*100.0/COUNT(*),2) AS fraud_rate_pct,
        ROUND(SUM(CASE WHEN is_fraud=1 THEN amt ELSE 0 END),2) AS fraud_amount
    FROM transactions
    GROUP BY category
    ORDER BY fraud_rate_pct DESC
)
TO 'C:/temp/fraud_summary_export.csv'
DELIMITER ','
CSV HEADER;

SELECT '✅ Export Complete!' AS status;
