# AFLPlayerStats

R scripts for scraping, cleaning, and storing AFL player and team statistics.

## Scripts

- `afl_player_stats.R` — Fetches player stats via `fitzRoy` (`fetch_player_stats_afl`), checks coverage by comparing played game IDs from the fixture against the existing CSV, and re-fetches any season with missing games. Merges fixture scores, calculates match outcomes, standardises team names. Output: single CSV in `Player Data/AFL/`
- `afltables_player_stats.R` — Fetches player stats from AFL Tables via `fitzRoy` (`fetch_player_stats`). Detects missing seasons from per-year CSVs and always re-fetches from `fetch_from_year` onwards. Output: one CSV per season in `Player Data/AFL Tables/`
- `aflca_votes.R` — Fetches AFLCA coaches votes via `fitzRoy` (`fetch_coaches_votes`). Detects missing seasons and always re-fetches from `fetch_from_year` onwards. Parses player name and team abbreviation from the `Player.Name` field. Output: CSV in `Player Data/AFLCA Votes/`

## Configuration

Each script has a `fetch_from_year` variable at the top. Update this after a full run to avoid re-fetching historical data unnecessarily. Current values:
- `afl_player_stats.R`: 2026
- `afltables_player_stats.R`: 2026
- `aflca_votes.R`: 2026

## Usage

Run scripts individually for the relevant data source. Each script automatically determines which seasons need updating — no manual round or season configuration required.

## Packages

`tidyverse`, `fitzRoy`

## Data output

Processed CSVs are saved to subdirectories of `Player Data/`. These CSVs are the primary input for `AFLBrownlowPredictor`.
