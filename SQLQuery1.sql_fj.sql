SELECT *
FROM ProjectPortfolio..CovidVaccination$
where continent is not null
order by 3, 4


select *
from ProjectPortfolio..DeathByCovid$
order by 3, 4


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from ProjectPortfolio..DeathByCovid$
where continent is not null 
order by 1, 2

select location, date, total_cases, population,(total_cases/population)*100 as covid_percentage
from ProjectPortfolio..DeathByCovid$
where location like '%india%'and continent is not null
order by 1, 2


select location, population, max(total_cases)as covid_infected,max(total_cases/population)*100 as covid_percentage
from ProjectPortfolio..DeathByCovid$
where continent is not null
Group by location, population
order by covid_infected desc


select continent, max(cast(Total_deaths as int)) as Death_rate
from ProjectPortfolio..DeathByCovid$
where continent is not null
group by continent
order by Death_rate desc    



select SUM(new_cases)as new_cases, SUM(cast(new_deaths as int))as new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percen_num
from ProjectPortfolio..DeathByCovid$
where continent is not null
--group by date
order by 1, 2



select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
  sum(convert(int,vaccine.new_vaccinations )) over(partition by death.location order by death.location, death.date) as cumulative_vaccine
from ProjectPortfolio..DeathByCovid$ death
join ProjectPortfolio..CovidVaccination$ vaccine
	on death.location = vaccine.location
	and death.date =vaccine.date
where death.continent is not null
order by 2, 3


with populationvsvaccine (continent, location, date, population, new_vaccinations, cumulative_vaccine)
as
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
  sum(convert(int,vaccine.new_vaccinations )) over(partition by death.location order by death.location, death.date) as cumulative_vaccines
--(cumulative_vaccine/population)*100
from ProjectPortfolio..DeathByCovid$ death
join ProjectPortfolio..CovidVaccination$ vaccine 
	on death.location = vaccine.location
	and death.date =vaccine.date
where death.continent is not null
--order by 2, 3
)


select *, (cumulative_vaccine/population)*100 as cumulative_population_vaccine
from populationvsvaccine


select continent,date,location,(weekly_hosp_admissions/population)*100 as hospital_admission_percentage
from ProjectPortfolio..DeathByCovid$
where continent is not null

Drop table if exists #populationpercentagevaccine
Create Table #populationpercentagevaccine
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
cumulative_all_vaccine numeric 
)
Insert into #populationpercentagevaccine 
  select death.Continent, death.location, death.Date, death.Population, vaccine.New_vaccinations, 
	sum(cast(vaccine.new_vaccinations as bigint)) over(partition by death.location order by death.location, death.date) as cumulative_all_vaccine
  --(cumulative_vaccine/population)*100
FROM ProjectPortfolio..DeathByCovid$ death
JOIN ProjectPortfolio..CovidVaccination$ vaccine
	on death.location = vaccine.location
	and death.date =vaccine.date
--where death.continent like '%asisa%'
--order by 2, 3

select *, (cumulative_all_vaccine/population)*100 as c_percentage
from #populationpercentagevaccine

Create view populationpercentagevaccined as 
select death.Continent, death.location, death.Date, death.Population, vaccine.New_vaccinations, 
	sum(cast(vaccine.new_vaccinations as bigint)) over(partition by death.location order by death.location, death.date) as cumulative_all_vaccine
  --(cumulative_vaccine/population)*100
FROM ProjectPortfolio..DeathByCovid$ death
JOIN ProjectPortfolio..CovidVaccination$ vaccine
	on death.location = vaccine.location
	and death.date =vaccine.date
where death.continent is not null
--order by 2, 3

select *
from populationpercentagevaccined

