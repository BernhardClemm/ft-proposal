# ==============================================================================
# file name: ep-uncertainty-plot.R
# authors: Bernhard Clemm
# date: 1 Nov 2023
# ==============================================================================

# SETUP ========================================================================

library(tidyverse)
library(rstatix)
library(survey)
path <- paste0(dirname(dirname(rstudioapi::getSourceEditorContext()$path)), "/")

# DATA =========================================================================

ep_proj_ger_00 <- read.csv(paste0(path, "data/ft-ep-projections-GER.csv"))

# WEIGHTED AVERAGE WITH UNCERTAINTY ============================================

## create weights ####
## I do not know the FT weighting procedure for EP elections. For the US elections:
## "We calculate poll averages ... using an exponential decay formula..."
## I assume a decay parameter r of 5% per day: raw_weight = (1 - 0.05)^n_days
## I normalize these weights so they sum to 1
## (with more time, one could reverse-engineer the decay factor, 
## but difficult given the rounded numbers)

ep_proj_ger_01 <- ep_proj_ger_00 %>%
  filter(!grepl("FT", .$house)) %>%
  mutate(id = row_number()) %>%
  mutate(date = as.Date(date, format = "%d/%m/%y"),
         last_date = as.Date("2019-05-23"),
         day_diff = as.numeric(last_date - date)) %>%
  mutate(weight_raw = (1 - 0.05)^day_diff) %>%
  mutate(sum_weights_raw = sum(weight_raw)) %>%
  mutate(weight = weight_raw / sum_weights_raw)

## compute weighted average and SE ####
## this simple approach can be approved by incorporating information on
## - sample size provided by survey companies
## - uncertainty provided by survey companies

design <- svydesign(id = ~id, weights = ~weight, data = ep_proj_ger_01)

ep_proj_ger_02 <- data.frame(
  group = c("epp", "greens", "sd", "efdd", "new", "gue", "alde"),
  mean = c(
    svymean(~epp, design), 
    svymean(~greens, design),
    svymean(~sd, design),
    svymean(~efdd, design),
    svymean(~new, design),
    svymean(~gue, design),
    svymean(~alde, design)),
  se = c(
    SE(svymean(~epp, design)), 
    SE(svymean(~greens, design)),
    SE(svymean(~sd, design)),
    SE(svymean(~efdd, design)),
    SE(svymean(~new, design)),
    SE(svymean(~gue, design)),
    SE(svymean(~alde, design))))

# PLOT =========================================================================

ep_proj_ger_03 <- ep_proj_ger_02 %>%
  mutate(ci_low = mean - 1.96*se,
         ci_high = mean + 1.96*se) %>%
  # create labels for bars
  mutate(label = paste0(round(mean, 0), " ± ", round(1.96*se, 1)))
  
colors <- c("#ffe033", "#217a9d", "#58aafc", "#321079", 
           "#8deb9d", "#991c00", "#f95f5f", "white")
names(colors) <- c("alde", "ecr", "efdd", "epp", "greens", "gue", "sd", "new")

ep_proj_ger_03 %>% 
  ggplot(aes(y = mean, x = reorder(group, mean), fill = group)) +
  geom_crossbar(aes(ymin = ci_low, ymax = ci_high), width = 0.8, size = 0.3) +
  geom_vline(xintercept = seq(1.5, 7, by = 1), color="gray", size=.4, alpha=.5) +
  geom_text(aes(label = label), size = 3,
            hjust = c(-0.6, -0.4, -0.5, -0.5, -0.5, -0.3, -0.5)) +
  ggtitle("(b) Germany EP projections 2019") +
  scale_fill_manual(values = colors) +
  scale_y_continuous(limits = c(0, 35)) +
  coord_flip() +
  theme(
    axis.text.x = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.background = element_blank(),
    panel.grid = element_blank(),
    legend.position = "none")

ggsave(file = paste0(path, "output/ep-projections-ger.png"),
       height = 5, width = 6.5)

