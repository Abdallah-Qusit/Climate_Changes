--1)How pollution changes each year for each country
SELECT
    country_name,
    year,
    pm25_concentration,
    LAG(pm25_concentration) OVER (PARTITION BY country_name ORDER BY year) AS prev_year_pm25,
    pm25_concentration -
    LAG(pm25_concentration) OVER (PARTITION BY country_name ORDER BY year) AS yoy_change
FROM AirQuality_cleaned2;


--2)shows long-term trend(3 years)
SELECT
    country_name,
    year,
    pm25_concentration,
    AVG(pm25_concentration) OVER (
        PARTITION BY country_name
        ORDER BY year
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3yr_avg
FROM AirQuality_cleaned2;


--3)Which country had the most deaths each year
WITH summed AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
)
SELECT
    country,
    year,
    total_deaths,
    RANK() OVER (PARTITION BY year ORDER BY total_deaths DESC) AS rank_by_deaths
FROM summed;


--4)Top 5 worst air-quality countries annually
WITH aggregated AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25 
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
),
ranked AS (
    SELECT
        country_name,
        year,
        avg_pm25,
        DENSE_RANK() OVER (PARTITION BY year ORDER BY avg_pm25 DESC) AS pollution_rank
    FROM aggregated
)
SELECT *
FROM ranked
WHERE pollution_rank <= 5;



--5)Simple correlation indicator
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
),
aq AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
)
SELECT
    d.country,
    d.year,
    d.total_deaths,
    aq.avg_pm25,
    (d.total_deaths * 1.0) / NULLIF(aq.avg_pm25, 0) AS deaths_per_pm25_unit
FROM deaths_agg d
JOIN aq
    ON d.country = aq.country_name
    AND d.year = aq.year;


--6)Did deaths rise or fall?
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
)
SELECT
    country,
    year,
    total_deaths,
    LAG(total_deaths) OVER (PARTITION BY country ORDER BY year) AS prev_year_deaths,
    total_deaths - LAG(total_deaths) OVER (PARTITION BY country ORDER BY year) AS yoy_change_deaths
FROM deaths_agg
ORDER BY country, year;



--7)Distribution of air-quality risk levels.
SELECT
    CASE
        WHEN pm25_concentration > 35 THEN 'High'
        WHEN pm25_concentration > 15 THEN 'Moderate'
        ELSE 'Low'
    END AS pollution_category,
    COUNT(*) AS num_records
FROM AirQuality_cleaned2
GROUP BY
    CASE
        WHEN pm25_concentration > 35 THEN 'High'
        WHEN pm25_concentration > 15 THEN 'Moderate'
        ELSE 'Low'
    END;


--8)Shows how extreme a country's death count is compared to others
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
)
SELECT
    country,
    year,
    total_deaths AS deaths,
    PERCENT_RANK() OVER (PARTITION BY year ORDER BY total_deaths) AS death_percentile
FROM deaths_agg
ORDER BY year, country;



--9)High-level country health summary
SELECT
    d.country,
    AVG(d.value) AS avg_deaths,
    AVG(a.pm25_concentration) AS avg_pm25,
    SUM(d.value) AS total_deaths,
    MAX(a.pm25_concentration) AS max_pm25
FROM [cleaned_health_data-1] d
JOIN AirQuality_cleaned2 a
    ON d.country = a.country_name
    AND d.year = a.year
GROUP BY d.country;


--10)Shows countries whose pollution risk changed year-to-year.
WITH pollution_agg AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
),
pollution_category AS (
    SELECT
        country_name,
        year,
        avg_pm25,
        CASE
            WHEN avg_pm25 > 35 THEN 'High'
            WHEN avg_pm25 > 15 THEN 'Moderate'
            ELSE 'Low'
        END AS category
    FROM pollution_agg
),
category_change AS (
    SELECT
        country_name,
        year,
        category,
        LAG(category) OVER (PARTITION BY country_name ORDER BY year) AS prev_category
    FROM pollution_category
)
SELECT *
FROM category_change
WHERE category <> prev_category
ORDER BY country_name, year;
 --1)How pollution changes each year for each country
SELECT
    country_name,
    year,
    pm25_concentration,
    LAG(pm25_concentration) OVER (PARTITION BY country_name ORDER BY year) AS prev_year_pm25,
    pm25_concentration -
    LAG(pm25_concentration) OVER (PARTITION BY country_name ORDER BY year) AS yoy_change
FROM AirQuality_cleaned2;


--2)shows long-term trend(3 years)
SELECT
    country_name,
    year,
    pm25_concentration,
    AVG(pm25_concentration) OVER (
        PARTITION BY country_name
        ORDER BY year
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3yr_avg
FROM AirQuality_cleaned2;


--3)Which country had the most deaths each year
WITH summed AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
)
SELECT
    country,
    year,
    total_deaths,
    RANK() OVER (PARTITION BY year ORDER BY total_deaths DESC) AS rank_by_deaths
FROM summed;


