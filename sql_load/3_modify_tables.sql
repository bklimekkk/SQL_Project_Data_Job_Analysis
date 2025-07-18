/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
 Database Load Issues (follow if receiving permission denied when running SQL code below)
 
 NOTE: If you are having issues with permissions. And you get error: 
 
 'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'
 
 1. Open pgAdmin
 2. In Object Explorer (left-hand pane), navigate to `sql_course` database
 3. Right-click `sql_course` and select `PSQL Tool`
 - This opens a terminal window to write the following code
 4. Get the absolute file path of your csv files
 1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
 5. Paste the following into `PSQL Tool`, (with the CORRECT file path)
 
 \copy company_dim FROM '[Insert File Path]/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
 \copy skills_dim FROM '[Insert File Path]/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
 \copy job_postings_fact FROM '[Insert File Path]/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
 \copy skills_job_dim FROM '[Insert File Path]/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
 */
-- NOTE: This has been updated from the video to fix issues with encoding
COPY company_dim
FROM '/Users/bartoszklimek/Desktop/SQL/SQL_Project_Data_Job_Analysis/csv_files/company_dim.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );
COPY skills_dim
FROM '/Users/bartoszklimek/Desktop/SQL/SQL_Project_Data_Job_Analysis/csv_files/skills_dim.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );
COPY job_postings_fact
FROM '/Users/bartoszklimek/Desktop/SQL/SQL_Project_Data_Job_Analysis/csv_files/job_postings_fact.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );
COPY skills_job_dim
FROM '/Users/bartoszklimek/Desktop/SQL/SQL_Project_Data_Job_Analysis/csv_files/skills_job_dim.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );
select count(job_id) as job_posted_count,
    extract(
        month
        from job_posted_date
    ) as month
from job_postings_fact
where job_title_short = 'Data Analyst'
group by month
order by job_posted_count desc;
SELECT extract(
        month
        from job_posted_date at time zone 'UTC' at time zone 'America/New_York'
    ) as month,
    count(job_id)
from job_postings_fact
where extract(
        year
        from job_posted_date at time zone 'UTC' at time zone 'America/New_York'
    ) = 2023
group by month
order by month;
select distinct cd.name
from job_postings_fact jpf
    join company_dim cd on jpf.company_id = cd.company_id
where jpf.job_health_insurance = true
    and extract(
        year
        from job_posted_date
    ) = 2023
    and extract(
        quarter
        from job_posted_date
    ) = 2;
select *
from job_postings_fact
where extract(
        month
        from job_posted_date
    ) = 1;
select *
from job_postings_fact
where extract(
        month
        from job_posted_date
    ) = 2;
select *
from job_postings_fact
where extract(
        month
        from job_posted_date
    ) = 3;
select count(job_title) as number_of_jobs,
    case
        when job_location = 'Anywhere' then 'Remote'
        when job_location = 'New York, NY' then 'Local'
        else 'Onsite'
    end as location_category
from job_postings_fact
where job_title_short = 'Data Analyst'
group by location_category;
select *,
    case
        when salary_year_avg >= 50000 then 'high'
        when salary_year_avg < 50000
        and salary_year_avg >= 20000 then 'standard'
        else 'low'
    end as salary_category
from job_postings_fact
where job_title_short = 'Data Analyst'
    and salary_year_avg is not null
order by salary_year_avg desc;
select company_id,
    name as company_name
from company_dim
where company_id in (
        select company_id
        from job_postings_fact
        where job_no_degree_mention = true
        order by company_id
    );
with company_job_count as (
    select company_id,
        count(*) as number_of_jobs
    from job_postings_fact
    group by company_id
)
select company_dim.name,
    company_job_count.number_of_jobs
from company_dim
    left join company_job_count on company_dim.company_id = company_job_count.company_id
order by number_of_jobs desc;
select skills
from skills_dim
where skill_id in (
        select skill_id
        from skills_job_dim
        group by skill_id
        order by count(*) desc
        limit 5
    );
select *,
    case
        when posts_number > 50 then 'Large'
        when posts_number <= 50
        and posts_number >= 10 then 'Medium'
        else 'Small'
    end as company_size
from (
        select job_postings_fact.company_id,
            company_dim.name as company_name,
            count(*) as posts_number
        from job_postings_fact
            join company_dim on job_postings_fact.company_id = company_dim.company_id
        group by 1,
            2
        order by job_postings_fact.company_id
    ) with remote_job_skills as (
        select skill_id,
            count(*) as skill_count
        from skills_job_dim as skills_to_job
            inner join job_postings_fact as job_posting on skills_to_job.job_id = job_posting.job_id
        where job_posting.job_work_from_home = true
            and job_posting.job_title_short = 'Data Analyst'
        group by skill_id
    )
select skills.skill_id,
    skills as skill_name,
    skill_count
from remote_job_skills
    inner join skills_dim as skills on skills.skill_id = remote_job_skills.skill_id
order by skill_count desc
limit 5;
SELECT january_jobs.job_title_short,
    skills_dim.skills,
    skills_dim.type
FROM january_jobs
    LEFT JOIN skills_job_dim ON january_jobs.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
UNION ALL
SELECT february_jobs.job_title_short,
    skills_dim.skills,
    skills_dim.type
FROM february_jobs
    LEFT JOIN skills_job_dim ON february_jobs.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
UNION ALL
SELECT march_jobs.job_title_short,
    skills_dim.skills,
    skills_dim.type
FROM march_jobs
    LEFT JOIN skills_job_dim ON march_jobs.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id;
select job_title_short,
    job_location,
    job_via,
    job_posted_date::date,
    salary_year_avg
from (
        select *
        from january_jobs
        union ALL
        select *
        from february_jobs
        union ALL
        select *
        from march_jobs
    ) as quarter1_job_postings
where salary_year_avg > 70000
    and job_title_short = 'Data Analyst'
order by salary_year_avg desc;
-- end of file