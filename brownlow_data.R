####################################################################################
#	Script-file:   brownlow_data.R
#	Project:       AFL Stats
# Author:        Cooper Denny
#
# Purpose:  	   Code to transform and summarise AFL Brownlow data from 2015-
####################################################################################

source("setup.R")

####################################################################################
####################################################################################

# Read the existing AFL player stats data from a CSV file
afltables_player_stats <- list.files(path = "./Player Data/AFL Tables", pattern = "*.csv", full.names = TRUE) %>%
  map_df(~read_csv(., col_types = cols(.default = "c")))

# Summarize the player stats data with specific transformations
afltables_player_stats <- afltables_player_stats %>% 
  summarise(ID = as.integer(ID),
            First.name = as.character(First.name),
            Surname = as.character(Surname),
            Playing.for = as.character(Playing.for),
            Jumper.No. = as.numeric(Jumper.No.),
            Season = as.numeric(Season),
            Round = as.character(Round),
            Date = as.character(Date),
            Kicks = as.numeric(Kicks),
            Handballs = as.numeric(Handballs),
            Disposals = as.numeric(Disposals),
            Marks = as.numeric(Marks),
            Goals = as.numeric(Goals),
            Behinds = as.numeric(Behinds),
            Hit.Outs = as.numeric(Hit.Outs),
            Tackles = as.numeric(Tackles),
            Rebounds = as.numeric(Rebounds),
            Inside.50s = as.numeric(Inside.50s),
            Clearances = as.numeric(Clearances),
            Clangers = as.numeric(Clangers),
            Frees.For = as.numeric(Frees.For),
            Frees.Against = as.numeric(Frees.Against),
            Brownlow.Votes = as.numeric(Brownlow.Votes),
            Contested.Possessions = as.numeric(Contested.Possessions),
            Uncontested.Possessions = as.numeric(Uncontested.Possessions),
            Contested.Marks = as.numeric(Contested.Marks),
            Marks.Inside.50 = as.numeric(Marks.Inside.50),
            One.Percenters = as.numeric(One.Percenters),
            Bounces = as.numeric(Bounces),
            Goal.Assists = as.numeric(Goal.Assists),
            Venue = as.character(Venue),
            Attendance = as.numeric(Attendance),
            Home.team = as.character(Home.team),
            Away.team = as.character(Away.team), 
            Home.score = as.numeric(Home.score),
            Away.score = as.numeric(Away.score))

afltables_player_stats <- afltables_player_stats %>%
  select("Playing.for", "Jumper.No.", "Season", "Round", "Date", "Brownlow.Votes") %>%
  filter(Round != "GF", Round != "PF", Round != "SF", Round != "EF", Round != "QF")

colnames(afltables_player_stats) <- c("Team.Name", "Player.Jumper.Number", "Year", "Round.Number", "Date", "Brownlow.Votes")

afltables_player_stats["Team.Name"][afltables_player_stats["Team.Name"] == "Greater Western Sydney"] <- "GWS Giants"
afltables_player_stats["Team.Name"][afltables_player_stats["Team.Name"] == "Gold Coast"] <- "Gold Coast Suns"
afltables_player_stats["Team.Name"][afltables_player_stats["Team.Name"] == "Sydney"] <- "Sydney Swans"
afltables_player_stats["Team.Name"][afltables_player_stats["Team.Name"] == "Adelaide"] <- "Adelaide Crows"
afltables_player_stats["Team.Name"][afltables_player_stats["Team.Name"] == "Geelong"] <- "Geelong Cats"
afltables_player_stats["Team.Name"][afltables_player_stats["Team.Name"] == "West Coast"] <- "West Coast Eagles"

afltables_player_stats$Brownlow.Votes <- replace(afltables_player_stats$Brownlow.Votes, 
                                                 is.na(afltables_player_stats$Brownlow.Votes), 
                                                 0)

afltables_player_stats$Player.Jumper.Number <- replace(afltables_player_stats$Player.Jumper.Number,
                                                       afltables_player_stats$Player.Jumper.Number == 28 & afltables_player_stats$Team.Name == "West Coast Eagles" & afltables_player_stats$Year == 2022,
                                                       43)

