# ==============================================================================
# file name: uk-polltracker-plot.R
# authors: Bernhard Clemm
# date: 21 Jan 2023
# ==============================================================================

# PACKAGES =====================================================================

library(tidyverse)
library(Hmisc)
path <- paste0(dirname(dirname(rstudioapi::getSourceEditorContext()$path)), "/")

# DATA =========================================================================

uk_polls_00 <- read.csv("http://bertha.ig.ft.com/view/publish/dsv/1qDuVHfUgoWnPSUNUDeXLaHfV33RuAPsNC-S1S0tDeKI/data.csv")

# RECODING =====================================================================

uk_polls_01 <- uk_polls_00 %>% 
  # dates into date format
  mutate(across(c(mdate, sdate, edate), ~ as.Date(.))) %>%
  # exclude unused rows
  filter(house != "" & house != "General election") %>% 
  # combine different values for Survation
  mutate(house = ifelse(grepl("Survation", .$house), "Survation", house)) %>%
  # turn to lower case and remove spaces
  mutate(house = tolower(gsub(" ", "_", .$house)))

# CREATE ROLLING AVERAGE AND SE ================================================

## "The trend line uses only the most recent poll from each pollster 
## and weights them according to when they were conducted."
## for simplicity, I just use the ten most recent polls

uk_polls_02 <- uk_polls_01 %>%
  select(house, mdate, con, lab, lib, snppc, brx, grn) %>%
  pivot_longer(con:grn, names_to = "party", values_to = "percent") %>% 
  ungroup() %>% arrange(mdate, house)

uk_polls_03 <- uk_polls_02 %>%
  group_by(mdate, house) %>% 
  mutate(poll_id = cur_group_id()) %>%
  group_by(party) %>% 
  mutate(
    percent_lag1 = lag(percent, 1, order_by = poll_id), 
    percent_lag2 = lag(percent, 2, order_by = poll_id),
    percent_lag3 = lag(percent, 3, order_by = poll_id),
    percent_lag4 = lag(percent, 4, order_by = poll_id),
    percent_lag5 = lag(percent, 5, order_by = poll_id),
    percent_lag6 = lag(percent, 6, order_by = poll_id), 
    percent_lag7 = lag(percent, 7, order_by = poll_id),
    percent_lag8 = lag(percent, 8, order_by = poll_id),
    percent_lag9 = lag(percent, 9, order_by = poll_id),
    percent_lag10 = lag(percent, 10, order_by = poll_id),
    ) %>%
  ungroup()

## create weights ####
## I do not know the UK weighting procedure for EP elections. For the US elections:
## "We calculate poll averages ... using an exponential decay formula..."
## I assume a decay parameter r of 10% per day: raw_weight = (1 - 0.10)^n_days

uk_polls_weights <- uk_polls_03 %>%
  select(poll_id, mdate, house) %>% distinct() %>%
  mutate(
    mdate_lag1 = lag(mdate, 1, order_by = poll_id), 
    mdate_lag2 = lag(mdate, 2, order_by = poll_id),
    mdate_lag3 = lag(mdate, 3, order_by = poll_id),
    mdate_lag4 = lag(mdate, 4, order_by = poll_id),
    mdate_lag5 = lag(mdate, 5, order_by = poll_id),
    mdate_lag6 = lag(mdate, 6, order_by = poll_id), 
    mdate_lag7 = lag(mdate, 7, order_by = poll_id),
    mdate_lag8 = lag(mdate, 8, order_by = poll_id),
    mdate_lag9 = lag(mdate, 9, order_by = poll_id),
    mdate_lag10 = lag(mdate, 10, order_by = poll_id)) %>%
  pivot_longer(mdate_lag1:mdate_lag10, names_to = "lag", values_to = "lag_date") %>%
  # compute the difference in days to 5 previous polls
  mutate(lag_day_diff = as.numeric(mdate - lag_date)) %>%
  # create weight according to decay formula
  mutate(lag_weight = (1 - 0.10)^lag_day_diff) %>%
  select(poll_id, mdate, house, lag, lag_weight) %>%
  pivot_wider(names_from = "lag", values_from = "lag_weight") 

## join weights to polls ####

uk_polls_04 <- uk_polls_03 %>%
  left_join(., uk_polls_weights %>% 
              select(-c(house, mdate)),
            by = "poll_id")

## create weighted mean and SE ####
## there is some debate about how to compute SE of weighted mean:
## https://www.alexstephenson.me/post/2022-04-02-weighted-variance-in-r/
## https://seismo.berkeley.edu/~kirchner/Toolkits/Toolkit_12.pdf
## I rely on the Hmisc functions, but the below can be improved.

uk_polls_05 <- uk_polls_04 %>% 
  mutate(
    percent_mean = apply(
      uk_polls_04, 1, 
      function(x) wtd.mean(x = as.numeric(x[6:15]), weights = as.numeric(x[16:25]))),
    percent_se = apply(
      uk_polls_04, 1, 
      function(x) sqrt(wtd.var(x = as.numeric(x[6:15]), weights = as.numeric(x[16:25])))))

# HOUSE WEIGHTS ================================================================

## only for illustration purposes, create random sample sizes
## these do not factor into computation of trend line

uk_polls_06 <- uk_polls_05 %>% 
  group_by(house) %>% mutate(sample_size = round(rnorm(1, 2500, 200))) %>%
  ungroup()
  
# PLOT =========================================================================

uk_polls_plot <- uk_polls_06 %>%
  filter(mdate > "2019-01-01") %>%
  select(house, sample_size, mdate, percent, party, percent_mean, percent_se) %>%
  mutate(across(percent_mean:percent_se, ~ ifelse(is.na(percent), NA, .))) %>%
  mutate(ci_low = percent_mean - 1.96*percent_se,
         ci_high = percent_mean + 1.96*percent_se)

colors <- c("blue1", "brown1", "darkgoldenrod1", "yellow2", 
            "cyan2", "springgreen2")
names(colors) <- c("con", "lab", "lib", "snppc", "brx", "grn")

uk_polls_plot %>% 
  ggplot(aes(x = mdate, y = percent, group = party, color = party)) +
  geom_point(aes(size = sample_size), alpha = 0.4) + 
  scale_size(range = c(0.05, 3)) +
  geom_line(aes(y = percent_mean), size = 1) + 
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high, fill = party), alpha = 0.1, colour = NA) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  scale_color_manual(values = colors) +
  scale_fill_manual(values = colors) +
  ggtitle("(a) UK poll tracker 2019") +
  theme_light() +
  theme(
    axis.title = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none")

ggsave(file = paste0(path, "output/uk-polltracker.png"),
       height = 5, width = 9)






  

