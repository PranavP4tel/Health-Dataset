create database health;
use health;

/*
Analysis conducted:
1. List of healthy individuals & Low absenteeism
2. Calculate wage increase for non smokers for insurance budget of 983,221
3. Count of asbenteeism in seasons. (Inspect season with peak absenteeism)
4. Distribution of absence reason
5. Absenteeism based on age ranges
6. Distribution of disciplinary failure with age
7. Total transportation expense
8. Commute distance ranges and transportation expense as per range
9. Dashboard for HR to understand absenteeism at work - Completed in PowerBI
*/

#Viewing data in all tables
select * from absent;
select * from reasons;
select * from compensation;

#Creating combined table for analysis
create table health as (
select absent.*, compensation.comp, reasons.Reason, 
case when bmi<18.5 then 'Underweight'
when bmi between 18.5 and 25 then 'Healthy'
when bmi between 25 and 30 then 'Overweight'
when bmi>30 then 'Obese'
else 'Unknown' end as bmi_category,
case when Month_of_absence in (12,1,2) then 'winter'
when Month_of_absence in (3,4,5) then 'spring'
when Month_of_absence in (6,7,8) then 'summer'
when Month_of_absence in (9,10,11) then 'fall'
else 'Unknown' end as absence_season,
case when age<38 then '27-37'
when age<48 then '38-47'
when age<59 then '47-58'
else 'Unkown' end as age_range,
case when `Distance from Residence to Work`>=5 and `Distance from Residence to Work`<=15 then '5-15'
when `Distance from Residence to Work`>=16 and `Distance from Residence to Work`<=25 then '16-25'
when `Distance from Residence to Work`>=26 and `Distance from Residence to Work`<=35 then '26-35'
when `Distance from Residence to Work`>=36 and `Distance from Residence to Work`<=45 then '36-45'
when `Distance from Residence to Work`>=46 and `Distance from Residence to Work`<=55 then '46-55'
else 'Unknown' end as cd_range
from absent
left join compensation on absent.ID = compensation.ID
left join reasons on absent.reason_number = reasons.Number);

#1st Analysis
#For healthy - drinker = 0, smoker = 0, bmi<25, absenteeism <4
select ID, social_drinker, social_smoker, bmi, bmi_category, absenteeism from health
where social_drinker=0 and social_smoker=0 and bmi<25 and absenteeism<(
select avg(absenteeism) from health);

select bmi_category, sum(absenteeism) as Absenteeism from health
group by bmi_category
order by Absenteeism desc;

#2nd Analysis
select count(*) from health where social_smoker=0;
#Total work hours = 8*5*52*(count of non smokers = 686) = 14,26,880
#Increase in wage = amount/work hours = 983221/14,26,880 = 0.689
#Yearly increase in all employees salary = 0.689*8*5*52 = 1,433.12 USD
#Comp/hr after increase for all non smokers:
select ID, social_smoker, comp, (comp+0.689) as comp_new from health where social_smoker=0;

#3rd Analysis
#Checking peak absenteeism as per season
select absence_season, count(*) as Absentees from health
group by absence_season
order by Absentees desc;

select absence_season, sum(absenteeism) as Absenteeism from health
group by absence_season
order by Absenteeism desc;

#4th Analysis
select reason, count(*) as Count from health
group by reason
order by count desc;

#5th Analysis
select age_range, count(*) as Count from health
group by age_range
order by Count desc;

select age_range, sum(absenteeism) as Absenteeism from health
group by age_range
order by Absenteeism desc;

select age_range, reason, count(*) as Count
from health
group by age_range, reason
order by Count desc;

#6th Analysis
select count(*) as Count, (count(*)/740)*100 as Percentage from health 
where disciplinary_failure=1;

select age_range, count(*) as Count from health
where disciplinary_failure=1
group by age_range
order by Count desc;

#7th Analysis
select sum(transportation_expense) as Total_TE from health;

#8th Analysis
select cd_range, count(ID) as Count, sum(transportation_expense) as Total_TE from health
group by cd_range
order by Total_TE desc;

#Query for PowerBI
select absent.*, compensation.comp, reasons.Reason, 
case when bmi<18.5 then 'Underweight'
when bmi between 18.5 and 25 then 'Healthy'
when bmi between 25 and 30 then 'Overweight'
when bmi>30 then 'Obese'
else 'Unknown' end as bmi_category,
case when Month_of_absence in (12,1,2) then 'winter'
when Month_of_absence in (3,4,5) then 'spring'
when Month_of_absence in (6,7,8) then 'summer'
when Month_of_absence in (9,10,11) then 'fall'
else 'Unknown' end as absence_season,
case when age<38 then '27-37'
when age<48 then '38-47'
when age<59 then '47-58'
else 'Unkown' end as age_range,
case when `Distance from Residence to Work`>=5 and `Distance from Residence to Work`<=15 then '5-15'
when `Distance from Residence to Work`>=16 and `Distance from Residence to Work`<=25 then '16-25'
when `Distance from Residence to Work`>=26 and `Distance from Residence to Work`<=35 then '26-35'
when `Distance from Residence to Work`>=36 and `Distance from Residence to Work`<=45 then '36-45'
when `Distance from Residence to Work`>=46 and `Distance from Residence to Work`<=55 then '46-55'
else 'Unknown' end as cd_range
from absent
left join compensation on absent.ID = compensation.ID
left join reasons on absent.reason_number = reasons.Number;