afltables_player_stats$Player.Jumper.Number <- replace(afltables_player_stats$Player.Jumper.Number,
                                                       afltables_player_stats$Player.Jumper.Number == 36 & afltables_player_stats$Team.Name == "West Coast Eagles" & afltables_player_stats$Year == 2022 & afltables_player_stats$Round.Number == 1,
                                                       43)

afltables_player_stats$Player.Jumper.Number <- replace(afltables_player_stats$Player.Jumper.Number,
                                                       afltables_player_stats$Player.Jumper.Number == 36 & afltables_player_stats$Team.Name == "West Coast Eagles" & afltables_player_stats$Year == 2022 & afltables_player_stats$Round.Number == 2,
                                                       43)

afltables_player_stats$Player.Jumper.Number <- replace(afltables_player_stats$Player.Jumper.Number,
                                                       afltables_player_stats$Player.Jumper.Number == 23 & afltables_player_stats$Team.Name == "Collingwood" & afltables_player_stats$Year == 2018,
                                                       41)



##################

afl_player_stats <- read.csv("Player Data/AFL/afl_player_stats.csv")

afl_player_details <- read.csv("Player Data/AFL/afl_player_details.csv") %>% select(Player.ID, Year, Position)

afl_player_stats <- merge(afl_player_stats, afl_player_details, by = c("Player.ID", "Year"))

afl_player_stats["Team.Name"][afl_player_stats["Team.Name"] == "GWS GIANTS"] <- "GWS Giants"
afl_player_stats["Team.Name"][afl_player_stats["Team.Name"] == "Gold Coast SUNS"] <- "Gold Coast Suns"

afl_player_stats["Opponent.Name"][afl_player_stats["Opponent.Name"] == "GWS GIANTS"] <- "GWS Giants"
afl_player_stats["Opponent.Name"][afl_player_stats["Opponent.Name"] == "Gold Coast SUNS"] <- "Gold Coast Suns"

afl_player_stats <- afl_player_stats %>% 
  filter(case_when(Year=='2020' ~ Round.Number <= 18,
                   Year=='2023' ~ Round.Number <= 24,
                   Year=='2024' ~ Round.Number <= 24,
                   TRUE ~ Round.Number <= 23))

afl_player_stats$Uncontested.Marks <- afl_player_stats$Marks - afl_player_stats$Contested.Marks
afl_player_stats$Uncontested.Possessions <- afl_player_stats$Total.Possessions - afl_player_stats$Contested.Possessions
afl_player_stats$Effective.Handballs <- afl_player_stats$Effective.Disposals - afl_player_stats$Effective.Kicks
afl_player_stats$Margin <- afl_player_stats$Team.Total - afl_player_stats$Opponent.Total

afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I296225", "Willie")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1000887", "Mitch")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1002235", "Cameron")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1002353", "Mitch")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1002770", "Callum L.")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1005721", "Josh")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1006148", "Bobby")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1009208", "Matt")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1009320", "Hewago")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1010174", "Mitch")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I240406", "Josh J.")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I260310", "Nathan")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I290540", "Cameron")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I290733", "Cameron")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I293479", "Cameron")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I293813", "Tom J.")
afl_player_stats$Surname <- replace(afl_player_stats$Surname, afl_player_stats$Player.ID == "CD_I294178", "Dewar")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I294823", "Tim")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I298446", "Josh")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I990609", "Charlie")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I993107", "Harry")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I993820", "Tom")
afl_player_stats$Surname <- replace(afl_player_stats$Surname, afl_player_stats$Player.ID == "CD_I994185", "De Goey")
afl_player_stats$Surname <- replace(afl_player_stats$Surname, afl_player_stats$Player.ID == "CD_I996464", "MacPherson")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I998167", "Tom")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I998256", "Reuben")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1004995", "Jordon")
afl_player_stats$First.Name <- replace(afl_player_stats$First.Name, afl_player_stats$Player.ID == "CD_I1008185", "Ned")

