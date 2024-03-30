-- Covid Deaths Analysis

select * from Portfolio_Project..CovidDeaths$
where continent is not null
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths$
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in India

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from Portfolio_Project..CovidDeaths$
where location like '%India%' and continent is not null
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, total_cases,population, 
(total_deaths / population) * 100 AS CasePercentage
from Portfolio_Project..CovidDeaths$
--where location like '%India%'
where continent is not null
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

select location,population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as CasePercentage
from Portfolio_Project..CovidDeaths$
where continent is not null
group by location, population
order by CasePercentage desc;

-- Showing Countries with Highest Death Count per Population

select location,population, max(cast(total_deaths as int)) as DeathRate, max((total_deaths/population))*100 as DeathPercentage
from Portfolio_Project..CovidDeaths$
where continent is not null
group by location, population
order by DeathPercentage desc;

-- Showing death rate by Continents 

select continent, max(cast(total_deaths as int)) as DeathRate
from Portfolio_Project..CovidDeaths$
group by continent
order by DeathRate desc;

-- Showing continents with the highest death count per population

select continent, sum(population) as Total_Population, sum(CONVERT(float, total_deaths)) as Deaths, (sum(CONVERT(float, total_deaths)) / sum(population)) *100 as DeathRate_PerContinent
from Portfolio_Project..CovidDeaths$
group by continent
order by DeathRate_PerContinent desc;

-- Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int)) / sum(new_cases)) * 100 as DeathPercentage
from Portfolio_Project..CovidDeaths$
where continent is not null
--group by date
order by 1,2;

-- Covid Vacctination Analysis


-- Looking at Total Population vs Vaccinations
select death.continent,death.location,death.date, death.population,vac.new_vaccinations,SUM(convert(bigint, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ death join Portfolio_Project..CovidVaccination$ vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
order by 2,3;

with PopVsVac(continent,location, Date, Population,New_Vaccinatins,RollingPeopleVaccinated)
as
(
select death.continent,death.location,death.date, death.population,vac.new_vaccinations,SUM(convert(bigint, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ death join Portfolio_Project..CovidVaccination$ vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 as Vaccinated_Percentage from PopVsVac
order by 1,2,3;

--Temp Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select death.continent,death.location,death.date, death.population,vac.new_vaccinations,SUM(convert(bigint, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ death join Portfolio_Project..CovidVaccination$ vac
on death.location = vac.location and death.date = vac.date
--where death.continent is not null

select *,(RollingPeopleVaccinated/Population)*100 as Vaccinated_Percentage from #PercentPopulationVaccinated
order by 1,2,3;

-- Creating view to store date for later visualization

create view PercentPopulationVaccinated as
select death.continent,death.location,death.date, death.population,vac.new_vaccinations,SUM(convert(bigint, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ death join Portfolio_Project..CovidVaccination$ vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null;

select * from PercentPopulationVaccinated;