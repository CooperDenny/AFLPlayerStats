####################################################################################
# Script-file:   afltables_player_stats.R
# Project:       AFLPlayerData
# Author:        Cooper Denny
#
# Purpose:       Code to transform and summarise AFL player data from 1897-
####################################################################################

# Load necessary libraries
library(fitzRoy)  # For fetching AFL data
library(tidyverse)  # For data manipulation

####################################################################################
# Load data for selected round and season, then clean up
####################################################################################

# Define the current season and round number for which to update data
Season = 2024
Round_Number = 22

# Fetch new player stats for the current season from the afltables source
afltables_player_stats_new <- fetch_player_stats(season = Season, source = "afltables") %>% 
  # Use ifelse to apply different filters based on the season 
  # (afltables treats round 0 as round 1 in their system)
  filter(ifelse(Season == 2024, Round == Round_Number + 1, Round == Round_Number)) 

# Adjust the round number back to match the current round
afltables_player_stats_new$Round <- as.numeric(afltables_player_stats_new$Round) - 1
afltables_player_stats_new$Round <- as.character(afltables_player_stats_new$Round)

# Sort the new player stats data by Season, Date, and Local start time
afltables_player_stats_new <- afltables_player_stats_new %>% 
  arrange(Season, Date, Local.start.time)

# Clean up the Jumper Number field by removing any directional arrows
afltables_player_stats_new$Jumper.No. <- afltables_player_stats_new$Jumper.No. %>% 
  str_remove(" ↓") %>% 
  str_remove(" ↑")

# Replace any NA values in the Brownlow.Votes column with 0
afltables_player_stats_new$Brownlow.Votes[is.na(afltables_player_stats_new$Brownlow.Votes)] <- 0

# Summarize the new player stats data with specific transformations
afltables_player_stats_new <- afltables_player_stats_new %>% 
  summarise(ID = as.integer(ID),
            First.name = as.character(First.name),
            Surname = as.character(Surname),
            Playing.for = as.character(Playing.for),
            Jumper.No. = as.numeric(Jumper.No.),
            Season = as.numeric(Season),
            Round = as.character(Round),
            Date = as.character(Date),
            Kicks = as.numeric(Kicks),
            Handballs = as.numeric(Handballs),
            Disposals = as.numeric(Kicks) + as.numeric(Handballs),  # Calculate Disposals
            Marks = as.numeric(Marks),
            Goals = as.numeric(Goals),
            Behinds = as.numeric(Behinds),
            Hit.Outs = as.numeric(Hit.Outs),
            Tackles = as.numeric(Tackles),
            Rebounds = as.numeric(Rebounds),
            Inside.50s = as.numeric(Inside.50s),
            Clearances = as.numeric(Clearances),
            Clangers = as.numeric(Clangers),
            Frees.For = as.numeric(Frees.For),
            Frees.Against = as.numeric(Frees.Against),
            Brownlow.Votes = as.numeric(Brownlow.Votes),
            Contested.Possessions = as.numeric(Contested.Possessions),
            Uncontested.Possessions = as.numeric(Uncontested.Possessions),
            Contested.Marks = as.numeric(Contested.Marks),
            Marks.Inside.50 = as.numeric(Marks.Inside.50),
            One.Percenters = as.numeric(One.Percenters),
            Bounces = as.numeric(Bounces),
            Goal.Assists = as.numeric(Goal.Assists),
            Venue = as.character(Venue),
            Attendance = as.numeric(Attendance),
            Home.team = as.character(Home.team),
            Away.team = as.character(Away.team), 
            Home.score = as.numeric(Home.score),
            Away.score = as.numeric(Away.score))

####################################################################################
# Read data from all seasons and combine with current round data
####################################################################################

# Read the existing AFL player stats data from a CSV file
afltables_player_stats <- list.files(path = "./Player Data/AFL Tables", pattern = "*.csv", full.names = TRUE) %>%
  map_df(~read_csv(., col_types = cols(.default = "c")))

# Summarize the player stats data with specific transformations
afltables_player_stats <- afltables_player_stats %>% 
  summarise(ID = as.integer(ID),
            First.name = as.character(First.name),
            Surname = as.character(Surname),
            Playing.for = as.character(Playing.for),
            Jumper.No. = as.numeric(Jumper.No.),
            Season = as.numeric(Season),
            Round = as.character(Round),
            Date = as.character(Date),
            Kicks = as.numeric(Kicks),
            Handballs = as.numeric(Handballs),
            Disposals = as.numeric(Disposals),
            Marks = as.numeric(Marks),
            Goals = as.numeric(Goals),
            Behinds = as.numeric(Behinds),
            Hit.Outs = as.numeric(Hit.Outs),
            Tackles = as.numeric(Tackles),
            Rebounds = as.numeric(Rebounds),
            Inside.50s = as.numeric(Inside.50s),
            Clearances = as.numeric(Clearances),
            Clangers = as.numeric(Clangers),
            Frees.For = as.numeric(Frees.For),
            Frees.Against = as.numeric(Frees.Against),
            Brownlow.Votes = as.numeric(Brownlow.Votes),
            Contested.Possessions = as.numeric(Contested.Possessions),
            Uncontested.Possessions = as.numeric(Uncontested.Possessions),
            Contested.Marks = as.numeric(Contested.Marks),
            Marks.Inside.50 = as.numeric(Marks.Inside.50),
            One.Percenters = as.numeric(One.Percenters),
            Bounces = as.numeric(Bounces),
            Goal.Assists = as.numeric(Goal.Assists),
            Venue = as.character(Venue),
            Attendance = as.numeric(Attendance),
            Home.team = as.character(Home.team),
            Away.team = as.character(Away.team), 
            Home.score = as.numeric(Home.score),
            Away.score = as.numeric(Away.score))

# Combine the existing and new player stats data into a single data frame
afltables_player_stats <- bind_rows(afltables_player_stats, afltables_player_stats_new)

# Remove any duplicate rows from the combined player stats data
afltables_player_stats <- afltables_player_stats %>% 
  distinct()

# Get the unique years from the dataset
years <- unique(afltables_player_stats$Season)

# Loop through each year and write the corresponding data to a CSV file
for (year in years) {
  # Filter data for the current year
  yearly_data <- afltables_player_stats %>% filter(Season == !!year)
  
  # Create a file name based on the year
  file_name <- paste0("Player Data/AFL Tables/afltables_player_stats_", year, ".csv")
  
  # Write the filtered data to a CSV file
  write.csv(yearly_data, file_name, row.names = FALSE)
}

# Clear all objects from the workspace to free up memory
rm(list=ls())

