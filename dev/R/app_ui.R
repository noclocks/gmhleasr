#  ------------------------------------------------------------------------
#
# Title : Shiny App User Interface
#    By : Jimmy Briggs
#  Date : 2024-08-13
#
#  ------------------------------------------------------------------------

app_ui <- function(req) {

  ui <- force(req)

  ui <- bs4Dash::bs4DashPage(
    header = app_header_ui("header"),
    sidebar = app_sidebar_ui("sidebar"),
    body = app_body_ui(),
    controlbar = app_controlbar_ui("controlbar"),
    footer = app_footer_ui("footer"),
    title = "GMH Leasing Dashboard",
    freshTheme = app_theme(),
    preloader = app_preloader(),
    options = app_options_ui(),
    fullscreen = TRUE,
    help = TRUE,
    dark = FALSE,
    scrollToTop = TRUE
  )

  return(ui)

}

app_header_ui <- function(id, ...) {

  ns <- shiny::NS(id)

  header <- mod_header_ui(
    id = ns("header"),
    title = "GMH Leasing Dashboard"
  )

  return(header)

}


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


#  ------------------------------------------------------------------------
#
# Title : App Header
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

header_title <- function(
    title = "",
    color = "primary",
    img_src = "www/images/logos/gmh-communities-logo.svg",
    img_alt = "GMH Communities",
    href = "https://www.gmhcommunities.com/",
    opacity = 1,
    ...
) {

  shiny::div(
    class = "header-title",
    shiny::tags$a(
      href = href,
      shiny::tags$img(
        src = img_src,
        alt = img_alt,
        style = paste0("opacity: ", opacity, ";")
      )
    ),
    shiny::tags$h1(
      title,
      class = paste0("text-", color)
    )
  )



}


# exported ----------------------------------------------------------------

mod_header_ui <- function(
    id,
    title = "GMH Leasing Dashboard",
    ...
) {

  ns <- shiny::NS(id)

  elements <- mod_header_elements_ui(
    id = ns("elements"),
    include_elements = list(
      help = TRUE,
      about = TRUE,
      refresh = TRUE,
      contact = TRUE,
      user = TRUE
    ),
    contacts = .app_contacts()
  )

  bs4Dash::bs4DashNavbar(
    title = shiny::div(
      class = "header-title",
      shiny::tags$a(
        href = "https://gmhcommunities.com",
        shiny::tags$img(
          src = "www/images/logos/gmh-logo.svg",
          alt = "GMH Communities",
          style = "width: 250px; height: auto;"
        )
      ),
      htmltools::tags$br(),
      htmltools::tags$hr(),
    ),
    skin = "light",
    border = TRUE,
    rightUi = elements[[4]],
    bs4Dash::bs4DashBrand(
      title = "Leasing Dashboard",
      image = "www/images/logos/gmh-communities-logo.svg",
    )
  )
}

mod_header_server <- function(id, ...) {

  shiny::moduleServer(
    id,
    function(input, output, session) {
      mod_header_elements_server(
        id = session$ns("elements")
      )
    }
  )

}

# ui <- bs4Dash::bs4DashPage(
#   title = "GMH Leasing Dashboard",
#   header = mod_header_ui("header"),
#   sidebar = mod_sidebar_ui(id = "sidebar"),
#   controlbar = dashboardControlbar(
#     skin = "light",
#     sliderInput(
#       inputId = "controller",
#       label = "Update the first tabset",
#       min = 1,
#       max = 6,
#       value = 2
#     )
#   ),
#   footer = bs4DashFooter(),
#   body = bs4Dash::bs4DashBody(
#     shiny::tags$head(
#       # favicon
#       htmltools::tags$link(
#         rel = "icon",
#         type = "image/x-icon",
#         href = "www/images/favicons/favicon.ico"
#       ),
#       # styles
#       shiny::tags$link(rel = "stylesheet", type = "text/css", href = "styles/css/custom.css")
#     )
#   ),
#   options = list(
#     sidebarExpandOnHover = TRUE
#   ),
#   fullscreen = TRUE,
#   help = TRUE,
#   dark = FALSE,
#   scrollToTop = TRUE#,
#   # freshTheme = app_ui_theme(),
#   # preloader = app_ui_preloader(),
#   # body = app_body(),
#   # controlbar = app_controlbar(),
#   # footer = app_footer()
# )
