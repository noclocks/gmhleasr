
#  ------------------------------------------------------------------------
#
# Title : Setup Testing Environment
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

# libraries ---------------------------------------------------------------
library(httr2, warn.conflicts = FALSE)
library(httptest2, warn.conflicts = FALSE)
library(withr, warn.conflicts = FALSE)
library(fs, warn.conflicts = FALSE)


# variables ---------------------------------------------------------------

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


