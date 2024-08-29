# setup -------------------------------------------------------------------

library(httr2, warn.conflicts = FALSE)
library(httptest2, warn.conflicts = FALSE)

Sys.setlocale("LC_COLLATE", "C")

options(
  httptest2.verbose = TRUE,
  httptest.debug.trace = TRUE,
  warn = 1
)

cfg <- config::get("entrata", file = here::here("config.yml"))
cfg_test <- list(
  username = "testuser",
  password = "testpass",
  base_url = "https://api.entrata.com"
)
