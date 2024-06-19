		-- Here is the the selected data to be used
		select [location],      -- Location of the record
		continent,     -- continent of the record
		date,          -- Date of the record
		total_cases,   -- Total cases involved in the record
		new_cases,     -- New cases involved in the record
		total_deaths,  -- Total deaths involved in the record
		population     -- Population of the record
		from portfolioproject..deaths
		where continent is not null
		order by location, date;


		-- Examining Total cases VS Total deaths
		-- showing possibility of death if you contracted covid in your country ( Nigeria)
		select location,
		continent,
		date,         
		total_cases,
		total_deaths,
		CAST(total_deaths AS INT)/CAST(total_cases AS INT) * 100   -- Total deaths divided by total cases = Death percentage
		as [death percentage]
		from portfolioproject..deaths
		-- where location like 'nigeria%' 
		where total_cases is not null and continent is not null
		order by location, date;


		-- Examining Total cases VS Population
		-- Showing the percentage of population that contracted covid in a country
		select location,
		continent,
		date,         
		total_cases,
		population,
		CAST(total_cases AS INT)/(population) * 100 as [percentage population]
		from portfolioproject..deaths
		-- where location like 'nigeria%' 
		where total_cases is not null and continent is not null
		order by location, date;


		-- Countries with the highest infection rate while compared to population
		select location,    
		population,
		max(CAST(total_cases AS INT)) as [highest infection count],
		max(CAST(total_cases AS INT)/(population)) * 100 as [percentage population infected]
		from portfolioproject..deaths
		-- where location like 'nigeria%' 
		where total_cases is not null and continent is not null
		group by location, population
		order by [percentage population infected] desc;


		-- Countries with highest Death count per population

		select location,
		max(total_deaths)  as [total death count]
		from portfolioproject..deaths
		where total_cases is not null and continent is not null
		group by location
		order by [total death count] desc;


		-- Continent with highest Death count per population

		select continent,
		max(total_deaths)  as [total death count]
		from portfolioproject..deaths
		where total_cases is not null and continent is not null
		group by continent
		order by [total death count] desc;


		-- Global Numbers

		select   sum(new_cases) as [TOTAL CASES],
			sum(cast(new_deaths as int)) as TOTAL_DEATHS,
			sum(cast(new_deaths as int))/ sum(new_cases) as DEATH_PERCENTAGE
		from portfolioproject.dbo.deaths
		-- where location like 'nigeria%' 
		where total_cases is not null and continent is not null
		-- group by `date`, (total_deaths)/(total_cases) * 100, total_deaths
		
		--Total population vs Vaccination
		
		With main_cte as
		(
		select A.continent, 
		A.location,
		A.date, 
		A.population, 
		B.new_vaccinations,
		sum(CONVERT(float, B.NEW_VACCINATIONS)) OVER (PARTITION BY A.LOCATION ORDER BY A.LOCATION, A.DATE) as rolling_people_vaccinated
		from portfolioproject..deaths A
		join portfolioproject..vaccinations B
		on A.location = B.location
		AND A.date = B.date
		where a.continent is not null
		--ORDER BY  A.location, A.date
		)
		select *, (rolling_people_vaccinated/population) * 100 as [percentage vaccinated]
		from main_cte


		--TEM TABLE

		Create table #PercentPopulationVaccinated
		(
		Continent			nvarchar(255),
		location			nvarchar(255),
		date				datetime,
		population			numeric,
		new_vaccinations	numeric,
		rolling_people_vaccinated numeric
		)

		insert into #PercentPopulationVaccinated
		select A.continent, 
		A.location,
		A.date, 
		A.population, 
		B.new_vaccinations,
		sum(CONVERT(float, B.NEW_VACCINATIONS)) OVER (PARTITION BY A.LOCATION ORDER BY A.LOCATION, A.DATE) as rolling_people_vaccinated
		from portfolioproject..deaths A
		join portfolioproject..vaccinations B
		on A.location = B.location
		AND A.date = B.date
		where a.continent is not null
		--ORDER BY  A.location, A.date

		select *, (rolling_people_vaccinated/population) * 100 as [percentage vaccinated]
		from #PercentPopulationVaccinated

		-- VIEW TO STORE DATA FOR LATER VISUALIZATIONS
		CREATE VIEW PercentPopulationVaccinated AS
		select A.continent, 
		A.location,
		A.date, 
		A.population, 
		B.new_vaccinations,
		sum(CONVERT(float, B.NEW_VACCINATIONS)) OVER (PARTITION BY A.LOCATION ORDER BY A.LOCATION, A.DATE) as rolling_people_vaccinated
		from portfolioproject..deaths A
		join portfolioproject..vaccinations B
		on A.location = B.location
		AND A.date = B.date
		where a.continent is not null
		--ORDER BY  A.location, A.date