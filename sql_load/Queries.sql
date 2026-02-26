SELECT 
     job_title_short as title,
     job_posted_date ::date as date,
     job_location as location
from job_postings_fact;

select*
from job_postings_fact
limit 100;


/*Write a query to find the average salary both yearly 
(salary_year_avg) and hourly (salary_hour_avg) for job postings
that were posted after June 1, 2023. Group the results
by job schedule type.*/

select 
job_schedule_type,
AVG(salary_year_avg) as avg_salary_per_year,
AVG(salary_hour_avg) as avg_salary_per_hour
FROM job_postings_fact
--WHERE EXTRACT(MONTH FROM job_posted_date) IN (6,7,8,9,10,11,12)
WHERE job_posted_date > '2023-06-01'
GROUP BY job_schedule_type;

/*Write a query to count the number of job postings for each month in 2023,
adjusting the job_posted_date to be in 'America/New_York' time zone before 
extracting (hint) the month. Assume the job_posted_date is stored in UTC. 
Group by and order by the month.*/

select 
EXTRACT(MONTH FROM job_posted_date at time zone 'UTC' at time zone 'America/New_York') as month,
count(job_id) as job_count
FROM job_postings_fact
WHERE job_posted_date > '2023-01-01' AND job_posted_date < '2023-12-31'
GROUP BY month
ORDER BY month;

/*Write a query to find companies (include company name) 
that have posted jobs offering health insurance, where these postings were made
 in the second quarter of 2023. Use date extraction to filter by quarter.*/

SELECT
c.name
from job_postings_fact j
JOIN company_dim c
ON j.company_id = c.company_id
WHERE EXTRACT(YEAR FROM job_posted_date at time zone 'UTC' at time zone 'America/New_York') = 2023
AND extract(quarter FROM job_posted_date at time zone 'UTC' at time zone 'America/New_York') = 2;

--creating tables for jan, feb, and march of 2023

CREATE TABLE january_jobs AS
select * 
from job_postings_fact
WHERE extract(MONTH FROM job_posted_date at time zone 'UTC' at time zone 'America/New_York') = 1;

CREATE TABLE february_jobs AS
select *
from job_postings_fact
WHERE extract(MONTH FROM job_posted_date at time zone 'UTC' at time zone 'America/New_York') = 2;

CREATE TABLE march_jobs AS
select *
from job_postings_fact
WHERE extract(MONTH FROM job_posted_date at time zone 'UTC' at time zone 'America/New_York') = 3;

--Write a query to count the number of job postings for each 
--combination of job title and location category.

SELECT
COUNT(job_id) as job_count,
job_title_short as title,
CASE 
    WHEN job_location ='Anywhere' THEN 'Remote'
    when job_location ='New York, NY' THEN 'local'

    ELSE 'On-site'
END as location_category
FROM job_postings_fact
GROUP BY title, location_category;

--Write a query to find the top 5 job titles with the 
--highest average yearly salary (salary_year_avg) for 
--postings that require a Bachelor's degree. 
--Include the average salary in the results.

SELECT
job_id,
job_title_short as title,
salary_year_avg,
CASE 
    WHEN salary_year_avg > 200000 THEN 'High Salary'
    WHEN salary_year_avg > 100000 THEN 'Medium Salary'
    ELSE 'Low Salary'
END as salary_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC;


--Write a query to find companies (include company name and company_id)
--that have posted jobs mentioning "no degree required" 
--in the job description.

SELECT name as company_name,
company_id
FROM company_dim
WHERE company_id in(

SELECT company_id
FROM job_postings_fact
WHERE job_no_degree_mention = true);

--Write a query to find the total number of job postings for each company,
--including the company name. Order the results by the number of
--job postings in descending order.

with total_jobs as (
SELECT
COUNT(*) as job_count,
company_id
FROM job_postings_fact
GROUP BY company_id)

SELECT
c.name as company_name,
t.job_count
FROM total_jobs t
LEFT JOIN company_dim c
ON t.company_id = c.company_id
ORDER BY job_count DESC;

--Write a query to find the top 10 skills (include skill name) 
--that are most commonly required in job postings that allow remote work.

with work_from_home_jobs as (
SELECT
skill_id,
COUNT(*) as skill_count
FROM skills_job_dim as sj
INNER JOIN job_postings_fact as jp
ON sj.job_id = jp.job_id
WHERE jp.job_work_from_home = true and jp.job_title_short = 'Data Analyst'
GROUP BY skill_id)
SELECT
s.skill_id,
s.skills,
w.skill_count
FROM work_from_home_jobs w
JOIN skills_dim s
ON w.skill_id = s.skill_id
ORDER BY skill_count DESC
LIMIT 10;


