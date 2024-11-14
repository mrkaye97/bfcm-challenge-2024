library(tidyverse)

data <- read_csv("data/historicals.csv") %>%
  filter(days_to_black_friday %in% 0:4) %>%
  mutate(
    hour = as_factor(hour)
  ) %>%
  select(
    year,
    days_to_black_friday,
    hour,
    num_emails
  )

predicted_growth <- data %>%
  group_by(days_to_black_friday, hour) %>%
  mutate(yoy_change = num_emails / lag(num_emails, order_by=year)) %>%
  filter(year < 2024) %>%
  drop_na() %>%
  ungroup() %>%
  group_by(year) %>%
  summarize(avg_yoy_change = mean(yoy_change)) %>%
  ungroup() %>%
  summarize(avg_yoy_change = sum(case_when(year == 2022 ~ 0.3, year == 2023 ~ 0.7) * avg_yoy_change)) %>%
  pull(avg_yoy_change)

data <- data %>%
  filter(days_to_black_friday %in% 0:4)

forecast <- data %>%
  filter(year < 2024) %>%
  group_split(year) %>%
  map_dfr(
    . %>%
      mutate(
        num_emails = case_when(
          year == 2021 ~ 0.1,
          year == 2022 ~ 0.3,
          year == 2023 ~ 0.6
        ) * num_emails * (1.43 ** (2024 - year))
      ) %>%
      select(
        hour, days_to_black_friday, num_emails
      )
  ) %>%
  group_by(hour, days_to_black_friday) %>%
  summarize(num_emails = sum(num_emails), .groups="drop") %>%
  mutate(year = 2024)

data %>%
  filter(year < 2024) %>%
  bind_rows(forecast) %>%
  mutate(
    time = days_to_black_friday * 24 + as.numeric(hour),
    year = as_factor(year)
  ) %>%
  arrange(days_to_black_friday, hour) %>% 
  ggplot(aes(x=time, y=num_emails, color=year)) +
  geom_line()

