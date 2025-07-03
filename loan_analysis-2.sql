--1.Monthly Loan Issuance Segregated by Home Ownership 
SELECT *
FROM (
    SELECT 
        FORMAT(CAST(issue_date AS DATE), 'yyyy-MM') AS loan_month,
        home_ownership,
        loan_amount
    FROM financial_loan
) AS src
PIVOT (
    SUM(loan_amount) FOR home_ownership IN ([RENT], [MORTGAGE], [OWN], [OTHER])
) AS pvt
ORDER BY loan_month;

--2.Top 5 Loan-Issuing Employee Titles by State and Purpose (Based on Total Loan Amount)
SELECT TOP 5
    emp_title,
    state,
    purpose,
    COUNT(*) AS num_loans,
    ROUND(SUM(loan_amount), 2) AS total_loan_amount,
    ROUND(SUM(total_payment), 2) AS received_payment
FROM financial_loan
WHERE emp_title IS NOT NULL AND emp_title <> ''
GROUP BY emp_title, state, purpose
ORDER BY total_loan_amount DESC;


--3. Top 5 High-Risk States Based on Highest Average Interest Rate
WITH RankedStates AS (
    SELECT 
        state,
        ROUND(AVG(interest_rate), 2) AS avg_interest,
        ROW_NUMBER() OVER (ORDER BY AVG(interest_rate) DESC) AS rank
    FROM financial_loan
    GROUP BY state
)
SELECT *
FROM RankedStates
WHERE rank <= 5;

--4.Top Borrowers From Each State
WITH ranked_loans AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY state ORDER BY loan_amount DESC) AS rn
    FROM financial_loan
)
SELECT 
    emp_title,
    state,
    loan_amount,
    purpose,
    annual_income
FROM ranked_loans
WHERE rn = 1
ORDER BY loan_amount DESC;

--5.Loan Performance Summary Of Each Grade
SELECT
    grade,
    COUNT(*) AS total_loans,
    COUNT(CASE WHEN loan_status = 'Fully Paid' THEN 1 END) AS paid_loans,
    COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) AS defaulted_loans,
    ROUND(100 * COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) / COUNT(*), 2) AS default_rate
FROM financial_loan
GROUP BY grade
ORDER BY default_rate DESC;

--6. Monthly Unique Borrowers and Loan Issuance with Month-over-Month Growth
WITH MonthlyStats AS (
    SELECT 
        FORMAT(CAST(issue_date AS DATE), 'yyyy-MM') AS month,
        COUNT(DISTINCT id) AS borrowers,
        SUM(loan_amount) AS total_loans
    FROM financial_loan
    GROUP BY FORMAT(CAST(issue_date AS DATE), 'yyyy-MM')
)
SELECT *,
    borrowers - LAG(borrowers) OVER (ORDER BY month) AS borrower_growth,
    total_loans - LAG(total_loans) OVER (ORDER BY month) AS loan_growth
FROM MonthlyStats;

--7.Loan Status By Grade
SELECT *
FROM (
    SELECT grade, loan_status
    FROM financial_loan
) AS src
PIVOT (
    COUNT(loan_status) FOR loan_status IN ([Fully Paid], [Charged Off], [Current])
) AS pvt
ORDER BY grade;


