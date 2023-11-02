# ==============================================================================
# file name: us-explainer.R
# authors: Bernhard Clemm
# date: 21 Jan 2023
# ==============================================================================

# PACKAGES =====================================================================

library(tidyverse)
library(haven)
library(networkD3)
library(viridis)
library(patchwork)
library(circlize)

path <- paste0(dirname(dirname(rstudioapi::getSourceEditorContext()$path)), "/")

# DATA =========================================================================

# from https://apnorc.org/projects/ap-votecast-2020-general-elections/
ap_00 <- read_sav(paste0(path, "data/AP_VOTECAST_2020_GENERAL.sav"))

# variables of interest:
# str(ap_00$PRESVOTE)
# str(ap_00$VOTE16CHOICE)

# RECODING =====================================================================

ap_01 <- ap_00 %>%
  mutate(
    vote_2016 = case_when(
      VOTE16CHOICE == 1 ~ "Hillary Clinton",
      VOTE16CHOICE == 2 ~ "Donald Trump",
      VOTE16CHOICE == 3 ~ "Another candidate",
      VOTE16CHOICE == 4 ~ "Did not vote"),
    vote_2020 = case_when(
      PRESVOTE == 1 ~ "Joe Biden",
      PRESVOTE == 2 ~ "Donald Trump",
      PRESVOTE == 3 ~ "Another candidate")) %>%
  mutate(across(c("vote_2016", "vote_2020"),
                ~ factor(., ordered = T, 
                         levels = c("Hillary Clinton",
                                    "Joe Biden",
                                    "Donald Trump",
                                    "Another candidate",
                                    "Did not vote")))) %>%
  select(vote_2016, vote_2020)

# SUMMARIZE DATA ===============================================================

ap_sum <- ap_01 %>%
  na.omit() %>%
  group_by(vote_2016, vote_2020) %>%
  summarize(count = n()) %>%
  ungroup() %>%
  mutate(prop = count / sum(count)) %>%
  select(vote_2016, vote_2020, prop)

# PLOT =========================================================================

# for the plot, each value needs a unique id, separate for each column
ap_sum <- ap_sum %>%
  group_by(vote_2016) %>%
  mutate(source = cur_group_id() - 1)
offset <- length(unique(ap_sum$source))
ap_sum <- ap_sum %>%
  group_by(vote_2020) %>%
  mutate(target = cur_group_id() + offset - 1) %>%
  as.data.frame()

# define nodes
nodes <- data.frame(
  name = c(as.character(ap_sum$vote_2016) %>% unique(), 
           as.character(ap_sum$vote_2020) %>% unique()))

# define colors
node_color <- 'd3.scaleOrdinal() 
.domain(["Hillary Clinton", "Donald Trump", "Another candidate", "Did not vote", "Joe Biden", "Donald Trump", "Another candidate"]) 
.range(["green", "grey", "blue" , "grey", "blue", "blue", "red"])'

sankeyNetwork(
  Links = ap_sum, Nodes = nodes,
  Source = "source", Target = "target",
  Value = "prop", NodeID = "name",
  fontSize = 12, nodeWidth = 40,
  colourScale = node_color)


