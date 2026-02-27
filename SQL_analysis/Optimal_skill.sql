/*What are the most optimal skills for data analyst jobs?
-identify the top-paying data analyst jobs that allow remote work.
-focuses on job postings with specified salaries (remove nulls).
*/

WITH skills_demand AS (
SELECT
skills_dim.skill_id,
skills_dim.skills,
COUNT(job_postings_fact.job_id) as job_count
FROM job_postings_fact
INNER JOIN skills_job_dim
ON skills_job_dim.job_id = job_postings_fact.job_id
INNER JOIN skills_dim
ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
GROUP BY skills_dim.skill_id)
,average_salary AS (
SELECT
skills_dim.skill_id,
round(AVG(salary_year_avg),2) as avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim
ON skills_job_dim.job_id = job_postings_fact.job_id
INNER JOIN skills_dim
ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
GROUP BY skills_dim.skill_id)

SELECT
skills_demand.skill_id,
skills_demand.skills,
average_salary.avg_salary,
skills_demand.job_count
FROM skills_demand
INNER JOIN average_salary
ON skills_demand.skill_id = average_salary.skill_id
LIMIT 20;