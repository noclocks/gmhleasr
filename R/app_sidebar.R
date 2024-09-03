
#  ------------------------------------------------------------------------
#
# Title : App Sidebar Module
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------

#' App Sidebar Module
#'
#' @name app_sidebar
#'
#' @description
#' A module for creating the sidebar of the GMH Leasing Dashboard.
#'
#' @param id The module id
#'
#' @return
#' - `app_sidebar_ui()`: A bs4Dash sidebar UI element
#' - `app_sidebar_server()`: Server logic for the sidebar
#'
NULL

#' @rdname app_sidebar
#' @export
#' @importFrom bs4Dash bs4DashSidebar sidebarMenu menuItem
#' @importFrom shiny NS
app_sidebar_ui <- function(id) {
  ns <- shiny::NS(id)

  bs4Dash::bs4DashSidebar(
    id = ns("sidebar"),
    bs4Dash::sidebarMenu(
      bs4Dash::menuItem(
        text = "Dashboard",
        tabName = "dashboard",
        icon = shiny::icon("tachometer-alt")
      ),
      bs4Dash::menuItem(
        text = "Reports",
        tabName = "reports",
        icon = shiny::icon("file-alt")
      ),
      bs4Dash::menuItem(
        text = "Properties",
        tabName = "properties",
        icon = shiny::icon("building")
      )
    )
  )
}

#' @rdname app_sidebar
#' @export
app_sidebar_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    # Add any necessary server logic for the sidebar
  })
}



#  ------------------------------------------------------------------------
#
# Title : App Sidebar Module
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------

#' App Sidebar Module
#'
#' @name app_sidebar
#'
#' @description
#' A module for creating the sidebar of the GMH Leasing Dashboard.
#'
#' @param id The module id
#'
#' @return
#' - `app_sidebar_ui()`: A bs4Dash sidebar UI element
#' - `app_sidebar_server()`: Server logic for the sidebar
#'
NULL

#' @rdname app_sidebar
#' @export
#' @importFrom bs4Dash bs4DashSidebar sidebarMenu menuItem
#' @importFrom shiny NS
app_sidebar_ui <- function(id) {

  ns <- shiny::NS(id)

  bs4Dash::bs4DashSidebar(
    id = ns("sidebar"),
    htmltools::tags$div(
      class = "sidebar-header-text",
      htmltools::tags$p(
        align = "center",
        "GMH Leasing Dashboard"
      ),
      htmltools::tags$p(
        align = "center",
        "Powered by No Clocks, LLC"
      ),
      htmltools::tags$hr()
    ),
    bs4Dash::bs4SidebarMenu(
      id = ns("sidebar_menu"),
      bs4Dash::bs4SidebarMenuItem(
        text = "Dashboard",
        icon = shiny::icon("tachometer-alt"),
        tabName = "dashboard",
        selected = TRUE
      ),
      bs4Dash::bs4SidebarMenuItem(
        text = "Reports",
        icon = shiny::icon("file-alt"),
        tabName = "reports"
      ),
      bs4Dash::bs4SidebarMenuItem(
        text = "Properties",
        tabName = "properties",
        icon = shiny::icon("building")
      )
    ),
    fixed = TRUE,
    customArea = htmltools::tagList(
      htmltools::tags$a(
        href = "https://noclocks.dev",
        htmltools::tags$img(
          src = "www/images/noclocks/noclocks-logo-wordmark-black.svg",
          alt = "No Clocks, LLC",
          style = "width: 200px; height: auto; margin-bottom: 20px;"
        )
      )
    )
  )
}

#' @rdname app_sidebar
#' @export
app_sidebar_server <- function(id, app_globals = NULL) {

  shiny::moduleServer(id, function(input, output, session) {

    if (is.null(app_globals)) {
      parent_session <- .subset2(session, "parent")
      app_globals <- parent_session$userData$app_globals
    }

    # update active_tab in app_globals
    shiny::observe({
      shiny::req(input$sidebar_menu)
      log_app_event("User changed to tab: {input$sidebar_menu}.")
      app_globals$active_tab <- input$sidebar_menu
    }) |>
      shiny::bindEvent(input$sidebar_menu)

  })
}

