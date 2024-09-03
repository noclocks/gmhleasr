
#  ------------------------------------------------------------------------
#
# Title : Shiny App Footer Module
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------


#' App Footer Module
#'
#' @name app_footer
#'
#' @description
#' A module for creating the footer of the GMH Leasing Dashboard.
#'
#' @param id The module id
#'
#' @return
#' - `app_footer_ui()`: A bs4Dash footer UI element
#' - `app_footer_server()`: Server logic for the footer
#'
NULL

#' @rdname app_footer
#' @export
#' @importFrom bs4Dash bs4DashFooter
#' @importFrom shiny NS
app_footer_ui <- function(id) {

  ns <- shiny::NS(id)

  bs4Dash::bs4DashFooter(
    fixed = TRUE,
    left = htmltools::tags$p(
      'Build for use by ',
      htmltools::tags$a(
        'GMH Communities',
        href = 'https://gmhcommunities.com',
        target = '_blank'
      )
    ),
    right = htmltools::tags$p(
      'Developed by ',
      htmltools::tags$a(
        'No Clocks, LLC',
        href = 'https://noclocks.dev',
        target = '_blank'
      ),
      ' | ', htmltools::HTML("&copy;"), ' Copyright ',
      format(Sys.Date(), '%Y')
    )
  )

}

#' @rdname app_footer
#' @export
app_footer_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    # Add any necessary server logic for the footer
  })
}
