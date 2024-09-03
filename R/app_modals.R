#  ------------------------------------------------------------------------
#
# Title : Shiny App Modals
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------

contact_button <- function() {
  htmltools::tagList(
    htmltools::tags$head(
      shiny::bootstrapLib()
    ),
    htmltools::tags$a(
      href = paste0(
        "mailto:support@noclocks.dev?cc=jimmy.briggs@noclocks.dev,patrick.howard@noclocks.dev&",
        "subject=Support%20Request%20for%20GMH%20Leasing%20Dashboard&body=Please",
        "%20Describe%20the%20Request%20Here"
      ),
      class = "btn btn-default btn-primary",
      htmltools::tags$i(
        class = "far fa-envelope",
        role = "presentation",
        `aria-label` = "Contact Support"
      ),
      "Contact Support"
    )
  )
}

# error -------------------------------------------------------------------

error_modal <- function(message) {
  shiny::modalDialog(
    title = icon_text(shiny::icon("exclamation-circle"), "Error"),
    footer = htmltools::tagList(
      contact_button(),
      shiny::modalButton("Dismiss")
    ),
    easyClose = TRUE,
    htmltools::tags$div(
      class = "error-message",
      htmltools::tags$p(message)
    )
  )
}


# warning -----------------------------------------------------------------


warning_modal <- function(message) {
  shiny::modalDialog(
    title = icon_text(shiny::icon("exclamation-triangle"), "Warning"),
    footer = htmltools::tagList(
      contact_button(),
      shiny::modalButton("Dismiss")
    ),
    easyClose = TRUE,
    htmltools::tags$div(
      class = "warning-message",
      htmltools::tags$p(message)
    )
  )
}

# info --------------------------------------------------------------------
