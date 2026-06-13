# **AFLPlayerStats**

**AFLPlayerStats** is a collection of R scripts and CSV files for downloading, cleaning, and storing Australian Football League (AFL) player statistics. Each script automatically detects which seasons are missing or incomplete and fetches only what is needed — no manual round or season configuration required.

## **Project Structure**

- **R Scripts**: Handle data acquisition and processing for player statistics, coaches votes, and match results.
- **CSV Files**: Store the processed data in `Player Data/`, organised by source.

## **Requirements**

- `tidyverse`
- `fitzRoy`

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

Fetches AFLCA coaches votes via `fitzRoy` (`fetch_coaches_votes`). Detects missing seasons and always re-fetches from `fetch_from_year` onwards. Parses the player name and team abbreviation from the returned `Player.Name` field.

**Output**: `Player Data/AFLCA Votes/aflca_votes.csv`

---

## **Configuration**

Each script has a `fetch_from_year` variable at the top. After a full run, update this to the current year to avoid unnecessarily re-fetching historical data on subsequent runs.

## **Data output**

These CSVs are the primary input for [AFLBrownlowPredictor](https://github.com/CooperDenny/AFLBrownlowPredictor).
