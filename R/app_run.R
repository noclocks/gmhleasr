#  ------------------------------------------------------------------------
#
# Title : Run Shiny App
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom rappdirs app_dir
#' @importFrom fs path_norm
.default_cache_dir <- function() {
  rappdirs::app_dir("gmhleasr")$cache() |>
    fs::path_norm()
}

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
#' @importFrom shiny runApp shinyOptions
run_app <- function(
  cache = TRUE,
  cache_mode = c("memory", "disk"),
  cache_dir = .default_cache_dir(),
  reactlog = FALSE,
  showcase = FALSE,
  hot_reload = FALSE,
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = ".*", #"/",
  ...
) {

  if (hot_reload) {
    options("shiny.autoreload.pattern" = utils::glob2rx("*.R"))
  }

  if (reactlog) {
    shiny::shinyOptions(reactlog = TRUE)
    cli::cli_alert_info(c(
      "Running App with Reactlog Enabled",
      "To view the Reactlog, press `Ctrl + F3` or `Cmd + F3` in the browser."
    ))
  }

  if (cache) {
    cache_mode <- rlang::arg_match(cache_mode, multiple = FALSE)
    if (cache_mode == "memory") {
      shiny::shinyOptions(cache = cachem::cache_mem(max_size = 500e6))
      cli::cli_alert_success("Setup Shiny Cache (in memory) with 500MB Limit")
    } else {
      shiny::shinyOptions(
        cache = cachem::cache_disk(
          dir = cache_dir,
          max_size = 500e6,
          write_fn = qs::qsave,
          read_fn = qs::qread,
          extension = ".qs",
          logfile = fs::path(cache_dir, "cache.log"),
          destroy_on_finalize = TRUE
        )
      )
      cli::cli_alert_success("Setup Shiny Cache (on disk) with 500MB Limit")
    }
  } else {
    shiny::shinyOptions(cache = NULL)
    cli::cli_alert_info("Running App with Cache Disabled")
  }

  run_with_opts(
    app = shiny::shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    showcase = showcase,
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
    showcase = FALSE,
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

  if (showcase) {
    shiny::runApp(app, display.mode = "showcase")
  } else {
    shiny::runApp(app)
  }

  return(app)
}
