####################################################################################
# Script-file:   afl_player_stats.R
# Project:       AFLPlayerData
# Author:        Cooper Denny
#
# Purpose:       Code to scrape and clean AFL player and team data from 2015-
####################################################################################

source("setup.R")

####################################################################################
# Configuration
####################################################################################

output_path     <- "Player Data/AFL/afl_player_stats.csv"
start_year      <- 2015
end_year        <- as.integer(format(Sys.Date(), "%Y"))
fetch_from_year <- 2026   # skip coverage check for seasons before this year

existing_data <- if (file.exists(output_path)) read.csv(output_path) else NULL

####################################################################################
# Determine which seasons need updating by comparing played games to CSV coverage
####################################################################################

message("Checking fixture coverage for seasons ", start_year, "–", end_year, "...")

seasons_to_fetch <- integer(0)

for (year in fetch_from_year:end_year) {

  fixture <- tryCatch(
    fetch_fixture(season = year, comp = "AFLM"),
    error = function(e) { warning("Fixture fetch failed for ", year, ": ", e$message); NULL }
  )

  if (is.null(fixture) || nrow(fixture) == 0) next

  # Only consider games that have actually been played (scores present)
  played_ids <- fixture %>%
    filter(!is.na(home.score.totalScore)) %>%
    pull(providerId)

  if (length(played_ids) == 0) {
    message("  ", year, ": season not yet started, skipping")
    next
  }

  csv_ids <- if (!is.null(existing_data) && year %in% existing_data$Year) {
    unique(existing_data$Game.ID[existing_data$Year == year])
  } else {
    character(0)
  }

  missing_games <- setdiff(played_ids, csv_ids)

  if (length(missing_games) > 0) {
    message("  ", year, ": ", length(missing_games), " game(s) missing — will re-fetch")
    seasons_to_fetch <- c(seasons_to_fetch, year)
  } else {
    message("  ", year, ": up to date (", length(played_ids), " games)")
  }
}

if (length(seasons_to_fetch) == 0) {
  message("All seasons up to date. Nothing to do.")
  quit(save = "no")
}

message("Re-fetching seasons: ", paste(seasons_to_fetch, collapse = ", "))

####################################################################################
# Column definitions
####################################################################################

desired_cols <- c(
  "providerId", "player.player.player.playerId", "player.player.player.givenName",
  "player.player.player.surname", "player.photoURL", "compSeason.year",
  "round.roundNumber", "team.name", "opponent",
  "teamStatus", "venue.name", "venue.state",
  "player.player.player.playerJumperNumber", "timeOnGroundPercentage", "goals",
  "behinds", "kicks", "handballs",
  "disposals", "marks", "bounces",
  "tackles", "contestedPossessions", "uncontestedPossessions",
  "totalPossessions", "inside50s", "marksInside50",
  "contestedMarks", "hitouts", "onePercenters",
  "disposalEfficiency", "clangers", "freesFor",
  "freesAgainst", "dreamTeamPoints", "rebound50s",
  "goalAssists", "goalAccuracy", "ratingPoints",
  "turnovers", "intercepts", "tacklesInside50",
  "shotsAtGoal", "scoreInvolvements", "metresGained",
  "clearances.centreClearances", "clearances.stoppageClearances", "clearances.totalClearances",
  "extendedStats.effectiveKicks", "extendedStats.kickEfficiency", "extendedStats.kickToHandballRatio",
  "extendedStats.effectiveDisposals", "extendedStats.marksOnLead", "extendedStats.interceptMarks",
  "extendedStats.contestedPossessionRate", "extendedStats.hitoutsToAdvantage", "extendedStats.hitoutWinPercentage",
  "extendedStats.hitoutToAdvantageRate", "extendedStats.groundBallGets", "extendedStats.f50GroundBallGets",
  "extendedStats.scoreLaunches", "extendedStats.pressureActs", "extendedStats.defHalfPressureActs",
  "extendedStats.spoils", "extendedStats.ruckContests", "extendedStats.contestDefOneOnOnes",
  "extendedStats.contestDefLosses", "extendedStats.contestDefLossPercentage", "extendedStats.contestOffOneOnOnes",
  "extendedStats.contestOffWins", "extendedStats.contestOffWinsPercentage", "extendedStats.centreBounceAttendances",
  "extendedStats.kickins", "extendedStats.kickinsPlayon", "team.goals",
  "team.behinds", "team.total", "opponent.goals",
  "opponent.behinds", "opponent.total", "team.result"
)

