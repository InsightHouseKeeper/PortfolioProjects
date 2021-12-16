Select *
From PortfolioProject.dbo.CovidDeaths$
Where continent Is Not Null
Order By 3, 4

--Select *
--From PortfolioProject.dbo.CovidVaccinations$
--Order By 3, 4

/* Select variables */
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Where continent Is Not Null
Order By 1, 2

/* 
Total Cases VS. Total Deaths 
	; Likelihood of fatality in each country
*/
Select location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where continent Is Not Null And Location Like '%united states%'
Order By 1, 2

/*
Total Cases Vs. Population
	; Percentage of Covid cases 
*/
Select location, date, population, total_cases, (total_cases/population) * 100 as CasePercentage
From PortfolioProject.dbo.CovidDeaths$
Where continent Is Not Null
--Where Location Like '%States%'
Order By 1, 2

/*
Countries with highest infection-case percentage
*/
Select location, population, Max(total_cases) As MaxInfactionCount, Max(total_cases/population) * 100 as MaxInfectionPercentage
From PortfolioProject.dbo.CovidDeaths$
Where continent Is Not Null
--Where Location Like '%Korea%'
Group By location, population
Order By 4 Desc

/*
Countries with highest death case 
	; The data is daily updated
	; continent titles on location-variable has total contient's value.
		continent-var is additional information for individual countries
		so, if you want to work with continent related information,
		use the continent-titles in location-var.

*/
Select location, Max(Cast(Total_deaths as int)) as MaxDeathCount
From PortfolioProject.dbo.CovidDeaths$
Where continent Is Not Null
--Where Location Like '%Korea%'
Group By location
Order By 2 Desc

/*
	; By continent
	; continent titles in the "location" is correct
*/
Select location, Max(Cast(Total_deaths as int)) as MaxDeathCount
From PortfolioProject.dbo.CovidDeaths$
Where continent Is Null and location Not Like '%income%'
--Where Location Like '%Korea%'
Group By location
Order By 2 Desc

/*
continents with the hightest death rate per population
*/
--Select continent, Max(Cast(Total_deaths as int)) as MaxDeathCount
--From PortfolioProject.dbo.CovidDeaths$
--Where continent Is Not Null 
--Group By continent
--Order By 2 Desc

/*
Global-level Numbers
*/
Select date, Sum(new_cases) As global_total_cases, Sum(cast(new_deaths as int)) as global_total_deaths,
	Sum(cast(New_deaths as int)) / Sum(New_Cases)*100 as global_death_rate
From PortfolioProject.dbo.CovidDeaths$
Where continent Is Not Null
--Where Location Like '%united states%'
Group By date
Order By 1, 2

Select Sum(new_cases) As global_total_cases, Sum(cast(new_deaths as int)) as global_total_deaths,
	Sum(cast(New_deaths as int)) / Sum(New_Cases)*100 as global_death_rate
From PortfolioProject.dbo.CovidDeaths$
Where continent Is Not Null
--Where Location Like '%united states%'
--Group By date
Order By 1, 2

/*
	; total vaccination rate per total population
	; overflow!, use bigint(...long?)
*/
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
	, Sum(Convert(bigint, VAC.new_vaccinations)) Over (Partition by DEA.location Order by DEA.location, DEA.date) As accumulated_vaccinations
	--,(accumulated_vaccinations / population) * 100)
From PortfolioProject.dbo.CovidDeaths$ DEA
Join PortfolioProject.dbo.CovidVaccinations$ VAC
	On DEA.location = VAC.location and DEA.date = VAC.date
Where DEA.continent Is Not Null --and  DEA.location Like '%united states%'
Order By 2, 3

/*
CTE(common table expression)
*/
With PopVsVac ( continent, location, date, population,new_vaccinations, acculated_vaccinations)
As(
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
	, Sum(Convert(bigint, VAC.new_vaccinations)) Over (Partition by DEA.location Order by DEA.location, DEA.date) As accumulated_vaccinations
	--,(accumulated_vaccinations / population) * 100)
From PortfolioProject.dbo.CovidDeaths$ DEA
Join PortfolioProject.dbo.CovidVaccinations$ VAC
	On DEA.location = VAC.location and DEA.date = VAC.date
Where DEA.continent Is Not Null 
--Order By 2, 3
)
Select *, (acculated_vaccinations / population) * 100
From PopVsVac


/*Temp Table*/

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
accumulated_vaccinations numeric
)

Insert into #PercentPopulationVaccinated

Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
	, Sum(Convert(bigint, VAC.new_vaccinations)) Over (Partition by DEA.location Order by DEA.location, DEA.date) As accumulated_vaccinations
From PortfolioProject.dbo.CovidDeaths$ DEA
Join PortfolioProject.dbo.CovidVaccinations$ VAC
	On DEA.location = VAC.location and DEA.date = VAC.date
Where DEA.continent Is Not Null 

Select *, (accumulated_vaccinations / population) * 100
From #PercentPopulationVaccinated

/*Creat view to store data */

Create View PercentPopulationVaccinated as
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
	, Sum(Convert(bigint, VAC.new_vaccinations)) Over (Partition by DEA.location Order by DEA.location, DEA.date) As accumulated_vaccinations
From PortfolioProject.dbo.CovidDeaths$ DEA
Join PortfolioProject.dbo.CovidVaccinations$ VAC
	On DEA.location = VAC.location and DEA.date = VAC.date
Where DEA.continent Is Not Null 


Select *
From PercentPopulationVaccinated