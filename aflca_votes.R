####################################################################################
# Script-file:   aflca_votes.R
# Project:       AFLPlayerData
# Author:        Cooper Denny
#
# Purpose:       Function to fetch AFLCA coaches votes for a single season/round
#                and append the results to the existing CSV.
#
# Usage:         source("aflca_votes.R")
#                append_aflca_votes_round(year = 2026, round = 12)
####################################################################################

source("setup.R")

####################################################################################
# Configuration
####################################################################################

output_path <- "Player Data/AFLCA Votes/aflca_votes.csv"

# Hardcoded AFL API round ranges per season (Opening Round = round 0 for 2024+)
season_round_ranges <- list(
  `2015` = 1:23, `2016` = 1:23, `2017` = 1:23, `2018` = 1:23,
  `2019` = 1:23, `2020` = 1:18, `2021` = 1:23, `2022` = 1:23,
  `2023` = 1:24,
  `2024` = 0:24, `2025` = 0:24, `2026` = 0:15
)

# For Opening Round seasons, coaches votes round numbers are offset by +1 vs AFL API
has_opening_round <- function(year) year >= 2024

get_valid_rounds <- function(year) {
  rounds <- season_round_ranges[[as.character(year)]]
  if (is.null(rounds)) if (year >= 2024) 0:24 else 1:23 else rounds
}

####################################################################################
# Function
####################################################################################

append_aflca_votes_round <- function(year, round) {
  round_offset <- if (has_opening_round(year)) 1L else 0L
  api_round    <- round + round_offset

  message("Fetching ", year, " round ", round, " (API round ", api_round, ")...")

  df <- tryCatch(
    fetch_coaches_votes(season = year, comp = "AFLM", round_number = api_round),
    error = function(e) { stop("Fetch failed: ", e$message) }
  )

  if (is.null(df) || nrow(df) == 0) {
    message("No data returned for ", year, " round ", round)
    return(invisible(NULL))
  }

  new_rows <- df %>%
    mutate(
      Team.Name   = str_extract(Player.Name, "(?<=\\()\\w+(?=\\))"),
      Player.Name = str_remove(Player.Name, "\\s*\\(\\w+\\)")
    ) %>%
    separate(Player.Name, into = c("First.Name", "Surname"), sep = " ", extra = "merge", fill = "right") %>%
    transmute(
      Year          = as.integer(Season),
      Round.Number  = as.integer(Round) - round_offset,
      First.Name    = as.character(First.Name),
      Surname       = as.character(Surname),
      Team.Name     = as.character(Team.Name),
      Coaches.Votes = as.numeric(Coaches.Votes),
      Home.Team     = as.character(Home.Team),
      Away.Team     = as.character(Away.Team)
    ) %>%
    group_by(Round.Number, Home.Team, Away.Team) %>%
    filter(all(Coaches.Votes == floor(Coaches.Votes))) %>%
    ungroup() %>%
    filter(Round.Number == round)

  if (nrow(new_rows) == 0) {
    message("No complete votes data for ", year, " round ", round)
    return(invisible(NULL))
  }

  existing <- if (file.exists(output_path)) read.csv(output_path) else NULL

  combined <- if (!is.null(existing)) {
    existing %>%
      filter(!(Year == year & Round.Number == round)) %>%
      bind_rows(new_rows) %>%
      distinct()
  } else {
    distinct(new_rows)
  }

  write.csv(combined, output_path, row.names = FALSE)
  message("Done. Added ", nrow(new_rows), " rows for ", year, " round ", round,
          ". Total rows in file: ", nrow(combined))

  invisible(new_rows)
}
