####################################################################################
# Script-file:   brownlow_data.R
# Project:       AFLPlayerData
# Author:        Cooper Denny
#
# Purpose:       Joins AFL player stats, coaches votes and Brownlow votes
#                into a single dataset for modelling
####################################################################################

source("setup.R")

output_path <- "Player Data/Brownlow Data/brownlow_data.csv"
dir.create("Player Data/Brownlow Data", showWarnings = FALSE, recursive = TRUE)

####################################################################################
# AFL Tables player stats (Brownlow votes + jumper numbers)
####################################################################################

afltables_player_stats <- list.files("Player Data/AFL Tables", pattern = "\\.csv$", full.names = TRUE) %>%
  map_df(~read_csv(., col_types = cols(.default = "c"))) %>%
  mutate(
    Playing.for    = as.character(Playing.for),
    Jumper.No.     = as.numeric(Jumper.No.),
    Season         = as.numeric(Season),
    Round          = as.character(Round),
    Brownlow.Votes = replace(as.numeric(Brownlow.Votes), is.na(as.numeric(Brownlow.Votes)), 0)
  ) %>%
  filter(!Round %in% c("GF", "PF", "SF", "EF", "QF")) %>%
  transmute(
    Team.Name = case_when(
      Playing.for == "Greater Western Sydney" ~ "GWS Giants",
      Playing.for == "Gold Coast"             ~ "Gold Coast Suns",
      Playing.for == "Sydney"                 ~ "Sydney Swans",
      Playing.for == "Adelaide"               ~ "Adelaide Crows",
      Playing.for == "Geelong"                ~ "Geelong Cats",
      Playing.for == "West Coast"             ~ "West Coast Eagles",
      TRUE                                    ~ Playing.for
    ),
    Player.Jumper.Number = Jumper.No.,
    Year                 = Season,
    Round.Number         = Round,
    Date                 = as.character(Date),
    Brownlow.Votes
  ) %>%
  mutate(
    Player.Jumper.Number = case_when(
      Player.Jumper.Number == 28 & Team.Name == "West Coast Eagles" & Year == 2022                                         ~ 43,
      Player.Jumper.Number == 36 & Team.Name == "West Coast Eagles" & Year == 2022 & Round.Number %in% c("1", "2")        ~ 43,
      Player.Jumper.Number == 23 & Team.Name == "Collingwood"       & Year == 2018                                         ~ 41,
      TRUE ~ Player.Jumper.Number
    )
  )

####################################################################################
# AFL API player stats
####################################################################################

afl_player_stats <- read.csv("Player Data/AFL/afl_player_stats.csv")

afl_player_details <- read.csv("Player Data/AFL/afl_player_details.csv") %>%
  select(Player.ID, Year, Position)

afl_player_stats <- afl_player_stats %>%
  merge(afl_player_details, by = c("Player.ID", "Year")) %>%
  mutate(
    Team.Name     = recode(Team.Name,     "GWS GIANTS" = "GWS Giants", "Gold Coast SUNS" = "Gold Coast Suns"),
    Opponent.Name = recode(Opponent.Name, "GWS GIANTS" = "GWS Giants", "Gold Coast SUNS" = "Gold Coast Suns")
  ) %>%
  filter(case_when(
    Year == 2020 ~ Round.Number <= 18,
    Year >= 2023 ~ Round.Number <= 24,
    TRUE         ~ Round.Number <= 23
  )) %>%
  mutate(
    Uncontested.Marks       = Marks - Contested.Marks,
    Uncontested.Possessions = Total.Possessions - Contested.Possessions,
    Effective.Handballs     = Effective.Disposals - Effective.Kicks,
    Margin                  = Team.Total - Opponent.Total
  ) %>%
  mutate(
    First.Name = case_when(
      Player.ID == "CD_I296225"  ~ "Willie",
      Player.ID == "CD_I1000887" ~ "Mitch",
      Player.ID == "CD_I1002235" ~ "Cameron",
      Player.ID == "CD_I1002353" ~ "Mitch",
      Player.ID == "CD_I1002770" ~ "Callum L.",
      Player.ID == "CD_I1005721" ~ "Josh",
      Player.ID == "CD_I1006148" ~ "Bobby",
      Player.ID == "CD_I1009208" ~ "Matt",
      Player.ID == "CD_I1009320" ~ "Hewago",
      Player.ID == "CD_I1010174" ~ "Mitch",
      Player.ID == "CD_I240406"  ~ "Josh J.",
      Player.ID == "CD_I260310"  ~ "Nathan",
      Player.ID == "CD_I290540"  ~ "Cameron",
      Player.ID == "CD_I290733"  ~ "Cameron",
      Player.ID == "CD_I293479"  ~ "Cameron",
      Player.ID == "CD_I293813"  ~ "Tom J.",
      Player.ID == "CD_I294823"  ~ "Tim",
      Player.ID == "CD_I298446"  ~ "Josh",
      Player.ID == "CD_I990609"  ~ "Charlie",
      Player.ID == "CD_I993107"  ~ "Harry",
      Player.ID == "CD_I993820"  ~ "Tom",
      Player.ID == "CD_I998167"  ~ "Tom",
      Player.ID == "CD_I998256"  ~ "Reuben",
      Player.ID == "CD_I1004995" ~ "Jordon",
      Player.ID == "CD_I1008185" ~ "Ned",
      TRUE ~ First.Name
    ),
    Surname = case_when(
      Player.ID == "CD_I294178"  ~ "Dewar",
      Player.ID == "CD_I994185"  ~ "De Goey",
      Player.ID == "CD_I996464"  ~ "MacPherson",
      TRUE ~ Surname
    )
  )

