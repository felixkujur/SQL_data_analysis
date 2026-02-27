/*
What skills are required for the top-paying data analyst jobs?
-use the top-paying data analyst jobs identified in the previous 
query to find the most commonly required skills for these roles.
-add the specific skills required for these roles */

with top_paying_jobs as (
SELECT
job_id,
job_title,
company_dim.name as company_name,
salary_year_avg
FROM job_postings_fact
JOIN company_dim
ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
AND job_location='Anywhere'
ORDER BY salary_year_avg DESC
LIMIT 10)

SELECT
tp.*,
sd.skills
FROM top_paying_jobs tp
INNER JOIN skills_job_dim as s
ON tp.job_id = s.job_id
INNER JOIN skills_dim as sd
ON s.skill_id = sd.skill_id;