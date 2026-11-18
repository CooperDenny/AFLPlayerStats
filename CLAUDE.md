# AFLPlayerStats

R scripts for scraping, cleaning, and storing AFL player and team statistics.

## Scripts

- `afl_player_stats.R` — Fetches player stats via `fitzRoy` (`fetch_player_stats_afl`), checks coverage by comparing played game IDs from the fixture against the existing CSV, and re-fetches any season with missing games. Merges fixture scores, calculates match outcomes, standardises team names. Output: single CSV in `Player Data/AFL/`. Stops early when up to date; never call bare `quit()` (it ends an interactive RStudio session when `source()`d).
- `afltables_player_stats.R` — Fetches player stats from AFL Tables via `fitzRoy` (`fetch_player_stats`). Fetches seasons missing on disk and always re-fetches from `fetch_from_year` onwards. Shifts numeric rounds down by one in Opening Round seasons to align with the AFL API. Output: one CSV per season in `Player Data/AFL Tables/`
- `aflca_votes.R` — Defines `append_aflca_votes_round(year, round)`: fetches one round of AFLCA coaches votes (`fetch_coaches_votes`), offsetting the round by +1 in Opening Round seasons (2024+), and replaces that round in the CSV. Run it per round; it does not auto-detect missing seasons. Output: CSV in `Player Data/AFLCA Votes/`
- `afl_player_details.R` — Player positions per season, 2015 to the current year. Output: `Player Data/AFL/afl_player_details.csv`
- `brownlow_data.R` — Joins all sources into `Player Data/Brownlow Data/brownlow_data.csv`, the AFLBrownlowPredictor input. Name differences between sources are fixed in `case_when` tables (by `Player.ID` for AFL API, by name for coaches votes); the script prints unmatched coaches-votes rows with candidates.
- `setup.R` — Installs/loads packages; sourced by the other scripts.

## Configuration

`fetch_from_year` at the top of:
- `afl_player_stats.R`: 2015 (coverage check runs from here; raise it to skip older fixture checks)
- `afltables_player_stats.R`: 2026 (always re-fetched from here)

## Usage

Run the stats scripts individually; they work out which seasons need updating. Add coaches votes with `append_aflca_votes_round()`. Then run `brownlow_data.R`.

## Packages

`tidyverse`, `fitzRoy`

## Data output

Processed CSVs are saved to subdirectories of `Player Data/`. `Player Data/Brownlow Data/brownlow_data.csv` is the primary input for `AFLBrownlowPredictor`.
