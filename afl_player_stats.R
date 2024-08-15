####################################################################################
# Script-file:   afl_player_stats.R
# Project:       AFLPlayerData
# Author:        Cooper Denny
#
# Purpose:       Code to scrape and clean AFL player and team data from 2015-
####################################################################################

# Load necessary libraries
library(fitzRoy)    # For accessing AFL data
library(tidyverse)  # For data manipulation

####################################################################################
# Fetch new fixture and player stats for the current round and season
####################################################################################

# Define the current season and round number to update data
Season = 2024
Round_Number = 22

# Fetch the new fixture for the specified season and round
afl_results_new <- fetch_fixture(season = Season, comp = "AFLM", round_number = Round_Number) %>% 
  select(providerId, home.team.name, away.team.name, home.score.goals,
         home.score.behinds, home.score.totalScore, away.score.goals, away.score.behinds,
         away.score.totalScore, venue.abbreviation, venue.state, compSeason.year)

# Fetch new player stats for the current season and round
afl_player_stats_new <- fetch_player_stats_afl(season = Season, round_number = Round_Number, comp = "AFLM")

# Merge fixture data with player stats using common columns and calculate additional fields
afl_player_stats_new <- merge(afl_results_new,
                              afl_player_stats_new, 
                              by=c("providerId","home.team.name", "away.team.name")) %>%
  mutate(opponent = ifelse(teamStatus == "home", away.team.name, home.team.name)) %>%
  mutate(team.goals = ifelse(teamStatus == "home", home.score.goals, away.score.goals)) %>%
  mutate(team.behinds = ifelse(teamStatus == "home", home.score.behinds, away.score.behinds)) %>%
  mutate(team.total = ifelse(teamStatus == "home", home.score.totalScore, away.score.totalScore)) %>%
  mutate(opponent.goals = ifelse(teamStatus == "home", away.score.goals, home.score.goals)) %>%
  mutate(opponent.behinds = ifelse(teamStatus == "home", away.score.behinds, home.score.behinds)) %>%
  mutate(opponent.total = ifelse(teamStatus == "home", away.score.totalScore, home.score.totalScore)) %>%
  mutate(team.result = ifelse(team.total - opponent.total > 0, "W", ifelse(team.total - opponent.total < 0, "L", "D")))

# Select and rename columns for consistency and clarity
afl_player_stats_new <- afl_player_stats_new %>% select(providerId, player.player.player.playerId, player.player.player.givenName, 
                                                        player.player.player.surname, player.photoURL, compSeason.year, 
                                                        round.roundNumber, team.name, opponent, 
                                                        teamStatus, venue.name, venue.state, 
                                                        player.player.player.playerJumperNumber, timeOnGroundPercentage, goals, 
                                                        behinds, kicks, handballs, 
                                                        disposals, marks, bounces, 
                                                        tackles, contestedPossessions, uncontestedPossessions, 
                                                        totalPossessions, inside50s, marksInside50, 
                                                        contestedMarks, hitouts, onePercenters, 
                                                        disposalEfficiency, clangers, freesFor, 
                                                        freesAgainst, dreamTeamPoints, rebound50s, 
                                                        goalAssists, goalAccuracy, ratingPoints, 
                                                        turnovers, intercepts, tacklesInside50, 
                                                        shotsAtGoal, scoreInvolvements, metresGained, 
                                                        clearances.centreClearances, clearances.stoppageClearances, clearances.totalClearances, 
                                                        extendedStats.effectiveKicks, extendedStats.kickEfficiency, extendedStats.kickToHandballRatio, 
                                                        extendedStats.effectiveDisposals, extendedStats.marksOnLead, extendedStats.interceptMarks, 
                                                        extendedStats.contestedPossessionRate, extendedStats.hitoutsToAdvantage, extendedStats.hitoutWinPercentage, 
                                                        extendedStats.hitoutToAdvantageRate, extendedStats.groundBallGets, extendedStats.f50GroundBallGets, 
                                                        extendedStats.scoreLaunches, extendedStats.pressureActs, extendedStats.defHalfPressureActs, 
                                                        extendedStats.spoils, extendedStats.ruckContests, extendedStats.contestDefOneOnOnes, 
                                                        extendedStats.contestDefLosses, extendedStats.contestDefLossPercentage, extendedStats.contestOffOneOnOnes, 
                                                        extendedStats.contestOffWins, extendedStats.contestOffWinsPercentage, extendedStats.centreBounceAttendances, 
                                                        extendedStats.kickins, extendedStats.kickinsPlayon, team.goals, 
                                                        team.behinds, team.total, opponent.goals, 
                                                        opponent.behinds, opponent.total, team.result)

