SET VARIABLE TARGET_YEAR = 2024;
SET VARIABLE PREVIOUS_YEAR = GETVARIABLE('TARGET_YEAR') - 1;

WITH raw AS (
    SELECT
        *,
        100 * (num_emails :: FLOAT / LAG(num_emails, 1) OVER (PARTITION BY days_to_black_friday, hour ORDER BY year) - 1) AS yoy_change
    FROM read_csv(
        'historicals.csv',
        delim = ',',
        header = true,
        columns = {
            'year': 'INTEGER',
            'month': 'INTEGER',
            'day': 'INTEGER',
            'hour': 'INTEGER',
            'num_emails': 'INTEGER',
            'days_to_black_friday': 'INTEGER'
        }
    )
), forecasted_growth AS (
    SELECT year, 1 + AVG(yoy_change) / 100 AS growth_rate
    FROM raw
    WHERE
        yoy_change BETWEEN -50 AND 100 -- clean up outliers
        AND days_to_black_friday BETWEEN -25 AND -2 -- Smooth using the average growth rate from the three weeks leading up to BFCM
    GROUP BY year
)

SELECT
    GETVARIABLE('TARGET_YEAR') AS year,
    days_to_black_friday,
    hour,
    ROUND(num_emails * growth_rate) AS num_emails
FROM raw r
JOIN forecasted_growth g ON r.year = g.year - 1
WHERE
    r.year = GETVARIABLE('PREVIOUS_YEAR') -- Use previous year's data as the base
    AND days_to_black_friday BETWEEN 0 AND 3
ORDER BY 1, 2, 3
