####################################################################################
# Script-file:   aflca_votes.R
# Project:       AFLPlayerData
# Author:        Cooper Denny
#
# Purpose:       Code to transform and summarise AFL coaches votes data
####################################################################################

source("setup.R")

####################################################################################
# Configuration
####################################################################################

output_path     <- "Player Data/AFLCA Votes/aflca_votes.csv"
start_year      <- 2015
end_year        <- as.integer(format(Sys.Date(), "%Y"))
fetch_from_year <- 2026   # always re-fetch this season onwards

# Hardcoded AFL API round ranges per season (Opening Round = round 0 for 2024+)
season_round_ranges <- list(
  `2015` = 1:23, `2016` = 1:23, `2017` = 1:23, `2018` = 1:23,
  `2019` = 1:23, `2020` = 1:18, `2021` = 1:23, `2022` = 1:23,
  `2023` = 1:24,
  `2024` = 0:24, `2025` = 0:24, `2026` = 0:15
)

# For Opening Round seasons coaches votes round numbers are offset by +1 vs AFL API
has_opening_round <- function(year) year >= 2024

get_valid_rounds <- function(year) {
  rounds <- season_round_ranges[[as.character(year)]]
  if (is.null(rounds)) if (year >= 2024) 0:24 else 1:23 else rounds
}

####################################################################################
# Determine which seasons to fetch
####################################################################################

existing_data <- if (file.exists(output_path)) {
  read.csv(output_path) %>%
    filter(Year >= start_year, Coaches.Votes == floor(Coaches.Votes))
} else NULL

existing_years   <- if (!is.null(existing_data)) unique(existing_data$Year) else integer(0)
missing_years    <- setdiff(start_year:(end_year - 1), existing_years)
seasons_to_fetch <- sort(unique(c(missing_years, fetch_from_year:end_year)))

message("Fetching seasons: ", paste(seasons_to_fetch, collapse = ", "))

####################################################################################
# Fetch and process each season
####################################################################################

fetch_season <- function(year) {
  message("  Fetching ", year, "...")

  # For Opening Round seasons, coaches votes round 25 = AFL API round 24
  fetch_rounds <- if (has_opening_round(year)) 1:25 else 1:24

  df <- tryCatch(
    fetch_coaches_votes(season = year, comp = "AFLM", round_number = fetch_rounds),
    error = function(e) { warning("Fetch failed for ", year, ": ", e$message); NULL }
  )

  if (is.null(df) || nrow(df) == 0) {
    warning("No data for season ", year)
    return(NULL)
  }

  round_offset <- if (has_opening_round(year)) 1L else 0L

  df %>%
    mutate(
      Team.Name   = str_extract(Player.Name, "(?<=\\()\\w+(?=\\))"),
      Player.Name = str_remove(Player.Name, "\\s*\\(\\w+\\)")
    ) %>%
    separate(Player.Name, into = c("First.Name", "Surname"), sep = " ", extra = "merge", fill = "right") %>%
    transmute(
      Coaches.Votes = as.numeric(Coaches.Votes),
      Year          = as.integer(Season),
      Round.Number  = as.integer(Round) - round_offset,
      Home.Team     = as.character(Home.Team),
      Away.Team     = as.character(Away.Team),
      First.Name    = as.character(First.Name),
      Surname       = as.character(Surname),
      Team.Name     = as.character(Team.Name)
    ) %>%
    filter(Round.Number %in% get_valid_rounds(year), Coaches.Votes == floor(Coaches.Votes))
}

new_data <- map(seasons_to_fetch, fetch_season) %>%
  compact() %>%
  bind_rows()

####################################################################################
# Combine with existing data, replacing re-fetched seasons
####################################################################################

if (!is.null(existing_data) && nrow(new_data) > 0) {
  coaches_votes <- existing_data %>%
    filter(!Year %in% seasons_to_fetch) %>%
    bind_rows(new_data)
} else {
  coaches_votes <- if (is.null(existing_data)) new_data else existing_data
}

coaches_votes <- coaches_votes %>%
  distinct() %>%
  arrange(Year, Round.Number)

write.csv(coaches_votes, output_path, row.names = FALSE)

message("Done. ", nrow(coaches_votes), " rows saved to ", output_path)
