####################################################################################
# Script-file:   aflca_votes.R
# Project:       AFLPlayerData
# Author:        Cooper Denny
#
# Purpose:       Code to transform and summarise AFL coaches votes data
####################################################################################

library(fitzRoy)
library(tidyverse)

####################################################################################
# Configuration
####################################################################################

output_path     <- "Player Data/AFLCA Votes/aflca_votes.csv"
start_year      <- 2006   # earliest year available via fetch_coaches_votes()
end_year        <- as.integer(format(Sys.Date(), "%Y"))
fetch_from_year <- 2026   # always re-fetch this season onwards

####################################################################################
# Determine which seasons to fetch
####################################################################################

existing_data <- if (file.exists(output_path)) read.csv(output_path) else NULL

existing_years   <- if (!is.null(existing_data)) unique(existing_data$Year) else integer(0)
missing_years    <- setdiff(start_year:(end_year - 1), existing_years)
seasons_to_fetch <- sort(unique(c(missing_years, fetch_from_year:end_year)))

message("Fetching seasons: ", paste(seasons_to_fetch, collapse = ", "))

####################################################################################
# Fetch and process each season
####################################################################################

fetch_season <- function(year) {
  message("  Fetching ", year, "...")

  df <- tryCatch(
    fetch_coaches_votes(season = year, comp = "AFLM"),
    error = function(e) { warning("Fetch failed for ", year, ": ", e$message); NULL }
  )

  if (is.null(df) || nrow(df) == 0) {
    warning("No data for season ", year)
    return(NULL)
  }

  # Player.Name format: "Isaac Heeney (SYD)"
  df %>%
    mutate(
      Team.Name   = str_extract(Player.Name, "(?<=\\()\\w+(?=\\))"),
      Player.Name = str_remove(Player.Name, "\\s*\\(\\w+\\)")
    ) %>%
    separate(Player.Name, into = c("First.Name", "Surname"), sep = " ", extra = "merge", fill = "right") %>%
    transmute(
      Coaches.Votes = as.numeric(Coaches.Votes),
      Year          = as.integer(Season),
      Round.Number  = as.integer(Round),
      First.Name    = as.character(First.Name),
      Surname       = as.character(Surname),
      Team.Name     = as.character(Team.Name)
    )
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