# Rename columns for clarity
colnames(afl_player_stats_new) <- c("Game.ID", "Player.ID", "First.Name", "Surname", "Photo", "Year","Round.Number", "Team.Name", 
                                    "Opponent.Name", "Team.Status", "Venue.Name", "Venue.State",
                                    "Player.Jumper.Number", "Time.On.Ground.Percentage", "Goals", "Behinds", 
                                    "Kicks", "Handballs", "Disposals", "Marks", "Bounces", "Tackles", 
                                    "Contested.Possessions", "Uncontested.Possessions", "Total.Possessions", 
                                    "Inside.50s", "Marks.Inside.50", "Contested.Marks", "Hitouts", 
                                    "One.Percenters", "Disposal.Efficiency.Percentage", "Clangers", "Frees.For", 
                                    "Frees.Against", "DreamTeam.Points", "Rebound.50s", "Goal.Assists", 
                                    "Goal.Accuracy", "Rating.Points", "Turnovers", "Intercepts", 
                                    "Tackles.Inside.50", "Shots.At.Goal", "Score.Involvements", 
                                    "Metres.Gained", "Centre.Clearances", "Stoppage.Clearances", 
                                    "Total.Clearances", "Effective.Kicks", "Kicking.Efficiency.Percentage", 
                                    "Kick.To.Handball.Ratio", "Effective.Disposals", "Marks.On.Lead", 
                                    "Intercept.Marks", "Contested.Possession.Rate", "Hitouts.To.Advantage", 
                                    "Hitout.Win.Percentage", "Hitout.To.Advantage.Rate.Percentage", "Ground.Ball.Gets", 
                                    "F50.Ground.Ball.Gets", "Score.Launches", "Pressure.Acts", 
                                    "Defensive.Half.Pressure.Acts", "Spoils", "Ruck.Contests",
                                    "Contest.Defense.One.On.Ones", "Contest.Defense.Losses",
                                    "Contest.Defense.Loss.Percentage", "Contest.Offence.One.On.Ones",
                                    "Contest.Offence.Wins", "Contest.Offence.Wins.Percentage",
                                    "Centre.Bounce.Attendances", "Kick.Ins", "Kick.Ins.Play.On", "Team.Goals",
                                    "Team.Behinds", "Team.Total", "Opponent.Goals", "Opponent.Behinds", 
                                    "Opponent.Total", "Team.Result") 

# Remove rows with missing team names
afl_player_stats_new <- afl_player_stats_new %>% drop_na(Team.Name)

####################################################################################
# Read data from all seasons and combine with current round data
####################################################################################

# Read existing AFL player stats data from a CSV file
afl_player_stats <- read.csv("Player Data/AFL/afl_player_stats.csv")

# Combine existing and new player stats into a single data frame
afl_player_stats <- bind_rows(afl_player_stats, afl_player_stats_new)

# Standardize team names for consistency
afl_player_stats["Team.Name"][afl_player_stats["Team.Name"] == "Narrm"] <- "Melbourne"
afl_player_stats["Team.Name"][afl_player_stats["Team.Name"] == "Waalitj Marawar"] <- "West Coast Eagles"
afl_player_stats["Team.Name"][afl_player_stats["Team.Name"] == "Euro-Yroke"] <- "St Kilda"
afl_player_stats["Team.Name"][afl_player_stats["Team.Name"] == "Kuwarna"] <- "Adelaide Crows"
afl_player_stats["Team.Name"][afl_player_stats["Team.Name"] == "Walyalup"] <- "Fremantle"
afl_player_stats["Team.Name"][afl_player_stats["Team.Name"] == "Yartapuulti"] <- "Port Adelaide"
afl_player_stats["Team.Name"][afl_player_stats["Team.Name"] == "Footscray"] <- "Western Bulldogs"

afl_player_stats["Opponent.Name"][afl_player_stats["Opponent.Name"] == "Narrm"] <- "Melbourne"
afl_player_stats["Opponent.Name"][afl_player_stats["Opponent.Name"] == "Waalitj Marawar"] <- "West Coast Eagles"
afl_player_stats["Opponent.Name"][afl_player_stats["Opponent.Name"] == "Euro-Yroke"] <- "St Kilda"
afl_player_stats["Opponent.Name"][afl_player_stats["Opponent.Name"] == "Kuwarna"] <- "Adelaide Crows"
afl_player_stats["Opponent.Name"][afl_player_stats["Opponent.Name"] == "Walyalup"] <- "Fremantle"
afl_player_stats["Opponent.Name"][afl_player_stats["Opponent.Name"] == "Yartapuulti"] <- "Port Adelaide"
afl_player_stats["Opponent.Name"][afl_player_stats["Opponent.Name"] == "Footscray"] <- "Western Bulldogs"

# Remove duplicate entries
afl_player_stats <- afl_player_stats %>% distinct()

####################################################################################
# Save updated player stats data to a CSV file
####################################################################################

# Write updated player stats to a CSV file
write.csv(afl_player_stats, "Player Data/AFL/afl_player_stats.csv", row.names=FALSE)

# Clean up the environment by removing all objects
#rm(list=ls())



