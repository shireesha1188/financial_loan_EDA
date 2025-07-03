--1.Loan Status and Default Rate by State
WITH state_defaults AS (
    SELECT 
        state,
        COUNT(*) AS total_loans,
        SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS defaults
    FROM financial_loan
    GROUP BY state
)
SELECT 
    state,
    total_loans,
    defaults,
    ROUND(CAST(defaults AS FLOAT) / total_loans * 100, 2) AS default_rate_percent
FROM state_defaults
WHERE total_loans >= 50
ORDER BY default_rate_percent DESC;

--2.Loan Performance Metrics Vary Across Different Income Groups
WITH CTE AS(
SELECT *,CASE WHEN annual_income <30000 THEN 'Low Income'
            WHEN annual_income BETWEEN 30000 AND 60000 THEN 'Mid Income'
		    WHEN annual_income BETWEEN 60000 AND 100000 THEN 'Upper Income'
		 ELSE 'High Income'
		 END AS income_groups
		 FROM financial_loan
		)
SELECT income_groups,COUNT(*) AS total_loans,
            SUM(CASE WHEN loan_status='Fully Paid' THEN 1 ELSE 0 END) AS Fully_paid,
			SUM(CASE WHEN loan_status='Charged Off' THEN 1 ELSE 0 END) AS Defaults,
			ROUND(AVG(dti),2) AS avg_dti
			FROM CTE
GROUP BY income_groups
ORDER BY total_loans DESC

--3.Top 5 Loan Purposes by Default Rate

SELECT TOP 5
    purpose,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS defaults,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS default_rate
FROM financial_loan
GROUP BY purpose
ORDER BY default_rate DESC;

--4.  Risk and Profitability Metrics by Grade (Avg Loan, Interest, Installment, Default Rate)

SELECT grade,COUNT(*) AS total_loan,AVG(loan_amount) AS avg_loan,ROUND(AVG(interest_rate),2) AS avg_interest,
ROUND(AVG(installment),2) AS avg_installment,
SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS defaults,
    ROUND(
         100 *SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS default_rate
	FROM financial_loan
	GROUP BY grade
	ORDER BY grade
--5.Loan Recovery Ratio By Grade
WITH CTE AS(
SELECT grade,total_payment,loan_amount FROM financial_loan
WHERE loan_status='Charged Off' AND loan_amount>0
)
SELECT grade,ROUND(AVG(CAST(total_payment AS FLOAT)/loan_amount),2) AS recovery_rate FROM CTE
GROUP BY grade
ORDER BY recovery_rate DESC













