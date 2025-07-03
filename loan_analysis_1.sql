--basic queries

--1.total loan amount issued by states

select state,state_code as code,sum(loan_amount) as total_loan from financial_loan
group by state,state_code
order by total_loan DESC;

--2.avg interest_rate by grade
select grade,round(avg(interest_rate),1) as avg_int from financial_loan
group by grade
order by avg_int;

--3.loan distibution by status
select loan_status,count(*) as count,sum(loan_amount) as total_amount,sum(total_payment) as total_received  from financial_loan
group by loan_status
order by total_amount;

--4.top 5 loan purpose
select top 5 count(*) as total,purpose from financial_loan
group by purpose;

--5.monthly loan trends
select DATENAME(MONTH,issue_date) as month,sum(loan_amount) as total from financial_loan
group by DATENAME(MONTH,issue_date),MONTH(issue_date)
order by MONTH(issue_date)

--6.debt_to_income ration by employee length
select emp_length,round(sum(dti),2) as avg from financial_loan
group by emp_length
order by avg;

--7. verification status percentage
select verification_status, count(*) * 100.0 / (select count(*) from financial_loan) as percentage
from financial_loan
group by verification_status;

--8.home distribution percent
select home_ownership, count(*) * 100.0 / (select count(*) from financial_loan) as percentage
from financial_loan
group by home_ownership;

--9.top 5 emp_title by loan amount
select TOP 5 emp_title, count(*) as total_loans
from financial_loan
group by emp_title
order by total_loans DESC;

--10.loan with above avg interest rate
select count(*) from financial_loan
where interest_rate >(select avg(interest_rate) from financial_loan);

--11.loan distribution by owner ship
SELECT 
    home_ownership,
    COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) * 100.0 / COUNT(*) AS default_rate
FROM financial_loan
GROUP BY home_ownership
ORDER BY default_rate DESC;
