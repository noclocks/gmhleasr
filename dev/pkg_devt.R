
#  ------------------------------------------------------------------------
#
# Title : Package Development Script
#    By : Jimmy Briggs
#  Date : 2024-08-13
#
#  ------------------------------------------------------------------------

usethis::use_github_action(
  name = "document",
  save_as = "roxygen.yml",
  badge = TRUE
)

usethis::use_github_action(
  name = "lint",
  save_as = "lint.yml",
  badge = TRUE
)

usethis::use_github_action(
  name = "pr-commands",
  save_as = "pull-requests.yml",
  badge = TRUE
)

usethis::use_github_action(
  name = "style",
  save_as = "style.yml",
  badge = TRUE
)

usethis::use_github_action(
  name = "test-coverage",
  save_as = "coverage.yml",
  badge = TRUE
)

usethis::use_github_action(
  name = "check-standard",
  save_as = "check.yml",
  badge = TRUE
)

usethis::use_coverage()

usethis::use_github_links()

usethis::use_pkgdown_github_pages()

usethis::use_vignette("gmhleasr")

c(
  "entrata_api_request"
) |>
  purrr::walk(usethis::use_test, open = FALSE)
