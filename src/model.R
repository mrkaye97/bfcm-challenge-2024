library(tidyverse)
library(googlesheets4)

YEAR_TO_PREDICT <- 2024

data <- read_sheet(Sys.getenv("GOOGLE_SHEET_URL"))

PREDICTED_GROWTH_RATES <- data %>%
  group_by(days_to_black_friday, hour) %>%
  mutate(
    previous = lag(num_emails, n = 1, order_by = year),
    yoy_change = (num_emails / previous - 1) * 100
  ) %>%
  ungroup() %>%
  filter(
    between(yoy_change, -50, 100),
    between(days_to_black_friday, -25, 5)
  ) %>%
  drop_na() %>%
  group_by(year) %>%
  summarize(yoy_change = 1 + mean(yoy_change) / 100, .groups = "drop") %>%
  deframe() %>%
  as.list()

data <- data %>%
  filter(days_to_black_friday %in% 0:3) %>%
  select(
    year,
    days_to_black_friday,
    hour,
    num_emails
  )

forecast <- data %>%
  filter(year == YEAR_TO_PREDICT - 1) %>%
  mutate(num_emails = round(num_emails * PREDICTED_GROWTH_RATES[[as.character(YEAR_TO_PREDICT)]]), year = YEAR_TO_PREDICT) %>%
  arrange(days_to_black_friday, hour)


plot <- data %>%
  filter(year < YEAR_TO_PREDICT) %>%
  bind_rows(forecast) %>%
  mutate(
    time = days_to_black_friday * 24 + hour,
    year = as_factor(year),
    is_forecast = year == YEAR_TO_PREDICT,
    num_emails = num_emails / 1000000
  ) %>%
  arrange(days_to_black_friday, hour) %>%
  ggplot(aes(x = time, y = num_emails, color = year, linetype = is_forecast)) +
  geom_line() +
  scale_linetype_manual(values = c("solid", "dashed")) +
  xlab("Hours From Black Friday (Midnight Start)") +
  ylab("Emails Sent (Millions)") +
  labs(
    color = "Year",
    linetype = "Is Forecast"
  )

write_csv(forecast, glue::glue("forecast/{YEAR_TO_PREDICT}/forecast.csv"))
ggplot2::ggsave(
  glue::glue("forecast/{YEAR_TO_PREDICT}/plot.png"),
  plot,
  width = 18,
  height = 12
)
