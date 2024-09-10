#  ------------------------------------------------------------------------
#
# Title : Shiny App Server
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------

# server ------------------------------------------------------------------

#' App Server
#'
#' @description
#' This function contains the server-side logic for the application.
#'
#' @param input,output,session Internal parameters for {shiny}.
#'
#' @return NULL
#'
#' @export
#'
#' @importFrom shiny reactiveValues reactive req bindEvent renderText observe
#'
app_server <- function(input, output, session, logging = FALSE, ...) {

  session$sendCustomMessage(
    type = "redirect",
    message =
  )

  if (logging) {
    shinylogs::track_usage(
      storage_mode = shinylogs::store_json(path = "logs"),
      what = c("session", "input", "output", "error"),
      exclude_input_regex = NULL,
      exclude_input_id = NULL,
      on_unload = FALSE,
      app_name = "GMH Leasing Dashboard",
      exclude_users = NULL,
      get_user =
    )
  }

  # hide waiter
  waiter::waiter_hide()

  # log session start/end
  log_app_event("Shiny Session Started", level = "INFO")
  shiny::onStop(function() { log_app_event("Shiny Session Ended", level = "INFO") })

  # setup error handling
  shiny::onUnhandledError(function(err) {
    level <- if (inherits(err, "shiny.error.fatal")) "FATAL" else "ERROR"
    log_app_event(conditionMessage(err), level = level)
  })

  # setup cache
  session$cache <- cachem::cache_mem(max_size = 500e6)

  # setup user details
  shiny::observe({
    shiny::req(session$userData$user())
    app_globals$active_user <- session$userData$user()
    # app_globals$active_user_email <- session$userData$user()$email
    # app_globals$active_user_role <- session$userData$user()$role
  }) |>
    shiny::bindEvent(
      session$userData$user(),
      once = TRUE
    )

  # collect initial summary data
  global_data <- shiny::reactiveValues(
    pre_lease = list(
      summary = NULL,
      details = NULL
    ),
    properties = list(
      table = NULL,
      map = NULL,
      chart = NULL
    )
  )

  pre_lease_init <- shiny::reactive({
    entrata_pre_lease_report()
  }) |>
    shiny::bindCache(
      entrata_pre_lease_report(),
      cache = cachem::cache_disk("./cache/pre_lease")
    )

  shiny::observe({
    shiny::req(pre_lease_init())
    global_data$pre_lease$summary <- pre_lease_init()$summary
    global_data$pre_lease$details <- pre_lease_init()$details
  }) |>
    shiny::bindEvent(
      pre_lease_init()
    )

  # reports_queue_id <- shiny::reactiveVal(NULL)
  # pre_lease_summary_data <- shiny::reactiveValues(
  #   summary = NULL,
  #   details = NULL
  # )

  # app modules -------------------------------------------------------------
  app_header_server("header")
  app_sidebar_server("sidebar")
  app_footer_server("footer")
  app_controlbar_server("controlbar")

  # tab modules -------------------------------------------------------------
  mod_dashboard_server("dashboard", global_data = global_data)
  mod_properties_server("properties")



}


# logger ------------------------------------------------------------------

log_app_event <- function(
    event,
    level = "info",
    session = shiny::getDefaultReactiveDomain(),
    user = shiny::getDefaultReactiveDomain(),
    ...
) {

  event <- glue::glue(event)
  ts <- strftime(Sys.time(), "(%F %T)")
  cli::cli_alert_info("[{toupper(level)}]: {ts} {event}")

}


secure_server <- function(
  server,
  ...
) {

  server <- force(server)

  function(input, output, session) {


    session$userData$user <- function() NULL
    session$userData$p <- NULL

    if (is.null(session$userData$user())) {
      shiny::showNotification(
        title = "Unauthorized",
        message = "You must be logged in to access this page.",
        type = "error"
      )
      shiny::stopApp()
    }

    server(input, output, session)

  }

}

#
#
#   # instantiate global reactive values
#   # app_globals <- shiny::reactiveValues(
#   #   active_tab = "home",
#   #   active_user = NULL,
#   #   active_user_email = NULL,
#   #   active_user_role = NULL,
#   #   session_start = Sys.time(),
#   #   session_duration = NULL,
#   #   session_idle = FALSE,
#   #   device_type = NULL,
#   #   screen_width = NULL,
#   #   data_last_refreshed = NULL
#   # )
#
#
#
#   # home_tab_server("home")
#   # properties_tab_server("properties")
#   # leases_tab_server("leases")
#   # reports_tab_server("reports")
#   # settings_tab_server("settings")
#
#   shiny::observe({
#     shiny::req(app_globals)
#     # add to session$userData so can be accessed in other modules
#     session$userData$app_globals <- app_globals
#   })
#   #
#
#
#   # setup device type and screen width
#   # shiny::observe({
#   #   shiny::req(input$screen_width)
#   #   app_globals$screen_width <- input$screen_width
#   # }) |>
#   #   shiny::bindEvent(
#   #     input$screen_width,
#   #     once = TRUE
#   #   )
#
#   # setup session duration
#   shiny::observe({
#     shiny::invalidateLater(1000, session)
#     app_globals$session_duration <- Sys.time() - app_globals$session_start
#     app_globals$session_idle <- app_globals$session_duration > 3000
#   })
#
#   render user email for display in UI
#   output$active_user_email <- shiny::renderText({
#     shiny::req(app_globals$active_user_email())
#     app_globals$active_user_email()
#   }) |>
#     shiny::bindEvent(
#       app_globals$active_user_email
#     )
#
#   logout observer
#   shiny::observe({
#     shiny::req(input$logout)
#     noClocksAuthR::sign_out_from_shiny(session)
#     session$userData$user(NULL)
#     session$relaod()
#   }) |>
#     shiny::bindEvent(
#       input$logout
#     )
#
#
