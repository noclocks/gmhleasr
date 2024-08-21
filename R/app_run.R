
#  ------------------------------------------------------------------------
#
# Title : Run Shiny App
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

run_app <- function(
  ui = app_ui,
  server = app_server,
  options = list(
    port = 5000,
    host = "0.0.0.0",
    launch.browser = TRUE
  ),
  ...
) {
  shiny::shinyApp(ui = ui, server = server, options = options)
}