--4)Top 5 worst air-quality countries annually
WITH aggregated AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25 
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
),
ranked AS (
    SELECT
        country_name,
        year,
        avg_pm25,
        DENSE_RANK() OVER (PARTITION BY year ORDER BY avg_pm25 DESC) AS pollution_rank
    FROM aggregated
)
SELECT *
FROM ranked
WHERE pollution_rank <= 5;



--5)Simple correlation indicator
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
),
aq AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
)
SELECT
    d.country,
    d.year,
    d.total_deaths,
    aq.avg_pm25,
    (d.total_deaths * 1.0) / NULLIF(aq.avg_pm25, 0) AS deaths_per_pm25_unit
FROM deaths_agg d
JOIN aq
    ON d.country = aq.country_name
    AND d.year = aq.year;


--6)Did deaths rise or fall?
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
)
SELECT
    country,
    year,
    total_deaths,
    LAG(total_deaths) OVER (PARTITION BY country ORDER BY year) AS prev_year_deaths,
    total_deaths - LAG(total_deaths) OVER (PARTITION BY country ORDER BY year) AS yoy_change_deaths
FROM deaths_agg
ORDER BY country, year;



--7)Distribution of air-quality risk levels.
SELECT
    CASE
        WHEN pm25_concentration > 35 THEN 'High'
        WHEN pm25_concentration > 15 THEN 'Moderate'
        ELSE 'Low'
    END AS pollution_category,
    COUNT(*) AS num_records
FROM AirQuality_cleaned2
GROUP BY
    CASE
        WHEN pm25_concentration > 35 THEN 'High'
        WHEN pm25_concentration > 15 THEN 'Moderate'
        ELSE 'Low'
    END;


--8)Shows how extreme a country's death count is compared to others
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
)
SELECT
    country,
    year,
    total_deaths AS deaths,
    PERCENT_RANK() OVER (PARTITION BY year ORDER BY total_deaths) AS death_percentile
FROM deaths_agg
ORDER BY year, country;



--9)High-level country health summary
SELECT
    d.country,
    AVG(d.value) AS avg_deaths,
    AVG(a.pm25_concentration) AS avg_pm25,
    SUM(d.value) AS total_deaths,
    MAX(a.pm25_concentration) AS max_pm25
FROM [cleaned_health_data-1] d
JOIN AirQuality_cleaned2 a
    ON d.country = a.country_name
    AND d.year = a.year
GROUP BY d.country;


--10)Shows countries whose pollution risk changed year-to-year.
WITH pollution_agg AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
),
pollution_category AS (
    SELECT
        country_name,
        year,
        avg_pm25,
        CASE
            WHEN avg_pm25 > 35 THEN 'High'
            WHEN avg_pm25 > 15 THEN 'Moderate'
            ELSE 'Low'
        END AS category
    FROM pollution_agg
),
category_change AS (
    SELECT
        country_name,
        year,
        category,
        LAG(category) OVER (PARTITION BY country_name ORDER BY year) AS prev_category
    FROM pollution_category
)
SELECT *
FROM category_change
WHERE category <> prev_category
ORDER BY country_name, year;
--1)How pollution changes each year for each country
SELECT
    country_name,
    year,
    pm25_concentration,
    LAG(pm25_concentration) OVER (PARTITION BY country_name ORDER BY year) AS prev_year_pm25,
    pm25_concentration -
    LAG(pm25_concentration) OVER (PARTITION BY country_name ORDER BY year) AS yoy_change
FROM AirQuality_cleaned2;


--2)shows long-term trend(3 years)
SELECT
    country_name,
    year,
    pm25_concentration,
    AVG(pm25_concentration) OVER (
        PARTITION BY country_name
        ORDER BY year
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3yr_avg
FROM AirQuality_cleaned2;


--3)Which country had the most deaths each year
WITH summed AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
)
SELECT
    country,
    year,
    total_deaths,
    RANK() OVER (PARTITION BY year ORDER BY total_deaths DESC) AS rank_by_deaths
FROM summed;


--4)Top 5 worst air-quality countries annually
WITH aggregated AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25 
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
),
ranked AS (
    SELECT
        country_name,
        year,
        avg_pm25,
        DENSE_RANK() OVER (PARTITION BY year ORDER BY avg_pm25 DESC) AS pollution_rank
    FROM aggregated
)
SELECT *
FROM ranked
WHERE pollution_rank <= 5;



--5)Simple correlation indicator
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
),
aq AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
)
SELECT
    d.country,
    d.year,
    d.total_deaths,
    aq.avg_pm25,
    (d.total_deaths * 1.0) / NULLIF(aq.avg_pm25, 0) AS deaths_per_pm25_unit
FROM deaths_agg d
JOIN aq
    ON d.country = aq.country_name
    AND d.year = aq.year;


--6)Did deaths rise or fall?
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
)
SELECT
    country,
    year,
    total_deaths,
    LAG(total_deaths) OVER (PARTITION BY country ORDER BY year) AS prev_year_deaths,
    total_deaths - LAG(total_deaths) OVER (PARTITION BY country ORDER BY year) AS yoy_change_deaths
