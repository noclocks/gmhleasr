
#  ------------------------------------------------------------------------
#
# Title : Run Shiny App
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------

.validate_app_path <- function(path) {

  # validate is character
  if (!is.character(path)) {
    cli::cli_abort("Invalid {.var path} argument. Provided path of {.arg {path}} is not a character string.")
  }

  # validate is directory
  if (!fs::is_dir(path)) {
    cli::cli_abort("Invalid {.var path} argument. Provided path of {.arg {path}} is not a directory.")
  }

  # validate path exists
  if (!fs::dir_exists(path)) {
    cli::cli_abort("Invalid {.var path} argument. Provided path of {.arg {path}} does not exist.")
  }

  # normalize path
  path <- normalizePath(path, mustWork = TRUE)

  # validate path contains shiny app


  if (!is.character(path)) {
    stop("path must be a character string")
  }

  if (!file.exists(path)) {
    stop("path does not exist")
  }

  if (!file.info(path)$isdir) {
    stop("path must be a directory")
  }

  return(invisible(TRUE))



}

run_app <- function(
  path = NULL,
  app = NULL,
  ui = NULL,
  server = NULL,
  port = NULL,
  host = NULL,
  launch.browser = TRUE,
  ...
) {

  # validate arguments: use path if provided, else use ui and server
  if (!is.null(path)) {



  shiny::shinyApp(ui = ui, server = server, options = options)
}
