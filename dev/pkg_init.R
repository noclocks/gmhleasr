#  ------------------------------------------------------------------------
#
# Title : Package Initialization Script
#    By : Jimmy Briggs
#  Date : 2024-08-13
#
#  ------------------------------------------------------------------------

# library -----------------------------------------------------------------
require(usethis)
require(noclocksr)

# initialize --------------------------------------------------------------
usethis::create_package("gmhleasr")
usethis::use_directory("dev", TRUE)
usethis::use_namespace()
usethis::use_roxygen_md()
usethis::use_readme_md()
usethis::use_proprietary_license("No Clocks, LLC")
usethis::use_git()
usethis::use_package_doc()
usethis::use_import_from("rlang", ".data")
usethis::use_import_from("rlang", ".env")
usethis::use_import_from("tibble", "tibble")
usethis::use_import_from("glue", "glue")
usethis::use_tibble()
attachment::att_amend_desc()
devtools::document()


# testing -----------------------------------------------------------------
usethis::use_testthat()
usethis::use_spell_check()
httptest2::use_httptest2()


# authors -----------------------------------------------------------------

usethis::use_author(
  "Jimmy",
  "Briggs",
  email = "jimmy.briggs@noclocks.dev",
  role = c("aut", "cre"),
  comment = c(ORCID = "0000-0002-7489-8787")
)

usethis::use_author(
  "Patrick",
  "Howard",
  email = "patrick.howard@noclocks.dev",
  role = c("aut", "rev")
)

usethis::use_author(
  "No Clocks, LLC",
  email = "team@noclocks.dev",
  role = c("cph", "fnd")
)

# setup config and encryption ---------------------------------------------
cfg <- yaml::read_yaml("_config.yml")
noclocksr::cfg_init(cfg = cfg)
noclocksr::cfg_hooks_init()