####################################################################################
# Coaches votes
####################################################################################

coaches_votes <- read.csv("Player Data/AFLCA Votes/aflca_votes.csv") %>%
  filter(Year >= 2015) %>%
  select(-Team.Name)

# Fix name discrepancies between coaches votes and AFL API sources.
# First.Name and Surname fixes are split across two mutate calls because some
# Surname fixes depend on First.Name corrections made in the first call.
coaches_votes <- coaches_votes %>%
  mutate(
    First.Name = case_when(
      First.Name == "Alexander" & Surname == "Keath"        ~ "Alex",
      First.Name == "Bailey"    & Surname == "J Williams"   ~ "Bailey J.",
      First.Name == "Callum"    & Surname == "L"            ~ "Callum L.",
      First.Name == "Callum"    & Surname == "L Brown"      ~ "Callum L.",
      First.Name == "Callum"    & Surname == "Brown"        ~ "Callum M.",
      First.Name == "Cameron"   & Surname == "McCarthy"     ~ "Cam",
      First.Name == "Cameron"   & Surname == "Mackenzie"    ~ "Cam",
      First.Name == "James"     & Surname == "Bartel"       ~ "Jimmy",
      First.Name == "Josh"      & Surname == "J Kennedy"    ~ "Josh J.",
      First.Name == "Josh"      & Surname == "Kennedy"      ~ "Josh P.",
      First.Name == "Josh"      & Surname == "Draper"       ~ "Joshua",
      First.Name == "Joshua"    & Surname == "Rachele"      ~ "Josh",
      First.Name == "Joshua"    & Surname == "Weddle"       ~ "Josh",
      First.Name == "Joseph"    & Surname == "Fonti"         ~ "Joe",
      First.Name == "Lachie"    & Surname == "Bramble"      ~ "Lachlan",
      First.Name == "Lachie"    & Surname == "Cowan"        ~ "Lachlan",
      First.Name == "Matt"      & Surname == "Carroll"      ~ "Matthew",
      First.Name == "Matthew"   & Surname == "Roberts"      ~ "Matt",
      First.Name == "Matthew"   & Surname == "Spangher"     ~ "Matt",
      First.Name == "Matthew"   & Surname == "Thomas"       ~ "Matt",
      First.Name == "Michael"   & Surname == "Pyke"         ~ "Mike",
      First.Name == "Mitchell"  & Surname == "Georgiades"   ~ "Mitch",
      First.Name == "Nathan"    & Surname == "Fyfe"          ~ "Nat",
      First.Name == "Nicholas"  & Surname == "Hind"         ~ "Nick",
      First.Name == "Nicholas"  & Surname == "Murray"       ~ "Nick",
      First.Name == "Nicholas"  & Surname == "Newman"       ~ "Nic",
      First.Name == "Samuel"    & Surname == "Durham"       ~ "Sam",
      First.Name == "Scott"     & Surname == "Thompson" & Year == 2017 & Round.Number %in% c(6, 7, 9, 23) ~ "Scott D.",
      First.Name == "Scott"     & Surname == "Thompson" & Year == 2018 ~ "Scott D.",
      First.Name == "Thomas"    & Surname == "Boyd"         ~ "Tom",
      First.Name == "Tom"       & Surname == "J Lynch"      ~ "Tom J.",
      First.Name == "William"   & Surname == "Rioli"        ~ "Willie",
      TRUE ~ First.Name
    )
  ) %>%
  mutate(
    Surname = case_when(
      First.Name == "Angus"     & Surname == "Litherland"   ~ "Dewar",
      First.Name == "Bailey J." & Surname == "J Williams"   ~ "Williams",
      First.Name == "Brendon"   & Surname == "Ah"           ~ "Ah Chee",
      First.Name == "Brent"     & Surname == "MacAffer"     ~ "Macaffer",
      First.Name == "Callum"    & Surname == "Ah"           ~ "Ah Chee",
      First.Name == "Callum L." & Surname %in% c("L", "L Brown") ~ "Brown",
      First.Name == "Connor"    & Surname == "MacDonald"    ~ "Macdonald",
      First.Name == "David"     & Surname == "MacKay"       ~ "Mackay",
      First.Name == "Edward"    & Surname == "Allen"        ~ "Allan",
      First.Name == "Jacob"     & Surname == "Van Rooyen"   ~ "van Rooyen",
      First.Name == "Jamie"     & Surname == "MacMillan"    ~ "Macmillan",
      First.Name == "Jay"       & Surname == "Kennedy-Harris" ~ "Kennedy Harris",
      First.Name == "Joel"      & Surname == "Sudar-Jeffrey" ~ "Jeffrey",
      First.Name == "Jordan"    & Surname == "De"           ~ "De Goey",
      First.Name == "Josh J."   & Surname == "J Kennedy"    ~ "Kennedy",
      First.Name == "Mark"      & Surname == "Lecras"       ~ "LeCras",
      First.Name == "Matt"      & Surname == "De Boer"      ~ "de Boer",
      First.Name == "Mitch"     & Surname == "W Brown"      ~ "Brown",
      First.Name == "Nathan"    & Surname == "Van"          ~ "Van Berlo",
      First.Name == "Tom J."    & Surname == "J Lynch"      ~ "Lynch",
      First.Name == "Malcolm"    & Surname == "Rosas Jr"      ~ "Rosas",
      TRUE ~ Surname
    )
  )

