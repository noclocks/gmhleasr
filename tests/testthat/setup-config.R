
#  ------------------------------------------------------------------------
#
# Title : Configuration Setup for Testing
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

require(fs)
require(config)

# paths -------------------------------------------------------------------
cfg_file_pkg <- fs::path_package(package = "gmhleasr", "config/config.encrypted.yml")


# decrypt -----------------------------------------------------------------
cfg_decrypted <- decrypt_cfg_file(cfg_file_pkg)


# get entrata config ------------------------------------------------------
cfg <- config::get("entrata")


# test config -------------------------------------------------------------
cfg_test <- list(
  username = "testuser",
  password = "testpass",
  base_url = "https://api.entrata.com"
)


# cleanup for CI/CD -------------------------------------------------------

if (is_github()) {
  withr::defer(
    {
      file.remove(cfg_decrypted)
      Sys.unsetenv("R_CONFIG_FILE")
    },
    testthat::teardown_env()
  )
}
