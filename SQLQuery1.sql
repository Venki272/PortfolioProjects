--select * from PortfolioProject..CovidDeaths order by total_cases desc 2,3,4;

--select * from PortfolioProject..CovidVaccinations order by 2,3,4;

--select Location, CalendarDate, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths order by 1,2;

--TOTAL CASES vs TOTAL DEATHS
select Location, convert(date,CalendarDate,110) as Date, 
isnull(total_cases,0) as TotalCases, isnull(total_deaths,0) as TotalDeaths, 
round(isnull((cast(total_deaths as float)/total_cases),0),4)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where Location like '%United%States%' 
order by 1,2;

--TOTAL CASES vs POPULATION
select Location, CalendarDate, isnull(total_cases,0) as TotalCases, Population, 
round(isnull((cast(total_cases as float)/population),0),5)*100 as AffectedPercentage
from PortfolioProject..CovidDeaths 
where Location like '%United%States%' 
order by 1,2;

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
select Location, Population, max(isnull(total_cases,0)) as HighestInfectionCount,
round(max(isnull(cast(total_cases as float),0)/population),4)*100 as AffectedRate
from PortfolioProject..CovidDeaths 
group by Location, Population
order by AffectedRate desc;

--COUNTRIES WITH HIGHEST DEATH RATE COMPARED TO POPULATION
select Location, Population, max(isnull(total_deaths,0)) as HighestDeathCount,
round(max(isnull(cast(total_deaths as float),0)/population),4)*100 as DeathRate
from PortfolioProject..CovidDeaths 
group by Location, Population
order by DeathRate desc;

--DEATH TO INFECTION RATIO
select CalendarDate as Date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,
round(isnull(sum(cast(new_deaths as float))/nullif(sum(new_cases),0),0),4)*100 as DeathInfectionRatio
from PortfolioProject..CovidDeaths 
group by CalendarDate
order by DeathInfectionRatio desc;

--USING CTE - CUMMULATIVE COUNT OF VACCINATIONS PER LOCATION (COUNTRY)
With VacCountperLoc as 
(
select cd.Continent, cd.Location, cd.CalendarDate as Date, cd.Population, isnull(cv.New_Vaccinations,0) as NewVaccinations, 
sum(isnull(cv.New_Vaccinations,0)) over (partition by cd.location order by cd.calendardate) as CummulativeVaccinationsCount
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location 
and cd.CalendarDate = cv.CalendarDate
)
select *, round(cast(CummulativeVaccinationsCount as float)/Population,4)*100 as VaccinatedPercentage
from VacCountperLoc
order by 2,3; 

--USING TEMP TABLE - CUMMULATIVE COUNT OF VACCINATIONS PER LOCATION (COUNTRY)
drop table if exists #VacCountperLoc;
create table #VacCountperLoc
(
Continent nvarchar(255),
Location nvarchar(255),
CalendarDate datetime,
Population numeric(38,0),
New_Vaccinations numeric(38,0),
CummulativeVaccinationsCount numeric(38,0)
);

insert into #VacCountperLoc
select cd.Continent, cd.Location, cd.CalendarDate as Date, cd.Population, isnull(cv.New_Vaccinations,0) as NewVaccinations, 
sum(isnull(cv.New_Vaccinations,0)) over (partition by cd.location order by cd.calendardate) as CummulativeVaccinationsCount
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location 
and cd.CalendarDate = cv.CalendarDate;

select *, round(cast(CummulativeVaccinationsCount as float)/Population,4)*100 as VaccinatedPercentage
from #VacCountperLoc
order by 2,3;

--VIEW - TO STORE THE CUMMULATIVE VACCINATIONS DATA
drop view if exists CummulativeVaccinationsData;
go

Create view CummulativeVaccinationsData as
select cd.Continent, cd.Location, cd.CalendarDate as Date, cd.Population, isnull(cv.New_Vaccinations,0) as NewVaccinations, 
sum(isnull(cv.New_Vaccinations,0)) over (partition by cd.location order by cd.calendardate) as CummulativeVaccinationsCount
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location 
and cd.CalendarDate = cv.CalendarDate;
























