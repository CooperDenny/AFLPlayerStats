# AFLPlayerStats

R scripts for scraping, cleaning, and storing AFL player and team statistics.

## Scripts

- `afl_player_stats.R` — Fetches player stats via `fitzRoy`, merges with existing CSV, calculates match outcomes, standardises team names. Output: CSV in `Player Data/`
- `afltables_player_stats.R` — Same pipeline but sourced from AFL Tables via `fitzRoy`. Adjusts round numbering to match AFL Tables indexing
- `aflca_votes.R` — Scrapes AFLCA coaches votes leaderboard using `rvest`/`polite`, merges with historical data. Output: CSV in `Player Data/`

## Usage

Run scripts individually for the relevant data source. Each script reads existing CSVs, appends new data, deduplicates, and writes back.

## Packages

`tidyverse`, `fitzRoy`, `rvest`, `polite`, `ordinal`, `knitr`, `unglue`

## Data output

Processed CSVs are saved to the `Player Data/` directory. These CSVs are the primary input for `AFLBrownlowPredictor`.
