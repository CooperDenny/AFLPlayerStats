library(fitzRoy)
library(tidyverse)

afl_player_details <- data.frame(
)

for (y in 2015:2026){
  afl_player_details_y <- fetch_player_details_afl(season = y)
  
  afl_player_details <- bind_rows(afl_player_details, afl_player_details_y)
}

afl_player_details <- afl_player_details %>% select(firstName, surname, season, providerId, position)

colnames(afl_player_details) <- c("First.Name", "Surname", "Year", "Player.ID", "Position")

write.csv(afl_player_details, "Player Data/AFL/afl_player_details.csv", row.names = FALSE)
