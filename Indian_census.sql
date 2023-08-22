-- total no of rows in the dataset
SELECT count(*) FROM dataset1;

-- Datasets for Jharkhand and Bihar

select * from dataset1 where state in ('Jharkhand' , 'Bihar');

-- Total population of India

select sum(population) as Population from dataset2 ;

-- Average growth per state

select state, avg(Growth) avg_growth from dataset1 group by state;

-- Average sex ratio per state

select state,round( avg(Sex_Ratio), 0 ) as avg_sex_ratio from dataset1 group by state order by avg_sex_ratio desc;

-- Average literacy rate per state and states with Literacy rate greater than 90

/* part 1 */
select state,round( avg(Literacy), 0 ) as avg_Literacy from dataset1 group by state  order by avg_Literacy desc;

/* part 2 */
select state,round( avg(Literacy), 0 ) as avg_Literacy from dataset1 
group by state having avg_Literacy > 90 order by avg_Literacy desc;

-- Top 3 states showing highest growth rate

select state, avg(Growth) avg_growth from dataset1 group by state order by avg_growth desc limit 3;

-- Bottom 3 states showing lowest sex ratio 

select state,round( avg(Sex_Ratio), 0 ) as avg_sex_ratio from dataset1 group by state order by avg_sex_ratio asc limit 3;

-- top and bottom 3 states in literacy rate

drop table if exists topstates;
create table topstates 
( state text,
topstates float ) ;

insert into topstates
select state,round( avg(Literacy), 0 ) as avg_Literacy from dataset1 group by state  order by avg_Literacy desc limit 3;

select * from topstates;

drop table if exists bottomstates;
create table bottomstates 
( state text,
bottomstates float ) ;

insert into bottomstates
select state,round( avg(Literacy), 0 ) as avg_Literacy from dataset1 group by state  order by avg_Literacy asc limit 3;

select * from bottomstates;

-- union operator

select state, topstates as top_and_bottom_states from (
select * from topstates
union
select * from bottomstates) a;

-- states starting with letter 'a' or 'b'

select distinct state from dataset1 where lower(state) like 'a%' or lower(state) like 'b%';

-- Determining the number of males and females in a population by using sex ration and population

select District , state, Population , round(Population/(Sex_Ratio + 1 )) as Males , round((Population*Sex_Ratio)/(Sex_Ratio + 1)) as Females from 
(select a.District , a.state , (a.Sex_Ratio/1000) as Sex_Ratio, b.Population from dataset1 a inner join dataset2 b on a.District = b.District ) c ;

-- aggregated males and females 
create table sex_of_population as (
select state , sum(Population) as Population , sum(Males) as Males , sum(Females) as Females from 
(select District , state, Population , round(Population/(Sex_Ratio + 1 )) as Males , round((Population*Sex_Ratio)/(Sex_Ratio + 1)) as Females from 
(select a.District , a.state , (a.Sex_Ratio/1000) as Sex_Ratio, b.Population from dataset1 a inner join dataset2 b on a.District = b.District ) c ) d group by state);

-- literacy rate

select state , sum(Population) as Population , sum(Total_Literate) as Literate , sum(Total_Illiterate) as Illiterate from (
select District, state , Population , round((Literacy_Rate*Population)) as Total_Literate , round((1 - Literacy_Rate )*Population) as Total_Illiterate from
(select a.District , a.state , (a.Literacy/100) as Literacy_Rate , b.Population from dataset1 a inner join dataset2 b on a.District = b.District) a ) b 
group by state;

-- Using growth rate to calculate population for previous year
create table current_vs_previous as (
select sum(b.Previous_Year_population) as Previous_census, sum(b.Current_Year_Census) as Current_census from 
(select  district, state , round((Population/(1 + Growth_Rate))) as Previous_Year_population , Population) as Current_Year_Census from
(select a.District , a.state , round((a.Growth/100),4) as Growth_Rate , b.Population from dataset1 a inner join dataset2 b on a.District = b.District) a 
) b ) ;


-- Population vs area

select total_area/Previous_census , total_area/Current_census from
(select d.* , e.total_area from 
(select '1' as keyy , c.* from
(select sum(b.Previous_Year_population) as Previous_census, sum(b.Current_Year_Census) as Current_census from 
(select  district, state , round((Population/(1 + Growth_Rate))) as Previous_Year_population , Population as Current_Year_Census from
(select a.District , a.state , round((a.Growth/100),4) as Growth_Rate , b.Population from dataset1 a inner join dataset2 b on a.District = b.District) a 
) b ) c ) d inner join

(select '1' as keyy , sum(Area_km2) as total_area from dataset2 ) e on d.keyy = e.keyy ) f;

select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from dataset1 a inner join dataset2 b on a.district=b.district) d) e
group by e.state)m;

-- Window 	
-- rank over top 3 states with highest literacy rates

select * from
(select district, state , Literacy, rank() over( partition by state order by Literacy desc ) as rnk from dataset1)a
where rnk in (1,2,3);

-- rank over highest literacy rate for each state

select state, rnk ,round( avg(Literacy), 2) as avg_Literacy from 
(select district, state , Literacy, rank() over(  order by Literacy desc ) as rnk from dataset1)a
 group by state order by state;
 
