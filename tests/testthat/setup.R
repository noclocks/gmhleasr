# setup -------------------------------------------------------------------

library(httr2, warn.conflicts = FALSE)
library(httptest2, warn.conflicts = FALSE)
library(withr, warn.conflicts = FALSE)

Sys.setlocale("LC_COLLATE", "C")

options(
  httptest2.verbose = TRUE,
  httptest.debug.trace = TRUE,
  warn = 1
)

cfg_file_pkg <- fs::path_package(package = "gmhleasr", "config/config.encrypted.yml")

cfg_decrypted <- decrypt_cfg_file(cfg_file_pkg)

cfg <- config::get("entrata")

cfg_test <- list(
  username = "testuser",
  password = "testpass",
  base_url = "https://api.entrata.com"
)

test_prop_ids <- c(
  "739084",
  "641240",
  "676055",
  "952515",
  "518041",
  "518042",
  "833617",
  "1197887",
  "1143679",
  "1311849"
)

if (is_github()) {
  withr::defer(
    {
      file.remove(cfg_decrypted)
      Sys.unsetenv("R_CONFIG_FILE")
    },
    testthat::teardown_env()
  )
}
