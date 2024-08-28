
#  ------------------------------------------------------------------------
#
# Title : Shiny App Logo
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

app_logo <- function() {
  logo_html <- htmltools::tags$span(
    class = "logo",
    htmltools::tags$img(
      src = "www/logo.png",
      alt = "Logo"
    )
  )
}
