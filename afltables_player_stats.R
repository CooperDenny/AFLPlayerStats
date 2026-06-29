####################################################################################
# Script-file:   afltables_player_stats.R
# Project:       AFLPlayerData
# Author:        Cooper Denny
#
# Purpose:       Code to transform and summarise AFL player data from 1897-
####################################################################################

source("setup.R")

####################################################################################
# Configuration
####################################################################################

output_dir       <- "Player Data/AFL Tables"
end_year         <- as.integer(format(Sys.Date(), "%Y"))
fetch_from_year  <- 2026   # always re-fetch this season onwards

####################################################################################
# Determine which seasons to fetch
####################################################################################

existing_files <- list.files(path = output_dir, pattern = "\\.csv$", full.names = TRUE)

existing_seasons <- existing_files %>%
  basename() %>%
  str_extract("\\d{4}") %>%
  as.integer()

# Fetch seasons missing from disk, plus always re-fetch from fetch_from_year onwards
seasons_to_fetch <- sort(unique(c(setdiff(1897:end_year, existing_seasons), fetch_from_year:end_year)))

message("Fetching seasons: ", paste(seasons_to_fetch, collapse = ", "))

####################################################################################
# Fetch and clean each season
####################################################################################

has_opening_round <- function(year) {
  if (year < 2024) return(FALSE)
  fixture <- tryCatch(fetch_fixture(season = year, comp = "AFLM"), error = function(e) NULL)
  if (is.null(fixture)) return(FALSE)
  0L %in% fixture$round.roundNumber
}

clean_season <- function(df) {
  df$Jumper.No. <- df$Jumper.No. %>% str_remove(" ↓") %>% str_remove(" ↑")
  df$Brownlow.Votes[is.na(df$Brownlow.Votes)] <- 0

  df %>%
    transmute(
      ID                      = as.integer(ID),
      First.name              = as.character(First.name),
      Surname                 = as.character(Surname),
      Playing.for             = as.character(Playing.for),
      Jumper.No.              = as.numeric(Jumper.No.),
      Season                  = as.numeric(Season),
      Round                   = as.character(Round),
      Date                    = as.character(Date),
      Kicks                   = as.numeric(Kicks),
      Handballs               = as.numeric(Handballs),
      Disposals               = as.numeric(Kicks) + as.numeric(Handballs),
      Marks                   = as.numeric(Marks),
      Goals                   = as.numeric(Goals),
      Behinds                 = as.numeric(Behinds),
      Hit.Outs                = as.numeric(Hit.Outs),
      Tackles                 = as.numeric(Tackles),
      Rebounds                = as.numeric(Rebounds),
      Inside.50s              = as.numeric(Inside.50s),
      Clearances              = as.numeric(Clearances),
      Clangers                = as.numeric(Clangers),
      Frees.For               = as.numeric(Frees.For),
      Frees.Against           = as.numeric(Frees.Against),
      Brownlow.Votes          = as.numeric(Brownlow.Votes),
      Contested.Possessions   = as.numeric(Contested.Possessions),
      Uncontested.Possessions = as.numeric(Uncontested.Possessions),
      Contested.Marks         = as.numeric(Contested.Marks),
      Marks.Inside.50         = as.numeric(Marks.Inside.50),
      One.Percenters          = as.numeric(One.Percenters),
      Bounces                 = as.numeric(Bounces),
      Goal.Assists            = as.numeric(Goal.Assists),
      Venue                   = as.character(Venue),
      Attendance              = as.numeric(Attendance),
      Home.team               = as.character(Home.team),
      Away.team               = as.character(Away.team),
      Home.score              = as.numeric(Home.score),
      Away.score              = as.numeric(Away.score)
    )
}

fetch_season <- function(year) {
  message("  Fetching ", year, "...")

  df <- tryCatch(
    fetch_player_stats(season = year, source = "afltables"),
    error = function(e) { warning("Fetch failed for ", year, ": ", e$message); NULL }
  )

  if (is.null(df) || nrow(df) == 0) {
    warning("No data for season ", year)
    return(NULL)
  }

  cleaned <- clean_season(df)

  # For Opening Round seasons, shift numeric rounds down by 1 to align with AFL API
  # (Opening Round = "0", Rd 1 = "1"). Finals labels (EF, QF, etc.) are unchanged.
  if (has_opening_round(year)) {
    cleaned <- cleaned %>%
      mutate(Round = {
        n <- suppressWarnings(as.integer(Round))
        if_else(!is.na(n), as.character(n - 1L), Round)
      })
  }

  cleaned
}

new_data <- map(seasons_to_fetch, fetch_season) %>%
  compact() %>%
  bind_rows()

####################################################################################
# Write one CSV per season
####################################################################################

new_data %>%
  group_by(Season) %>%
  group_walk(function(df, key) {
    df <- df %>% mutate(Season = key$Season)
    file_path <- file.path(output_dir, paste0("afltables_player_stats_", key$Season, ".csv"))
    write.csv(df, file_path, row.names = FALSE)
    message("  Wrote ", nrow(df), " rows to ", basename(file_path))
  })

message("Done.")