FROM deaths_agg
ORDER BY country, year;



--7)Distribution of air-quality risk levels.
SELECT
    CASE
        WHEN pm25_concentration > 35 THEN 'High'
        WHEN pm25_concentration > 15 THEN 'Moderate'
        ELSE 'Low'
    END AS pollution_category,
    COUNT(*) AS num_records
FROM AirQuality_cleaned2
GROUP BY
    CASE
        WHEN pm25_concentration > 35 THEN 'High'
        WHEN pm25_concentration > 15 THEN 'Moderate'
        ELSE 'Low'
    END;


--8)Shows how extreme a country's death count is compared to others
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
)
SELECT
    country,
    year,
    total_deaths AS deaths,
    PERCENT_RANK() OVER (PARTITION BY year ORDER BY total_deaths) AS death_percentile
FROM deaths_agg
ORDER BY year, country;



--9)High-level country health summary
SELECT
    d.country,
    AVG(d.value) AS avg_deaths,
    AVG(a.pm25_concentration) AS avg_pm25,
    SUM(d.value) AS total_deaths,
    MAX(a.pm25_concentration) AS max_pm25
FROM [cleaned_health_data-1] d
JOIN AirQuality_cleaned2 a
    ON d.country = a.country_name
    AND d.year = a.year
GROUP BY d.country;


--10)Shows countries whose pollution risk changed year-to-year.
WITH pollution_agg AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
),
pollution_category AS (
    SELECT
        country_name,
        year,
        avg_pm25,
        CASE
            WHEN avg_pm25 > 35 THEN 'High'
            WHEN avg_pm25 > 15 THEN 'Moderate'
            ELSE 'Low'
        END AS category
    FROM pollution_agg
),
category_change AS (
    SELECT
        country_name,
        year,
        category,
        LAG(category) OVER (PARTITION BY country_name ORDER BY year) AS prev_category
    FROM pollution_category
)
SELECT *
FROM category_change
WHERE category <> prev_category
ORDER BY country_name, year;



--11)Which countries show the largest improvement (decrease) in PM2.5 levels over their full available timeline.
WITH yearly AS (
    SELECT 
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
),
diff AS (
    SELECT
        country_name,
        FIRST_VALUE(avg_pm25) OVER (PARTITION BY country_name ORDER BY year) AS first_value,
        LAST_VALUE(avg_pm25) OVER (
            PARTITION BY country_name 
            ORDER BY year
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_value
    FROM yearly
)
SELECT DISTINCT
    country_name,
    first_value,
    last_value,
    (first_value - last_value) AS improvement_amount
FROM diff
ORDER BY improvement_amount DESC;

--12)Which age group has the highest average death count across all countries and years.
SELECT
    age,
    AVG(value) AS avg_deaths,
    SUM(value) AS total_deaths
FROM [cleaned_health_data-1]
GROUP BY age
ORDER BY avg_deaths DESC;


--13)How does the relationship between total deaths and PM2.5 change year by year.
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
),
pollution AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
),
combined AS (
    SELECT
        d.country,
        d.year,
        d.total_deaths,
        p.avg_pm25,
        (d.total_deaths * 1.0) / NULLIF(p.avg_pm25, 0) AS correlation_factor
    FROM deaths_agg d
    JOIN pollution p
        ON d.country = p.country_name
       AND d.year = p.year
)
SELECT 
    year,
    AVG(correlation_factor) AS yearly_correlation_index
FROM combined
GROUP BY year
ORDER BY year;

--14)Which countries have the highest death rates within each WHO region? (Top 3 per region).
WITH deaths_agg AS (
    SELECT
        country,
        year,
        SUM(value) AS total_deaths
    FROM [cleaned_health_data-1]
    GROUP BY country, year
),
total AS (
    SELECT 
        country,
        AVG(total_deaths) AS avg_deaths
    FROM deaths_agg
    GROUP BY country
)
SELECT 
    a.who_region,
    t.country,
    t.avg_deaths,
    DENSE_RANK() OVER (
        PARTITION BY a.who_region
        ORDER BY t.avg_deaths DESC
    ) AS region_rank
FROM AirQuality_cleaned2 a
JOIN total t 
    ON a.country_name = t.country
GROUP BY a.who_region, t.country, t.avg_deaths
HAVING DENSE_RANK() OVER (
        PARTITION BY a.who_region
        ORDER BY t.avg_deaths DESC
    ) <= 3
ORDER BY a.who_region, region_rank;


--15)Which countries have the highest long-term pollution risk score (PM2.5 × population).
WITH yearly AS (
    SELECT
        country_name,
        year,
        AVG(pm25_concentration) AS avg_pm25,
        AVG(population) AS population
    FROM AirQuality_cleaned2
    GROUP BY country_name, year
),
risk AS (
    SELECT
        country_name,
        year,
        (avg_pm25 * population) AS risk_score
    FROM yearly
)
SELECT
    country_name,
    AVG(risk_score) AS long_term_risk
FROM risk
GROUP BY country_name
ORDER BY long_term_risk DESC;
