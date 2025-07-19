-- What are the most in demand skills for aspiring data analysts
select skills,
    count(sjd.job_id) as demand_count
from job_postings_fact jpf
    join skills_job_dim sjd on jpf.job_id = sjd.job_id
    join skills_dim sd on sjd.skill_id = sd.skill_id
where job_title_short = 'Data Analyst'
group by skills
order by demand_count desc
limit 5;