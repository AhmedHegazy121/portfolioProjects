select *
 from PortiolioProject .. coviedDeaths
order by 3 ,4
select * 
from PortiolioProject .. ConvidVaccinations
order by 3 ,4

 select  location, date  , total_cases , new_cases , total_deaths , population
 from PortiolioProject .. coviedDeaths
 order by 1,2


 alter table PortiolioProject .. coviedDeaths 
 alter column  total_deaths int 
 alter table PortiolioProject .. coviedDeaths 
 alter column  total_cases int 


 select  location, date  , total_cases , population, (total_cases /population)*100 as  percentpopulationinfected
 from PortiolioProject .. coviedDeaths
 --where location like '%states%'
 order by 1,2


 select  location, population, max (total_cases) as HighestinfectionCount ,  max((total_cases /population))*100 
 as percentpopulationinfected
 from PortiolioProject .. coviedDeaths
 --where location like '%states%'
 where location is not null
 group by location, population
 order by  percentpopulationinfected desc

 select  location , max(cast (total_deaths as int))as TotalDeathCount
 from PortiolioProject .. coviedDeaths
 --where location like '%states%'
 where location is not null
 group by location
 order by TotalDeathCount  desc

 select  continent , max (cast (total_deaths as int))as TotalDeathCount
 from PortiolioProject .. coviedDeaths
 --where location like '%states%'
 where continent is not null
 group by continent
 order by TotalDeathCount  desc


  
 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
 SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortiolioProject .. coviedDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

 select dea.continent ,dea.location, dea.date, dea.population ,vac.new_vaccinations 
 ,sum(convert( float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as countvaccinations
 from PortiolioProject..CoviedDeaths dea 
 join PortiolioProject.. ConvidVaccinations vac 
 on dea.location =vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 -- to know how many people had taken vaccentation 
 with popvsvac (continent , location , date , population, new_vacccinations, countvaccinations) as
 (
 select dea.continent ,dea.location, dea.date, dea.population ,vac.new_vaccinations 
 ,sum(convert( float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as countvaccinations
 from PortiolioProject..CoviedDeaths dea 
 join PortiolioProject.. ConvidVaccinations vac 
 on dea.location =vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select * ,(countvaccinations / population)*100 as whotakevac
 from popvsvac
 --order by whotakevac desc
   -- creating view to store data later visualiza
   create view percentpopultionVaccinated as
   select dea.continent ,dea.location, dea.date, dea.population ,vac.new_vaccinations 
 ,sum(convert( float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as countvaccinations
 from PortiolioProject..CoviedDeaths dea 
 join PortiolioProject.. ConvidVaccinations vac 
 on dea.location =vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 select * 
 from percentpopultionVaccinated 