afl_player_stats %>% group_by(Player.ID, First.Name, Surname) %>% summarise(
  n = n()) %>% group_by(Player.ID) %>% summarise(
    n = n()
  ) %>% arrange(desc(n))


#########

coaches_votes <- read.csv("Player Data/AFLCA Votes/aflca_votes.csv") %>% 
  filter(Year >= 2015) %>% select(-Team.Name)
coaches_votes$Coaches.Votes <- as.character(coaches_votes$Coaches.Votes)

coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Alexander" &
                                      coaches_votes$Surname == "Keath", 
                                    "Alex")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Angus" &
                                   coaches_votes$Surname == "Litherland", 
                                 "Dewar")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Brendon" &
                                   coaches_votes$Surname == "Ah", 
                                 "Ah Chee")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Brent" &
                                   coaches_votes$Surname == "MacAffer", 
                                 "Macaffer")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Callum" &
                                   coaches_votes$Surname == "Ah", 
                                 "Ah Chee")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Callum" &
                                      coaches_votes$Surname == "L", 
                                    "Callum L.")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Callum L." &
                                   coaches_votes$Surname == "L", 
                                 "Brown")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Callum" &
                                      coaches_votes$Surname == "Brown", 
                                    "Callum M.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "James" &
                                      coaches_votes$Surname == "Bartel", 
                                    "Jimmy")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Cameron" &
                                      coaches_votes$Surname == "McCarthy", 
                                    "Cam")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "David" &
                                   coaches_votes$Surname == "MacKay", 
                                 "Mackay")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Jamie" &
                                   coaches_votes$Surname == "MacMillan", 
                                 "Macmillan")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Jay" &
                                   coaches_votes$Surname == "Kennedy-Harris", 
                                 "Kennedy Harris")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Joel" &
                                   coaches_votes$Surname == "Sudar-Jeffrey", 
                                 "Jeffrey")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Jordan" &
                                   coaches_votes$Surname == "De", 
                                 "De Goey")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Josh" &
                                      coaches_votes$Surname == "Kennedy", 
                                    "Josh P.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Josh" &
                                      coaches_votes$Surname == "J Kennedy", 
                                    "Josh J.")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Josh J." &
                                   coaches_votes$Surname == "J Kennedy", 
                                 "Kennedy")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Joshua" &
                                      coaches_votes$Surname == "Rachele", 
                                    "Josh")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Mark" &
                                   coaches_votes$Surname == "Lecras", 
                                 "LeCras")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Matt" &
                                   coaches_votes$Surname == "De Boer", 
                                 "de Boer")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Matthew" &
                                      coaches_votes$Surname == "Spangher", 
                                    "Matt")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Matthew" &
                                      coaches_votes$Surname == "Thomas", 
                                    "Matt")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Michael" &
                                      coaches_votes$Surname == "Pyke", 
                                    "Mike")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Mitch" &
                                   coaches_votes$Surname == "W Brown", 
                                 "Brown")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Mitchell" &
                                      coaches_votes$Surname == "Georgiades", 
                                    "Mitch")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Nathan" &
                                   coaches_votes$Surname == "Van", 
                                 "Van Berlo")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Nicholas" &
                                      coaches_votes$Surname == "Hind", 
                                    "Nick")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Nicholas" &
                                      coaches_votes$Surname == "Newman", 
                                    "Nic")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Scott" &
                                      coaches_votes$Surname == "Thompson" & 
                                      coaches_votes$Year == "2014" & 
                                      coaches_votes$Round.Number == "4" &
                                      coaches_votes$Coaches.Votes == "10", 
                                    "Scott D.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Scott" &
                                      coaches_votes$Surname == "Thompson" & 
                                      coaches_votes$Year == "2014" & 
                                      coaches_votes$Round.Number == "14" &
                                      coaches_votes$Coaches.Votes == "7", 
                                    "Scott D.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Scott" &
                                      coaches_votes$Surname == "Thompson" & 
                                      coaches_votes$Year == "2014" & 
                                      coaches_votes$Round.Number == "21", 
                                    "Scott D.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Scott" &
                                      coaches_votes$Surname == "Thompson" &
                                      coaches_votes$Year == "2017" & 
                                      coaches_votes$Round.Number == "6",
                                    "Scott D.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Scott" &
                                      coaches_votes$Surname == "Thompson" &
                                      coaches_votes$Year == "2017" & 
                                      coaches_votes$Round.Number == "7",
                                    "Scott D.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Scott" &
                                      coaches_votes$Surname == "Thompson" &
                                      coaches_votes$Year == "2017" & 
                                      coaches_votes$Round.Number == "9",
                                    "Scott D.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Scott" &
                                      coaches_votes$Surname == "Thompson" &
                                      coaches_votes$Year == "2017" & 
                                      coaches_votes$Round.Number == "23",
                                    "Scott D.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Scott" &
                                      coaches_votes$Surname == "Thompson" &
                                      coaches_votes$Year == "2018",
                                    "Scott D.")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Thomas" &
                                      coaches_votes$Surname == "Boyd", 
                                    "Tom")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Tom" &
                                      coaches_votes$Surname == "J Lynch", 
                                    "Tom J.")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Tom J." &
                                   coaches_votes$Surname == "J Lynch", 
                                 "Lynch")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "William" &
                                      coaches_votes$Surname == "Rioli", 
                                    "Willie")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Bailey" &
                                      coaches_votes$Surname == "J Williams", 
                                    "Bailey J.")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Bailey J." &
                                   coaches_votes$Surname == "J Williams", 
                                 "Williams")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Connor" &
                                   coaches_votes$Surname == "MacDonald", 
                                 "Macdonald")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Joshua" &
                                      coaches_votes$Surname == "Weddle", 
                                    "Josh")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Samuel" &
                                      coaches_votes$Surname == "Durham", 
                                    "Sam")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Lachie" &
                                      coaches_votes$Surname == "Bramble", 
                                    "Lachlan")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Jacob" &
                                   coaches_votes$Surname == "Van Rooyen", 
                                 "van Rooyen")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Callum" &
                                      coaches_votes$Surname == "L Brown", 
                                    "Callum L.")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Callum L." &
                                   coaches_votes$Surname == "L Brown", 
                                 "Brown")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Matthew" &
                                      coaches_votes$Surname == "Roberts", 
                                    "Matt")
