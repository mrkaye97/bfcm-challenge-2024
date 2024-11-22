## BFCM Challenge 2024, Track II

Goal: Predict hourly email sends for Klaviyo throughout BFCM. Lowest SMAPE wins a prize!

Method: The simplest thing I could think of:

1. Estimate the year-over-year growth rate in email sends based on the average year-over-year growth rate for the days leading up to BFCM
2. Use the previous year's series * the forecasted growth rate
