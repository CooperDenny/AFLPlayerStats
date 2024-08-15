####################################################################################
# Script-file:   aflca_votes.R
# Project:       AFLPlayerData
# Author:        Cooper Denny
#
# Purpose:       Code to transform and summarize AFL coaches votes data
####################################################################################

# Load necessary libraries
library(tidyverse) # For data manipulation
library(fitzRoy)   # For accessing AFL data
library(rvest)     # For web scraping
library(polite)    # For polite web scraping
library(ordinal)   # For ordinal logistic regression
library(knitr)     # For dynamic report generation
library(unglue)    # For ungluing strings

####################################################################################
# Scrape AFL coaches votes data for selected round and season, then clean up
####################################################################################

# Define the current season and round number for which to update data
Season = 2024
Round_Number = 22

# Create a bow object for scraping the coaches votes leaderboard
coaches_scrape <- bow(paste0("https://aflcoaches.com.au/awards/the-aflca-champion-player-of-the-year-award/leaderboard/",
                             Season, "/", Season + 1, "01", Round_Number + 1))
# Scrape the data from the webpage
coaches_data <- scrape(coaches_scrape)

# Extract player names from the HTML nodes
Player.Name <- coaches_data %>%
  html_nodes(".div-hover .col-10") %>% 
  html_text() %>%
  str_remove("\n\t\t\t\t\t\t\t\t\t") %>% 
  str_remove("\n\t\t\t\t\t\t\t\t")

# Extract coaches votes from the HTML nodes
Coaches.Votes <- coaches_data %>%
  html_nodes(".div-hover strong") %>% 
  html_text()

# Create a data frame with the extracted data
coaches_votes_new <- data.frame(Coaches.Votes, Player.Name)

# Add season and round number columns
coaches_votes_new$Season = Season
coaches_votes_new$Round = Round_Number

# Unglue player name data into separate columns and arrange by season and round
coaches_votes_new <- unglue_unnest(coaches_votes_new, Player.Name, "{First.Name} {Surname} {Team.Name}") %>% 
  arrange(Season, Round)

# Adjust surname by appending the team name extracted from parentheses
coaches_votes_new$Surname <- paste(coaches_votes_new$Surname, str_extract(coaches_votes_new$Team.Name, "^[^\\(]+"))

# Remove "NA" and adjust team names
coaches_votes_new$Surname <- coaches_votes_new$Surname %>% str_remove(" NA")
coaches_votes_new$Team.Name <- str_replace(coaches_votes_new$Team.Name, "^[^\\(]+\\s*\\(", "")
coaches_votes_new$Team.Name <- str_replace(coaches_votes_new$Team.Name, "\\)", "")
coaches_votes_new$Team.Name <- str_replace(coaches_votes_new$Team.Name, "\\(", "")

# Trim trailing spaces in surnames
for(i in 1:nrow(coaches_votes_new)){
  if (substr(coaches_votes_new$Surname[i], nchar(coaches_votes_new$Surname[i]), nchar(coaches_votes_new$Surname[i])) == " ") {
    coaches_votes_new$Surname[i] <- substr(coaches_votes_new$Surname[i], 1, nchar(coaches_votes_new$Surname[i]) - 1)
  }
}

# Rename columns for clarity
colnames(coaches_votes_new) <- c("Coaches.Votes", "Year", "Round.Number", "First.Name", "Surname", "Team.Name")

####################################################################################
# Load existing coaches votes data and combine with new data
####################################################################################

# Read existing AFLCA votes data from a CSV file
coaches_votes <- read.csv("Player Data/AFLCA Votes/aflca_votes.csv")

# Combine existing and new coaches votes data into a single data frame
coaches_votes <- rbind(coaches_votes, coaches_votes_new)

# Remove duplicate entries
coaches_votes <- coaches_votes %>% distinct()

# Save updated coaches votes data to a CSV file
write.csv(coaches_votes, "Player Data/AFLCA Votes/aflca_votes.csv", row.names=FALSE)

# Clean up the environment by removing all objects
#rm(list=ls())

