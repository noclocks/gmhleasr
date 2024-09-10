
#  ------------------------------------------------------------------------
#
# Title : Configuration Related Test Helpers
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

require(cli)
require(httr2)
require(fs)

decrypt_cfg_file <- function(cfg_path, key = "NOCLOCKS_ENCRYPTION_KEY") {
  if (!httr2::secret_has_key(key)) {
    cli::cli_alert_danger("Encryption key: {.field {key}} not found.")
    cli::cli_abort("Please set the encryption key in your environment variables.")
  }

  cfg_file_decrypted_temp <- httr2::secret_decrypt_file(
    path = cfg_path,
    key = key
  )

  fs::file_move(
    cfg_file_decrypted_temp,
    fs::path(dirname(cfg_path), "config.yml")
  )

  cfg_file_decrypted <- fs::path(dirname(cfg_path), "config.yml")

  cli::cli_alert_success("Successfully decrypted the config file: {.file cfg_file_decrypted}")
  cli::cli_alert_info("The decrypted file is now the active config file.")

  Sys.setenv("R_CONFIG_FILE" = cfg_file_decrypted)
  cli::cli_alert_info("Set `R_CONFIG_FILE` to: {.file {cfg_file_decrypted}}")

  return(invisible(cfg_file_decrypted))
}
