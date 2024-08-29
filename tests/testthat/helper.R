#  ------------------------------------------------------------------------
#
# Title : Test Helpers
#    By : Jimmy Briggs
#  Date : 2024-08-28
#
#  ------------------------------------------------------------------------


# encryption --------------------------------------------------------------

decrypt_cfg_file <- function(
    cfg_file = here::here("inst/config/config.yml"),
    cfg_file_encrypted = here::here("inst/config/config.encrypted.yml"),
    key = "NOCLOCKS_ENCRYPTION_KEY") {
  if (!httr2::secret_has_key(key)) {
    cli::cli_alert_danger("Encryption key: {.field {key}} not found.")
    cli::cli_abort("Please set the encryption key in your environment variables.")
  }

  cfg_file_decrypted <- cfg_file |> fs::path()
  cfg_file_encrypted <- cfg_file_encrypted |> fs::path()

  cfg_file_decrypted_temp <- httr2::secret_decrypt_file(
    path = cfg_file_encrypted,
    key = key
  )

  fs::file_move(
    cfg_file_decrypted_temp,
    cfg_file_decrypted
  )

  cli::cli_alert_success("Successfully decrypted the config file: {.file cfg_file_decrypted}")
  cli::cli_alert_info("The decrypted file is now the active config file.")

  Sys.setenv("R_CONFIG_FILE" = cfg_file_decrypted)
  cli::cli_alert_info("Set `R_CONFIG_FILE` to: {.file {cfg_file_decrypted}}")

  return(invisible(config::get()))
}

# mocks -------------------------------------------------------------------

mock_req_body <- list(
  auth = list(
    type = "basic"
  ),
  requestId = 15,
  method = list(
    name = "getStatus",
    version = "r1",
    params = list()
  )
)

mock_res_success <- list(
  response = list(
    requestId = "15",
    code = 200,
    result = list(
      status = "Success",
      message = "API service is available and running."
    )
  )
)

mock_res_error <- list(
  response = list(
    requestId = "15",
    error = list(
      code = 113,
      message = "Username and/or password is incorrect."
    )
  )
)


# mock response -----------------------------------------------------------

# Helper function to create a mock response
create_mock_response <- function(status_code, body) {
  structure(
    list(
      status_code = status_code,
      headers = list(`Content-Type` = "application/json"),
      body = jsonlite::toJSON(body, auto_unbox = TRUE)
    ),
    class = "response"
  )
}

# package root ------------------------------------------------------------

test_package_root <- function() {
  hold <- tryCatch(
    rprojroot::find_package_root_file(),
    error = function(e) NULL
  )

  if (!is.null(hold)) {
    return(hold)
  }

  pkg <- testthat::testing_package()

  hold <- tryCatch(
    rprojroot::find_package_root_file(
      path = file.path("..", "..", pkg)
    ),
    error = function(e) NULL
  )

  if (!is.null(hold)) {
    return(hold)
  }

  rlang::abort("Could not find package root")
}
