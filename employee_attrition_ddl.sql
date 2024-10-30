-- create the 'employees' database
CREATE DATABASE employees;
USE employees;

-- define the table structure with selected attributes for analysis
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    age INT,
    attrition VARCHAR(3),
    business_travel VARCHAR(40),
    department VARCHAR(40),
    education INT,
    gender VARCHAR(6),
    job_involvement INT,
    job_level INT,
    monthly_income INT,
    overtime VARCHAR(3),
    performance INT,
    training_time INT,
    work_life_balance INT, 
    years_at_company INT,
    years_since_last_promotion INT
);

-- display the structure of the created table
DESC employees;

-- import data from a .csv file into the table (only essential columns included for analysis)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/HR.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @col1, @col2, @col3, @col4, @col5, @col6, 
    @col7, @col8, @col9, @col10, @col11, @col12, 
    @col13, @col14, @col15, @col16, @col17, @col18, 
    @col19, @col20, @col21, @col22, @col23, @col24, 
    @col25, @col26, @col27, @col28, @col29, @col30, 
    @col31, @col32, @col33, @col34, @col35
)
SET
    age = @col1,
    attrition = @col2,
    business_travel = @col3,
    department = @col5,
    education = @col7,
    gender = @col12,
    job_involvement = @col14,
    job_level = @col15,
    monthly_income = @col19,
    overtime = @col23,
    performance = @col25,
    training_time = @col30,
    work_life_balance = @col31, 
    years_at_company = @col32,
    years_since_last_promotion = @col34;
