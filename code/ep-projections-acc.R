# ==============================================================================
# file name: ep-projections-acc.R
# authors: Bernhard Clemm
# date: 31 Oct 2023
# ==============================================================================

# SETUP ========================================================================

library(tidyverse)
path <- paste0(dirname(dirname(rstudioapi::getSourceEditorContext()$path)), "/")

# DATA =========================================================================

ep_proj_00 <- read.csv(paste0(path, "data/ft-ep-projections.csv"))
ep_res_00 <- read.csv(paste0(path, "data/ft-ep-results.csv"))

# RECODING =====================================================================

# projections ####
ep_proj_01 <- ep_proj_00 %>%
  mutate(across(epp:re, ~ as.numeric(gsub(" \\(.*\\)", "", .))))

## sum UK regions and Belgium, as these are just one row each in results
## do this separately, because here we want to ignore NA (but not for the rest of data)
ep_proj_uk <- ep_proj_01 %>%
  filter(name == "United Kingdom") %>%
  select(-c(new, id, re)) %>%
  group_by(name) %>%
  summarize(across(epp:enf, ~ sum(., na.rm = TRUE)))
ep_proj_be <- ep_proj_01 %>%
  filter(name == "Belgium") %>%
  select(-c(efdd, gue, ni, id, re)) %>%
  group_by(name) %>%
  summarize(across(epp:enf, ~ sum(., na.rm = TRUE)))

ep_proj_02 <- ep_proj_01 %>%
  filter(!name %in% c("United Kingdom", "Belgium")) %>%
  bind_rows(., ep_proj_uk) %>%
  bind_rows(., ep_proj_be) %>%
  select(-subname)

ep_proj_l <- ep_proj_02 %>%
  pivot_longer(epp:re, names_to = "group", values_to = "seats_proj") %>%
  filter(!is.na(seats_proj))
  
# results ####
ep_res_01 <- ep_res_00 %>%
  mutate(across(epp:re, ~ as.numeric(gsub(" \\(.*\\)", "", .)))) %>%
  select(-subname)

ep_res_l <- ep_res_01 %>%
  pivot_longer(epp:re, names_to = "group", values_to = "seats_res") %>%
  filter(!is.na(seats_res)) 

# harmonize group names and ignore certain groups ####
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

# RESULTS ======================================================================

# join projections/results and compute mean absolute error ####

ep <- ep_proj_l %>%
  left_join(., ep_res_l, by = c("name", "group")) %>%
  mutate(
    e = seats_res - seats_proj,
    ae = abs(seats_res - seats_proj))

# mean absolute error on group-country level ####

mae <- mean(ep$ae, na.rm = T)

e_plot <- ep %>% ggplot(aes(y = e, x = group, fill = group)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(
    values = c("#ffe033", "#217a9d", "#58aafc", "#321079", 
               "#8deb9d", "#991c00", "#f95f5f")) +
  facet_wrap(~name) +
  theme_light()

ggsave(e_plot)

# mean absolute error on group level ####

## Quick and dirty: get this manually
ep_total <- data.frame(
  group = c("alde/re", "ecr", "enf/id", "epp", "greens", "gue", "sd"),
  seats_proj = c(97, 57, 55, 171, 53, 43, 149),
  seats_res = c(108, 62, 73, 182, 74, 41, 154),
  name = "All countries")

ep_total <- ep_total %>%
  mutate(
    e = seats_res - seats_proj,
    ae = abs(seats_res - seats_proj))

mae_total <- mean(ep_total$ae, na.rm = T)

ep_total_plot <- ep_total %>% ggplot(aes(y = e, x = group, fill = group)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(
    values = c("#ffe033", "#217a9d", "#58aafc", "#321079", 
               "#8deb9d", "#991c00", "#f95f5f")) +
  facet_wrap(~name) +
  theme_light()







