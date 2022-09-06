drop table coviddeath
create table Coviddeath(
iso_code varchar,
continent varchar,
loca_tion varchar,
	start_date date,
	population bigint,
	total_cases bigint,
	new_cases bigint,
	new_case_smoothed decimal,
	total_deaths bigint,
	new_deaths bigint,
	new_deaths_smoothed decimal,
	total_cases_per_million decimal,
	new_cases_smoothed_per_million decimal,
	total_deaths_per_million decimal,
	new_deaths_per_million decimal,
	new_deaths_smoothed_per_million decimal,
	reproduction_rate decimal,
	icu_patients decimal,
	icu_patients_per_million decimal,
	hosp_patients decimal,
	hosp_patients_per_million decimal,
	weekly_icu_admissions decimal,
	weekly_icu_admissions_per_million decimal,
	weekly_hosp_admissions decimal,
	weekly_hosp_admissions_per_million decimal,
	u decimal
);

copy  coviddeath from 'F:\SQL\data2\CovidDeaths(Solve).csv' delimiter ','csv header ;
select * from coviddeath;
drop table covidvacine;
create table covidvacine(
iso_code varchar,
	continent varchar,
	loca_tion varchar,
	start_date date,
	new_test bigint,
	total_tests bigint,
	total_test_per_thousand decimal,
	new_test_per_thousand decimal,
	new_test_smoothed bigint,
	new_test_smoothed_per_thousand decimal,
	positive_rate decimal,
	test_per_case decimal,
	test_unit varchar,
	total_vaccinations bigint,
	people_vaccinated bigint,
	people_fully_vacinated bigint,
	new_vaccinations bigint,
	new_vaccinations_smoothed bigint,
	total_vaccinations_per_hundred decimal,
	people_vaccinated_per_hundred decimal,
	people_fully_vaccinated_per_hundred decimal,
	new_vaccinaton_smoothed_per_million decimal,
	stringency_index decimal,
	population_density decimal,
	median_age decimal,
	age_65_older decimal,
	age_70_older decimal,
	gdp_per_captia decimal,
	extreme_poverty decimal,
	cardiovasc_death_rate decimal,
	diabetes_prevalence decimal,
	female_smokers decimal,
	male_smokers decimal,
	handwashing_facilities decimal,
	hospital_beds_per_thousands decimal,
	life_expectancy decimal,
	human_development_index decimal
	
);
copy covidvacine from 'F:\SQL\data2\CovidVacinations(Solve).csv' delimiter ',' csv header;

--select data we are going to be use
select loca_tion,start_date,total_cases,new_cases,total_deaths,population from coviddeath
order by loca_tion,start_date;

--Looking at total cases vs total deaths
select loca_tion,start_date,total_cases,total_deaths,(total_deaths/cast(total_cases as float))*100  as percentage_death from coviddeath
order by 1,2;





--Shows likelihood of dying if you contract covid in our country
select loca_tion,start_date,total_cases,total_deaths,(total_deaths/cast(total_cases as float))*100 as death_percentage from coviddeath
where loca_tion like '%States%'
order by 1,2;

--Looking at total cases vs population
--Shows what percentage of population get covid
select loca_tion,start_date,total_cases,population,(total_cases/cast(population as float))*100 as population_percent from coviddeath
--where loca_tion like '%States%'
order by 1,2;

--Looking at countries with highest infection rate compared to population
select loca_tion, max(total_cases), population ,max((total_cases/cast(population as float))*100) as casepercent from coviddeath
group by loca_tion,population
order by casepercent desc;

--Showing countries with the highest death count per population
select loca_tion,max(cast(total_deaths as bigint)) as TotalDeathCounts from coviddeath
where continent is not null and total_deaths is not null
group by loca_tion
order by TotalDeathCounts desc;

select loca_tion,max(cast(total_deaths as bigint)) as TotalDeathCounts from coviddeath
where continent is  null and total_deaths is not null
group by loca_tion
order by TotalDeathCounts desc;

--Let's break things down by continent
--Showing Continent with highest death rate
select continent,max(cast(total_deaths as bigint)) as TotalDeathCounts from coviddeath
where continent is not null and total_deaths is not null
group by continent
order by TotalDeathCounts desc;

--Global numbers
select start_date,sum(new_cases) as total_case ,sum(cast(new_deaths as bigint)) , sum(cast(new_deaths as bigint))/sum(new_cases)*100 as deathpercentage from coviddeath
where continent is not null
group by start_date
order by 1,2;


select sum(new_cases) as total_case ,sum(cast(new_deaths as bigint)) , sum(cast(new_deaths as bigint))/sum(new_cases)*100 as deathpercentage from coviddeath
where continent is not null
order by 1,2;

--Start of covidvacine
select d.continent,d.loca_tion,d.start_date,d.population,v.new_vaccinations,sum(v.new_vaccinations)over(partition by d.loca_tion order by d.loca_tion , d.start_date) as RollingPeopleVaccinated from coviddeath as d
right join covidvacine as v
on d.loca_tion = v.loca_tion and d.start_date=v.Start_date
where d.continent is not null
order by 2,3;

--Use CTE
with popvsVac(continent,loca_tion,start_date,population,new_vaccinations,RollingPeopleVaccinated)
as
(select d.continent,d.loca_tion,d.start_date,d.population,v.new_vaccinations,sum(v.new_vaccinations)over(partition by d.loca_tion order by d.loca_tion , d.start_date) as RollingPeopleVaccinated from coviddeath as d
right join covidvacine as v
on d.loca_tion = v.loca_tion and d.start_date=v.Start_date
where d.continent is not null
--order by 2,3;
)

select * ,(RollingPeopleVaccinated/population)*100 from popvsVac;



--Temp Table
drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated(
continent varchar,
	loca_tion varchar,
	start_date date,
	population bigint,
	New_vaccinations bigint,
	RollingPeopleVaccinated bigint
);

insert into PercentPopulationVaccinated(
select d.continent,d.loca_tion,d.start_date,d.population,v.new_vaccinations,sum(v.new_vaccinations)over(partition by d.loca_tion order by d.loca_tion , d.start_date) as RollingPeopleVaccinated from coviddeath as d
right join covidvacine as v
on d.loca_tion = v.loca_tion and d.start_date=v.Start_date
where d.continent is not null
--order by 2,3;
);

select *  , (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;

--Creating view to store data for later visualization
drop view if exists PercentPopulationVacinated;
create view  PercentPopulationVacinated  as
(select d.continent,d.loca_tion,d.start_date,d.population,v.new_vaccinations,sum(v.new_vaccinations)over(partition by d.loca_tion order by d.loca_tion , d.start_date) as RollingPeopleVaccinated from coviddeath as d
right join covidvacine as v
on d.loca_tion = v.loca_tion and d.start_date=v.Start_date
where d.continent is not null
--order by 2,3;
)
select * from PercentPopulationVacinated;