coaches_votes$First.Name <- replace(coaches_votes$First.Name, 
                                    coaches_votes$First.Name == "Josh" &
                                      coaches_votes$Surname == "Draper", 
                                    "Joshua")
coaches_votes$Surname <- replace(coaches_votes$Surname, 
                                 coaches_votes$First.Name == "Edward" &
                                   coaches_votes$Surname == "Allen", 
                                 "Allan")
##################

brownlow_data1 <- full_join(afl_player_stats, coaches_votes, by = c("Year", "Round.Number", "First.Name", "Surname"))

nrow(brownlow_data1 %>% filter(is.na(Game.ID)) %>% group_by(First.Name,Surname) %>% summarise(
  n = n()
))

brownlow_data1$Round.Number <- as.character(brownlow_data1$Round.Number)

brownlow_data <- merge(brownlow_data1, afltables_player_stats, 
                       by = c("Team.Name", "Player.Jumper.Number", "Year", "Round.Number")) %>% 
  arrange(Date, Game.ID, Team.Name, Player.Jumper.Number) 

nrow(brownlow_data %>% filter(is.na(Game.ID)) %>% group_by(First.Name,Surname) %>% summarise(
  n = n()
))

brownlow_data <- brownlow_data %>% distinct()

is.na(brownlow_data)<-sapply(brownlow_data, is.infinite)
brownlow_data[is.na(brownlow_data)]<-0

write.csv(brownlow_data, "C:/Users/coope/Documents/R Project/AFL Data/CSV Files/Player Stats\\brownlow_data.csv", row.names=FALSE)
write.csv(brownlow_data %>% filter(Year <= 2024), "C:/Users/coope/Documents/R Project/AFLBrownlowPredictor\\brownlow_data.csv", row.names=FALSE)
