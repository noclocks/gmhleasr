
#  ------------------------------------------------------------------------
#
# Title : Package Development Script
#    By : Jimmy Briggs
#  Date : 2024-08-13
#
#  ------------------------------------------------------------------------

usethis::use_vignette("gmhleasr")

c(
  "entrata_api_request"
) |>
  purrr::walk(usethis::use_test, open = FALSE)