output_col_names <- c(
  "Game.ID", "Player.ID", "First.Name", "Surname", "Photo", "Year", "Round.Number", "Team.Name",
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
  "Opponent.Total", "Team.Result"
)

####################################################################################
# Fetch and process all rounds for a given season
####################################################################################

fetch_season <- function(year) {
  message("  Fetching player stats for ", year, "...")

  fixture <- tryCatch(
    fetch_fixture(season = year, comp = "AFLM") %>%
      select(providerId, home.team.name, away.team.name,
             home.score.goals, home.score.behinds, home.score.totalScore,
             away.score.goals, away.score.behinds, away.score.totalScore,
             venue.abbreviation, venue.state, compSeason.year),
    error = function(e) { warning("Fixture fetch failed for ", year, ": ", e$message); NULL }
  )

  stats <- tryCatch(
    fetch_player_stats_afl(season = year, comp = "AFLM"),
    error = function(e) { warning("Stats fetch failed for ", year, ": ", e$message); NULL }
  )

  if (is.null(fixture) || is.null(stats) || nrow(fixture) == 0 || nrow(stats) == 0) {
    warning("No data for season ", year)
    return(NULL)
  }

  merged <- merge(fixture, stats, by = c("providerId", "home.team.name", "away.team.name")) %>%
    mutate(
      opponent         = ifelse(teamStatus == "home", away.team.name, home.team.name),
      team.goals       = ifelse(teamStatus == "home", home.score.goals, away.score.goals),
      team.behinds     = ifelse(teamStatus == "home", home.score.behinds, away.score.behinds),
      team.total       = ifelse(teamStatus == "home", home.score.totalScore, away.score.totalScore),
      opponent.goals   = ifelse(teamStatus == "home", away.score.goals, home.score.goals),
      opponent.behinds = ifelse(teamStatus == "home", away.score.behinds, home.score.behinds),
      opponent.total   = ifelse(teamStatus == "home", away.score.totalScore, home.score.totalScore),
      team.result      = case_when(
        team.total - opponent.total > 0 ~ "W",
        team.total - opponent.total < 0 ~ "L",
        TRUE                             ~ "D"
      )
    ) %>%
    drop_na(team.name)

  # Select only columns available for this season (extended stats absent in older data)
  present       <- intersect(desired_cols, names(merged))
  merged        <- select(merged, all_of(present))
  names(merged) <- output_col_names[match(present, desired_cols)]

  merged
}

new_data <- map(seasons_to_fetch, fetch_season) %>%
  compact() %>%
  bind_rows()

####################################################################################
# Merge with existing data, replacing re-fetched seasons in full
####################################################################################

if (!is.null(existing_data) && nrow(new_data) > 0) {
  afl_player_stats <- existing_data %>%
    filter(!Year %in% seasons_to_fetch) %>%
    bind_rows(new_data)
} else {
  afl_player_stats <- if (is.null(existing_data)) new_data else existing_data
}

####################################################################################
# Standardise team names
####################################################################################

name_map <- c(
  "Narrm"           = "Melbourne",
  "Waalitj Marawar" = "West Coast Eagles",
  "Euro-Yroke"      = "St Kilda",
  "Kuwarna"         = "Adelaide Crows",
  "Walyalup"        = "Fremantle",
  "Yartapuulti"     = "Port Adelaide",
  "Footscray"       = "Western Bulldogs"
)

afl_player_stats <- afl_player_stats %>%
  mutate(
    Team.Name     = recode(Team.Name,     !!!name_map),
    Opponent.Name = recode(Opponent.Name, !!!name_map)
  )

####################################################################################
# Deduplicate and save
####################################################################################

afl_player_stats <- afl_player_stats %>%
  distinct() %>%
  arrange(Year, Round.Number, Game.ID)

write.csv(afl_player_stats, output_path, row.names = FALSE)

message("Done. ", nrow(afl_player_stats), " player-game rows saved to ", output_path)
