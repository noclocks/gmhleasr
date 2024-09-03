#' App Controlbar Module
#'
#' @name app_controlbar
#'
#' @description
#' A module for creating the controlbar of the GMH Leasing Dashboard.
#'
#' @param id The module id
#'
#' @return
#' - `app_controlbar_ui()`: A bs4Dash controlbar UI element
#' - `app_controlbar_server()`: Server logic for the controlbar
#'
NULL

#' @rdname app_controlbar
#' @export
#' @importFrom bs4Dash bs4DashControlbar controlbarMenu controlbarItem
#' @importFrom shiny NS sliderInput
app_controlbar_ui <- function(id) {
  ns <- shiny::NS(id)

  bs4Dash::bs4DashControlbar(
    id = ns("controlbar"),
    bs4Dash::controlbarMenu(
      id = ns("controlbar_menu"),
      bs4Dash::controlbarItem(
        "Settings",
        shiny::sliderInput(
          ns("slider"),
          "Number of observations:",
          min = 0,
          max = 1000,
          value = 500
        )
      )
    )
  )
}

#' @rdname app_controlbar
#' @export
app_controlbar_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    # Add any necessary server logic for the controlbar
  })
}
