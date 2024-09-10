
#  ------------------------------------------------------------------------
#
# Title : Environment Related Test Helpers
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------


# CI/CD (general) ---------------------------------------------------------

is_cicd <- function() {
  is_github() || isTRUE(as.logical(Sys.getenv("CI")))
}


# github (actions) --------------------------------------------------------

is_github <- function() {
  fs::file_exists("/github/workflow/event.json")
}

# shiny ------------------------------------------------------------------

is_shiny <- function() {
  !is.null(Sys.getenv("SHINY_PORT"))
}


# tests -------------------------------------------------------------------

is_test <- function() {
  !is.null(Sys.getenv("TEST"))
}

# CRAN --------------------------------------------------------------------

is_cran <- function() {
  !is.null(Sys.getenv("NOT_CRAN"))
}


