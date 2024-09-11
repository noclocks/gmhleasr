#  ------------------------------------------------------------------------
#
# Title : Run Shiny App
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

#' Run Shiny App
#'
#' @description
#' Run the Shiny application with the specified options.
#'
#' @inheritParams shiny::shinyApp
#' @param ... Additional options
#'
#' @return A Shiny Application.
#'
#' @export
#'
#' @importFrom cachem cache_disk cache_mem
#' @importFrom shiny runApp shinyOptions
run_app <- function(
    onStart = NULL,
    options = list(),
    enableBookmarking = NULL,
    uiPattern = "/",
    ...) {
  shiny::shinyOptions(cache = cachem::cache_mem(max_size = 500e6))
  # shiny::shinyOptions(cache = cachem::cache_disk(file.path(dirname(tempdir()), "gmhleasr"))
  shiny::shinyOptions(cache = cachem::cache_disk("./app_cache"))

  run_with_opts(
    app = shiny::shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    opts = list(...)
  )
}

#' Is App Local?
#'
#' @description
#' Check if the Shiny App is running locally.
#'
#' @return A logical value.
#' @export
#' @keywords internal
is_app_local <- function() {
  Sys.getenv("SHINY_PORT") == ""
}

#' Run with Options
#'
#' @description
#' Run a Shiny App with extra, custom options.
#'
#' @param app Shiny App object.
#' @param opts A list of options to pass to the Shiny App.
#' @param maintenance_page A Shiny App object to display when the app is in maintenance mode.
#' @param print A logical value to print the app. Defaults to `TRUE`.
#'
#' @return A Shiny App object.
#' @export
#' @keywords internal
#'
#' @importFrom shiny shinyApp
run_with_opts <- function(
    app,
    opts,
    maintenance_page = maintenance_page,
    print = TRUE) {
  if (Sys.getenv("APP_MAINTANENCE_ACTIVE", "FALSE") == "TRUE") {
    app <- shiny::shinyApp(
      ui = maintenance_page,
      server = function(input, output, session) {}
    )
  }

  set_app_global("running", TRUE)
  on.exit(set_app_global("running", FALSE))
  app$appOptions$opts <- opts

  if (is_app_local()) {
    print <- FALSE
  }

  if (print) {
    print(app)
  }

  return(app)
}
