# **AFLPlayerData**

**AFLPlayerData** is a collection of R scripts and CSV files designed for downloading, analyzing, and managing Australian Football League (AFL) player data. This project leverages several R libraries to scrape, clean, transform, and summarize player and team data, providing insights into player performance and AFL match outcomes.

## **Project Structure**

- **R Scripts**: These scripts handle the data acquisition and processing tasks, focusing on player statistics, coaches' votes, and team results.
- **CSV Files**: Store the processed data, allowing for easy access and further analysis.

## **Requirements**

The project uses the following R packages:

- `tidyverse`: For data manipulation and visualization.
- `fitzRoy`: To access AFL data, including player statistics and fixtures.
- `rvest` and `polite`: For web scraping.
- `ordinal`: For ordinal logistic regression (in coaches votes processing).
- `knitr`: For dynamic report generation.
- `unglue`: For flexible string manipulation.

Ensure that these packages are installed and loaded in your R environment before running the scripts.

## **Scripts**

### afl_player_stats.R

**Purpose**: Scrape, clean, and store AFL player and team data.

#### Key Functions:

- **Data Fetching**: Uses the fitzRoy package to download player statistics for a specified season and round from the AFL.
- **Data Cleaning**: Merges new data with existing data, calculates match outcomes, and standardizes team names.
- **Data Transformation**: Summarizes player statistics by calculating key metrics like disposals, using both kicks and handballs. Also converts data types for accurate analysis.
- **Data Integration**: Merges new statistics with historical data, ensuring all entries are unique and complete.
- **Data Exporting**: Saves the updated player statistics to a CSV file, preserving data for further analysis and usage.

### afltables_player_stats.R

**Purpose**: Transform and summarize AFL player statistics from AFL Tables.

#### Key Functions:

- **Data Fetching**: Uses the fitzRoy package to download player statistics for a specified season and round from AFL Tables.
- **Data Cleaning**: Adjusts round numbers to align with AFL Tables' indexing, and cleans and formats fields such as Jumper.No. to remove unnecessary characters and ensure consistency.
- **Data Transformation**: Summarizes player statistics by calculating key metrics like disposals, using both kicks and handballs. Also converts data types for accurate analysis.
- **Data Integration**: Merges new statistics with historical data, ensuring all entries are unique and complete.
- **Data Exporting**: Saves the updated player statistics to a CSV file, preserving data for further analysis and usage.

### aflca_votes.R

**Purpose**: Transform and summarize AFL Coaches Association (AFLCA) votes data.

#### Key Functions:

- **Data Scraping**: Uses `rvest` and `polite` to scrape the coaches' votes leaderboard from the AFLCA website.
- **Data Transformation**: Cleans and structures the scraped data into a usable format.
- **Data Integration**: Combines new votes data with historical data, ensuring no duplicates.
- **Data Exporting**: Saves the updated votes data to a CSV file for further analysis.


