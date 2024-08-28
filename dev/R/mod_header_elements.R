#  ------------------------------------------------------------------------
#
# Title : header_elements Shiny Module
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

#' Header Elements UI
#'
#' @description
#' UI module for header elements.
#'
#' @param id namespace ID
#' @param include_elements named list of logicals for element inclusion
#' @param contacts list of contact information
#'
#' @return \code{htmltools::tagList()}
#' @export
#' @importFrom shiny NS actionLink icon
#' @importFrom htmltools tags div a
#' @importFrom purrr compact map
mod_header_elements_ui <- function(id,
                                   include_elements = list(
                                     help = TRUE,
                                     about = TRUE,
                                     refresh = TRUE,
                                     contact = TRUE,
                                     user = TRUE
                                   ),
                                   contacts = NULL) {
  ns <- shiny::NS(id)

  element_configs <- list(
    help = list(label = "Help", icon = "question-circle"),
    about = list(label = "About", icon = "info-circle"),
    refresh = list(label = "Refresh", icon = "sync"),
    user = list(label = "User", icon = "user", special = TRUE)
  )

  create_element <- function(element_id, config) {

    if (!include_elements[[element_id]]) return(NULL)

    if (element_id == "contact") {
      return(if (include_elements$contact) create_contact_menu(contacts) else NULL)
    }

    if (!is.null(config$special)) {
      return(create_user_menu(ns))
    }

    htmltools::tags$li(
      class = "nav-item",
      shiny::actionLink(
        ns(element_id),
        label = NULL,
        icon = shiny::icon(config$icon),
        class = "nav-link"
      )
    )
  }

  elements <- purrr::map(names(element_configs), ~ create_element(.x, element_configs[[.x]]))
  if (include_elements$contact) {
    elements <- c(elements, list(create_element("contact", NULL)))
  }

  purrr::compact(elements)
}

#' Header Elements Server
#'
#' @description
#' Server module for header elements.
#'
#' @param input shiny input
#' @param output shiny output
#' @param session shiny session
#' @param parent_session shiny session of the parent environment
#' @param paths named list of file paths
#'
#' @return server
#' @export
#' @importFrom htmltools div
#' @importFrom shiny observeEvent showModal modalDialog includeMarkdown icon
#' @importFrom shinyWidgets confirmSweetAlert
mod_header_elements_server <- function(
  id,
  parent_session = NULL,
  paths = list(
    help = fs::path_package("gmhrleasr", "assets/content/help.Rmd"),
    about = fs::path_package("gmhrleasr", "assets/content/about.Rmd")
  )
) {
  shiny::moduleServer(
    id,
    function(input, output, session) {

      observe_element <- function(element_id, action) {
        shiny::observeEvent(input[[element_id]], action())
      }

      observe_element("help", ~ show_modal("Help", "question-circle", paths$help))
      observe_element("about", ~ show_modal("About", "info-circle", paths$about))
      observe_element("refresh", show_refresh_confirm)

      shiny::observeEvent(input$confirmrefresh, {
        if (isTRUE(input$confirmrefresh)) session$reload()
      })

    }
  )
}
