-- What are the most optimal skills to learn
with skills_demand as (
    select sd.skill_id,
        sd.skills,
        count(sjd.job_id) as demand_count
    from job_postings_fact jpf
        join skills_job_dim sjd on jpf.job_id = sjd.job_id
        join skills_dim sd on sjd.skill_id = sd.skill_id
    where job_title_short = 'Data Analyst'
        and salary_year_avg is not null
        and job_work_from_home = true
    group by sd.skill_id
),
average_salary as (
    select sd.skill_id,
        sd.skills,
        round(avg(salary_year_avg), 0) as avg_salary
    from job_postings_fact jpf
        join skills_job_dim sjd on jpf.job_id = sjd.job_id
        join skills_dim sd on sjd.skill_id = sd.skill_id
    where job_title_short = 'Data Analyst'
        and salary_year_avg is not null
        and job_work_from_home = true
    group by sd.skill_id
)
select skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary
from skills_demand
    inner join average_salary on skills_demand.skill_id = average_salary.skill_id
where demand_count > 10
order by avg_salary desc,
    demand_count desc
limit 25;