packages <- c("tidyverse", "fitzRoy", "ordinal", "knitr", "unglue")

installed <- rownames(installed.packages())
to_install <- packages[!packages %in% installed]
if (length(to_install) > 0) install.packages(to_install)

invisible(lapply(packages, library, character.only = TRUE))
