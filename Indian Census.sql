use demo27;
select * from dataset1;
select * from dataset2; 

-- To see how many rows are there
select count(*) from dataset1;
select count(*) from dataset2;

-- Find the total population of India
select sum(Population) as Total_Population from dataset2;

-- Find the average growth of India in percentage
select avg(Growth) as avg_growth from dataset1;

-- Find the statewise average growth of India in percentage 
select State,avg(Growth) as avg_growth 
from dataset1 
group by State;

-- list the top 10 districs with the largest area
select District,State,Area_km2
from Dataset2
order by Area_km2 desc limit 10;

-- calculate population density for each state
select District,State, Population/Area_km2 as population_density
from Dataset2;

-- Find the statewise highest to lowest avg sex ratio make sure that avg sex ratio should be rounded to zero decimal places
select State,round(avg(Sex_Ratio),0) as avg_sex_ratio 
from dataset1 
group by State 
order by avg_sex_ratio desc;

-- Find the statewise  avg literacy ratio  make sure that avg sex ratio should be rounded to zero decimal places and ratio will be greater than 90.
select State,round(avg(Literacy),0) as avg_literacy_ratio 
from dataset1 
group by State
having round(avg(Literacy),0)>90;

-- Find the top 3 states that showing highest growth ratio
select State,avg(Growth) as avg_drowth 
from Dataset1 
group by State
order by avg_drowth desc limit 3 ;

-- Find the bottom 3 states taht showing lowest sex ratio
select State,avg(sex_ratio) as avg_sex_ratio
from Dataset1
group by State
order by avg_sex_ratio limit 3;

-- list the districts where the growth rate is above national avgerage
select District,State,Growth
from Dataset1
where Growth > (select avg(Growth) as avg_growth from Dataset1);


-- create one table that contain top and bottom 5 state that giving literacy ratio
drop table if exists Top5;
create table Top5(State varchar(50),
				  li_ratio float);
insert into Top5 
select State,avg(literacy) as avg_literacy_ratio 
from Dataset1 
group by State 
order by avg_literacy_ratio desc;
select * from Top5 order by Top5.li_ratio desc limit 5;  -- this giving top 5 states by hieght literacy ratio

drop table if exists Bottom5;
create table Bottom5(State varchar(50),
				  li_ratio float);
insert into Bottom5 
select State,avg(literacy) as avg_literacy_ratio 
from Dataset1 
group by State 
order by avg_literacy_ratio ;
select * from Bottom5 order by Bottom5.li_ratio  limit 5; -- this giving bottom 5 states by lowest literacy ratio

-- to join both table we will use union operator
select * from (select * from Top5 order by Top5.li_ratio desc limit 5) as a
union
select * from (select * from Bottom5 order by Bottom5.li_ratio  limit 5) as b;

-- join the two tabels
select s.District,s.State,s.Sex_Ratio,p.Population
from Dataset1 as s
inner join Dataset2 as p
on(s.District=p.District);
 
-- join the two tables and in that calculate districtwise no_of_males and no_of_females in seperate col
select a.District,a.State ,(Population/(Sex_Ratio+1)) as no_of_males ,((Population*Sex_Ratio)/(Sex_Ratio+1)) as no_of_females
from (select s.District,s.State,s.Sex_Ratio/1000 as Sex_Ratio,p.Population from Dataset1 as s inner join Dataset2 as p on(s.District=p.District)) as a; 

-- -- join the two tables and in that calculate statewise total_males and total_females in seperate col
select d.State,sum(d.no_of_males) as total_males,sum(d.no_of_females) as total_feMales from
(select a.District,a.State ,(Population/(Sex_Ratio+1)) as no_of_males ,((Population*Sex_Ratio)/(Sex_Ratio+1)) as no_of_females     
from (select s.District,s.State,s.Sex_Ratio/1000 as Sex_Ratio,p.Population from Dataset1 as s inner join Dataset2 as p on(s.District=p.District)) as a) as d
group by d.State;

-- calculate statewise total_literate and total_illiterate people
select  b.State,sum(b.literate_people) as total_literate_people,sum(b.illiterate_people) as total_illiterate_people
from(select s.State,round((s.Literacy / 100 * p.Population),0) as literate_people,round(((1 - s.Literacy / 100) * p.Population),0) as illiterate_people
from Dataset1 as s
inner join 
Dataset2 as p
on s.District = p.District) as b
group by b.State;

-- Find the population of previous census
select a.State,sum(pre_census_pop) as total_pre_pop,sum(cur_census_pop) as total_cur_pop from
(select s.District,s.State,s.Growth,round(p.Population/(1+s.Growth*100),0) as pre_census_pop,p.Population as cur_census_pop from Dataset1 as s inner join Dataset2 as p) as a
group by a.State;  

-- Find the statewise top 3 district that giving hiegst literacy ratio
select a.* from
(select District,State,Literacy,rank() over(partition by State order by Literacy desc) as rnk from Dataset1 )as a
where a.rnk in (1,2,3);

-- calculate percentage of state's population that each district contributes 
select a.district, a.state, 
       (a.population / b.total_population) * 100 as population_percentage
from Dataset2 as a
join (select state, sum(population) as total_population
    from Dataset2
    group by state) as b 
    using(state);




