-- 1. Show the count and percentage of employees in each age group.
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 30 THEN '18-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        ELSE '51-60'
    END AS age_group,
    COUNT(*) AS num_employees,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM employees), 2) AS age_group_ratio
FROM 
    employees
GROUP BY 
    age_group;

-- 2. What is the gender distribution (female ratio) across different job levels in the organization?
SELECT 
    job_level,
    ROUND(100.0 * SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) / COUNT(*), 2) AS female_ratio
FROM 
    employees
GROUP BY 
    job_level
ORDER BY 
    female_ratio DESC;

-- 3. Calculate the overall attrition rate in the company.
SELECT 
    ROUND(100.0 * COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) / COUNT(*), 2) AS attrition_rate
FROM 
    employees;

-- 4. Show the attrition rate of each department.
SELECT 
    department,
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM 
    employees
GROUP BY 
    department
ORDER BY 
    attrition_rate DESC;

-- 5. Check minimum and maximum salary to define salary tiers. Then show attrition rate for each salary tier (from highest to lowest).
SELECT 
    MIN(monthly_income) AS min_salary,
    MAX(monthly_income) AS max_salary
FROM 
    employees;

SELECT 
    CASE
        WHEN monthly_income BETWEEN 1000 AND 5999 THEN '1-5k'
        WHEN monthly_income BETWEEN 6000 AND 10999 THEN '6-10k'
        WHEN monthly_income BETWEEN 11000 AND 15999 THEN '11-15k'
        WHEN monthly_income BETWEEN 15000 AND 20999 THEN '16-20k'
    END AS salary,
    100 * ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM 
    employees
GROUP BY 
    salary
ORDER BY 
    attrition_rate DESC;

-- 6. Show the attrition rate per age group.
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 30 THEN '18-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        ELSE '51-60'
    END AS age_group,
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM 
    employees
GROUP BY 
    age_group
ORDER BY 
    attrition_rate DESC;

-- 7. Identify age groups where the attrition rate is higher for women than for men.
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 30 THEN '18-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        ELSE '51-60'
    END AS age_group,
    ROUND(100.0 * SUM(CASE WHEN gender = 'Female' AND attrition = 'Yes' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END), 0), 2) AS female_attrition_rate,
    ROUND(100.0 * SUM(CASE WHEN gender = 'Male' AND attrition = 'Yes' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END), 0), 2) AS male_attrition_rate
FROM 
    employees
GROUP BY 
    age_group
HAVING 
    female_attrition_rate > male_attrition_rate;

-- 8. Identify age groups with an attrition rate higher than the overall company attrition rate.
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 30 THEN '18-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        ELSE '51-60'
    END AS age_group,
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS age_group_attrition_rate
FROM 
    employees
GROUP BY 
    age_group
HAVING 
    age_group_attrition_rate > (
        SELECT 
            ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 END) / COUNT(*), 2)
        FROM 
            employees
    );

-- 9. Identify combinations of age group and gender where the attrition rate exceeds the overall company attrition rate.
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 30 THEN '18-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        ELSE '51-60'
    END AS age_group,
    gender,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    (SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS attrition_rate
FROM 
    employees
GROUP BY 
    age_group, gender
HAVING 
    attrition_rate > (SELECT SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) FROM employees)
ORDER BY 
    attrition_rate DESC;

-- 10. Compare the average salary of employees who left the organization versus those who stayed.
SELECT 
    attrition,
    AVG(monthly_income) AS avg_salary
FROM 
    employees
GROUP BY 
    attrition;

-- 11. Compare the average salary by job level for employees who left the organization versus those who stayed.
SELECT 
    job_level,
    AVG(CASE WHEN attrition = 'Yes' THEN monthly_income END) AS avg_salary_attrition_yes,
    AVG(CASE WHEN attrition = 'No' THEN monthly_income END) AS avg_salary_attrition_no
FROM 
    employees
GROUP BY 
    job_level
ORDER BY 
    job_level;

-- 12. List employees whose salary is more than 50% below the average salary for their job level.
WITH SalaryData AS (
    SELECT 
        emp_id,
        gender,
        job_level,
        monthly_income AS salary,
        ROUND(AVG(monthly_income) OVER (PARTITION BY job_level),2) AS avg_salary_for_job_level,
        ROUND(100 * (monthly_income / AVG(monthly_income) OVER (PARTITION BY job_level) - 1),2) AS percent_salary_difference
    FROM 
        employees
)
SELECT *
FROM 
    SalaryData
WHERE 
    percent_salary_difference < -50
ORDER BY 
    percent_salary_difference;