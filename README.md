## BFCM Challenge 2024, Track II

Goal: Predict hourly email sends for Klaviyo throughout BFCM. Lowest SMAPE wins a prize!

Method: The simplest thing I could think of:

1. Estimate the year-over-year growth rate in email sends based on the average year-over-year growth rate for the days leading up to BFCM
2. Use the previous year's series times the forecasted growth rate
3. Do it all in 45 lines of SQL with DuckDB

## Running this solution

You'll need two things to run this "model":

1. You'll need to [set up DuckDB](https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=macos&download_method=package_manager)
2. You'll need to have the historical data saved to `historicals.csv`
