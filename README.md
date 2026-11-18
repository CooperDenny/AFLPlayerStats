# **AFLPlayerStats**

**AFLPlayerStats** is a collection of R scripts and CSV files for downloading, cleaning, and storing Australian Football League (AFL) player statistics. The player-stats scripts detect which seasons are missing or incomplete and fetch only what is needed; coaches votes are added a round at a time.

## **Project Structure**

- **R Scripts**: Handle data acquisition and processing for player statistics, coaches votes, and match results.
- **CSV Files**: Store the processed data in `Player Data/`, organised by source.

## **Requirements**

- `tidyverse`
- `fitzRoy`

`setup.R` also installs `ordinal`, `knitr` and `unglue`, which the Brownlow model uses.

## **Scripts**

### afl_player_stats.R

Fetches AFL player stats from the official AFL API via `fitzRoy`. On each run it checks which games have been played (via the fixture) and compares against the existing CSV, re-fetching any season with missing games. Merges fixture scores, calculates match outcomes (W/L/D), and standardises team names.

**Output**: `Player Data/AFL/afl_player_stats.csv`

---

### afltables_player_stats.R

Fetches player stats from AFL Tables via `fitzRoy`. Detects which seasons are absent from the per-year CSVs and always re-fetches from `fetch_from_year` onwards.

**Output**: `Player Data/AFL Tables/afltables_player_stats_{year}.csv`

---

### aflca_votes.R

Defines `append_aflca_votes_round(year, round)`, which fetches one round of AFLCA coaches votes via `fitzRoy` (`fetch_coaches_votes`) and writes it into the CSV, replacing that round if it is already there. Rounds use AFL API numbering (Opening Round = round 0 from 2024); only games whose votes are complete are kept.

```r
source("aflca_votes.R")
append_aflca_votes_round(year = 2026, round = 12)
```

**Output**: `Player Data/AFLCA Votes/aflca_votes.csv`

---

### afl_player_details.R

Fetches each player's listed position for every season from 2015 to the current year (`fetch_player_details_afl`).

**Output**: `Player Data/AFL/afl_player_details.csv`

---

### brownlow_data.R

Joins the AFL API stats, player positions, coaches votes and AFL Tables Brownlow votes into the modelling dataset. Player names differ between sources, so it applies a table of name fixes and prints any coaches-votes rows that still don't match, with candidate names, so new mismatches are easy to fix.

**Output**: `Player Data/Brownlow Data/brownlow_data.csv`

---

### setup.R

Installs any missing packages and loads them. Sourced by the other scripts.

---

## **Configuration**

`afl_player_stats.R` and `afltables_player_stats.R` have a `fetch_from_year` variable at the top:

- `afl_player_stats.R` checks every season from `fetch_from_year` against the fixture and re-fetches any with missing games. Raising it skips the fixture checks for older seasons.
- `afltables_player_stats.R` always re-fetches from `fetch_from_year` onwards, plus any season with no CSV on disk.

When nothing needs updating, `afl_player_stats.R` stops without writing; this is safe to `source()` in RStudio.

## **Data output**

These CSVs are the primary input for [AFLBrownlowPredictor](https://github.com/CooperDenny/AFLBrownlowPredictor).
