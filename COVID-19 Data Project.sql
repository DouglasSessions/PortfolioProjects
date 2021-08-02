--The data we are going to be using

select *
From [COVID-19 Data Project]..COVID_Data
order by 1,2

--Overview of data

Select Location, date, total_cases, new_cases, total_deaths, new_deaths, icu_patients, hosp_patients, total_tests, new_tests, population, median_age, life_expectancy 
From [COVID-19 Data Project]..COVID_Data
Where continent is not null 
order by 1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [COVID-19 Data Project]..COVID_Data
Where location like '%states%'
order by 1,2

--Total Cases vs Population
--Shows percentage of population that got COVID

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/population)*100 as DeathPercentage
From [COVID-19 Data Project]..COVID_Data
--Where location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From [COVID-19 Data Project]..COVID_Data
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--This is showing countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [COVID-19 Data Project]..COVID_Data
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Death Count by Continent
--Showing Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [COVID-19 Data Project]..COVID_Data
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
--Worldwide Death Percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [COVID-19 Data Project]..COVID_Data
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [COVID-19 Data Project]..CovidDeaths dea
Join [COVID-19 Data Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [COVID-19 Data Project]..CovidDeaths dea
Join [COVID-19 Data Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

--DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [COVID-19 Data Project]..CovidDeaths dea
Join [COVID-19 Data Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating Views to store data for later visualizations 


--if having permission trouble use
--GRANT SELECT ON DeathCountbyContinent TO public

CREATE VIEW DeathCountbyContinent
as
	select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
	From [COVID-19 Data Project]..COVID_Data
	Where continent is not null
	Group by continent
--order by TotalDeathCount desc

--This is showing countries with the highest death count per population

CREATE VIEW DeathCountbyCountry as
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [COVID-19 Data Project]..COVID_Data
Where continent is not null
Group by Location
--order by TotalDeathCount desc

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

CREATE VIEW DeathPercentageUSA as
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [COVID-19 Data Project]..COVID_Data
Where location like '%states%'
--order by 1,2



--Total Cases vs Population
--Shows percentage of population that got COVID

CREATE VIEW PercentPopulationInfected as
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/population)*100 as DeathPercentage
From [COVID-19 Data Project]..COVID_Data
--Where location like '%states%'
--order by 1,2