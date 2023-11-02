# ==============================================================================
# file name: ep-projections-acc.R
# authors: Bernhard Clemm
# date: 31 Oct 2023
# ==============================================================================

# SETUP ========================================================================

library(tidyverse)
path <- paste0(dirname(dirname(rstudioapi::getSourceEditorContext()$path)), "/")

# TOTALS =======================================================================

## data ####

ep_totals_proj_00 <- read.csv(paste0(path, "data/ft-ep-totals-projections.csv"))
ep_totals_res_00 <- read.csv(paste0(path, "data/ft-ep-totals-results.csv"))

## recoding ####
ep_totals_proj_01 <- ep_totals_proj_00 %>%
  rename("seats_proj" = n_seats) %>%
  mutate(group_name = case_when(
    group_name %in% c("ALDE", "RE")  ~ "ALDE/RE",
    group_name %in% c("ENF", "ID")  ~ "ENF/ID",
    TRUE ~ as.character(group_name)))

ep_totals_res_01 <- ep_totals_res_00 %>%
  rename("seats_res" = n_seats) %>%
  mutate(group_name = case_when(
    group_name %in% c("ALDE", "RE")  ~ "ALDE/RE",
    group_name %in% c("ENF", "ID")  ~ "ENF/ID",
    group_name == "Greens/EFA"  ~ "Greens EFA",
    group_name == "GUE/NGL"  ~ "GUE NGL",
    TRUE ~ as.character(group_name)))

## join projections/results ####

ep_totals <- ep_totals_proj_01 %>%
  left_join(., ep_totals_res_01, by = c("group_name")) %>% 
  # Ignore Non-inscrits, newcomers and efdd, as unclear whether fair comparison
  filter(!group_name %in% c("NI", "New", "EFDD")) %>%
  mutate(
    e = seats_res - seats_proj,
    ae = abs(seats_res - seats_proj)) %>%
  mutate(name = "Totals")

## Results ####

### Mean absolute error on group level

mean(ep_totals$ae, na.rm = T)

### Plot

ep_totals_plot <- ep_totals %>% 
  ggplot(aes(y = e, x = group_name, fill = group_name)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(
    values = c("#ffe033", "#217a9d", "#58aafc", "#321079", 
               "#8deb9d", "#991c00", "#f95f5f")) +
  scale_y_continuous(name = "Projection error (in seats)") +
  facet_wrap(~name) +
  theme_light() +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.position = "bottom")

ggsave(file = paste0(path, "output/ep-totals-accuracy.png"),
       height = 5, width = 6.5)

# COUNTRIES ====================================================================

## data ####

ep_proj_00 <- read.csv(paste0(path, "data/ft-ep-countries-projections.csv"))
ep_res_00 <- read.csv(paste0(path, "data/ft-ep-countries-results.csv"))

## recoding ####

### projections

ep_proj_01 <- ep_proj_00 %>%
  mutate(across(epp:re, ~ as.numeric(gsub(" \\(.*\\)", "", .))))

## sum UK regions and Belgium, as these are just one row each in results
## do this separately, because here we want to ignore NA (but not for the rest of data)
ep_proj_uk <- ep_proj_01 %>%
  filter(name == "United Kingdom") %>%
  select(-c(new, id, re)) %>%
  group_by(name) %>%
  dplyr::summarize(across(epp:enf, ~ sum(., na.rm = TRUE)))
ep_proj_be <- ep_proj_01 %>%
  filter(name == "Belgium") %>%
  select(-c(efdd, gue, ni, id, re)) %>%
  group_by(name) %>%
  dplyr::summarize(across(epp:enf, ~ sum(., na.rm = TRUE)))

ep_proj_02 <- ep_proj_01 %>%
  filter(!name %in% c("United Kingdom", "Belgium")) %>%
  bind_rows(., ep_proj_uk) %>%
  bind_rows(., ep_proj_be) %>%
  select(-subname)

ep_proj_l <- ep_proj_02 %>%
  pivot_longer(epp:re, names_to = "group", values_to = "seats_proj") %>%
  filter(!is.na(seats_proj))
  
### results 

ep_res_01 <- ep_res_00 %>%
  mutate(across(epp:re, ~ as.numeric(gsub(" \\(.*\\)", "", .)))) %>%
  select(-subname)

ep_res_l <- ep_res_01 %>%
  pivot_longer(epp:re, names_to = "group", values_to = "seats_res") %>%
  filter(!is.na(seats_res)) 

## harmonize group names and ignore certain groups ####
## RE = ALDE and ID = ENF

ep_res_l <- ep_res_l %>% 
  mutate(group = case_when(
    group == "re" ~ "alde/re",
    group == "id" ~ "enf/id",
    TRUE ~ as.character(group)))

ep_proj_l <- ep_proj_l %>% 
  mutate(group = case_when(
    group == "alde" ~ "alde/re",
    group == "enf" ~ "enf/id",
    TRUE ~ as.character(group)))

## Ignore Non-inscrits, newcomers and efdd, as unclear whether fair comparison

ep_res_l <- ep_res_l %>% 
  filter(!group %in% c("ni", "new", "efdd"))

ep_proj_l <- ep_proj_l %>% 
  filter(!group %in% c("ni", "new", "efdd"))

## join projections ####

ep <- ep_proj_l %>%
  left_join(., ep_res_l, by = c("name", "group")) %>%
  mutate(
    e = seats_res - seats_proj,
    ae = abs(seats_res - seats_proj))

## Results ####

### Mean absolute error on group-country level

mean(ep$ae, na.rm = T)

### plot

e_plot <- ep %>% ggplot(aes(y = e, x = group, fill = group)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(
    values = c("#ffe033", "#217a9d", "#58aafc", "#321079", 
               "#8deb9d", "#991c00", "#f95f5f")) +
  scale_y_continuous(name = "Projection error (in seats)") +
  facet_wrap(~name, nrow = 4) +
  theme_light() +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.position = "bottom")

ggsave(file = paste0(path, "output/ep-country-accuracy.png"),
       height = 8, width = 9)