####################################################################################
# Diagnostic: coaches votes rows with no matching AFL player stats entry
####################################################################################

unmatched_cv <- coaches_votes %>%
  anti_join(afl_player_stats, by = c("Year", "Round.Number", "First.Name", "Surname"))

if (nrow(unmatched_cv) > 0) {
  message("WARNING: ", nrow(unmatched_cv), " coaches votes rows did not match AFL player stats:")
  unmatched_cv %>%
    arrange(First.Name, Surname, Year, Round.Number) %>%
    as.data.frame() %>%
    print(row.names = FALSE)

  message("\nAFL API name candidates for unmatched players (by surname + year):")
  unmatched_cv %>%
    distinct(First.Name, Surname, Year) %>%
    arrange(Surname, Year) %>%
    rowwise() %>%
    group_walk(function(row, key) {
      candidates <- afl_player_stats %>%
        filter(Surname == row$Surname, Year == row$Year) %>%
        distinct(First.Name, Surname, Team.Name)
      if (nrow(candidates) > 0) {
        cat(sprintf("\nCoaches votes '%s %s' (%d) → AFL API:\n", row$First.Name, row$Surname, row$Year))
        print(as.data.frame(candidates), row.names = FALSE)
      }
    })
} else {
  message("All coaches votes rows matched AFL player stats.")
}

####################################################################################
# Join all sources
####################################################################################

brownlow_data <- afl_player_stats %>%
  full_join(coaches_votes, by = c("Year", "Round.Number", "First.Name", "Surname")) %>%
  mutate(Round.Number = as.character(Round.Number)) %>%
  merge(afltables_player_stats, by = c("Team.Name", "Player.Jumper.Number", "Year", "Round.Number")) %>%
  arrange(Date, Game.ID, Team.Name, Player.Jumper.Number) %>%
  distinct()

brownlow_data[sapply(brownlow_data, is.infinite)] <- NA
brownlow_data[is.na(brownlow_data)] <- 0

write.csv(brownlow_data, output_path, row.names = FALSE)

message("Done. ", nrow(brownlow_data), " rows saved to ", output_path)
