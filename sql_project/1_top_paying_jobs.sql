-- What are the top paying 'Data Analyst' remote jobs?
select
jpf.job_id,
jpf.job_title,
jpf.job_location,
jpf.job_schedule_type,
jpf.salary_year_avg,
jpf.job_posted_date,
cd.name as company_name
from job_postings_fact jpf
left join company_dim cd on jpf.company_id = cd.company_id
where job_title_short = 'Data Analyst'
and job_location = 'Anywhere'
and salary_hour_avg is not null
order by salary_year_avg DESC
limit 10;