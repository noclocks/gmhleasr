#' Dashboard Sidebar Module
#'
#' @name mod_sidebar
#'
#' @description
#' - `mod_sidebar_ui()` creates the UI for the dashboard sidebar.
#' - `mod_sidebar_server()` creates the server logic for the dashboard sidebar.
#'
#' @param id The namespace ID for the module.
#'
#' @return
#' - `mod_sidebar_ui()` returns the UI for the dashboard sidebar.
#' - `mod_sidebar_server()` returns the server logic for the dashboard sidebar.
NULL


#' @rdname mod_sidebar
#' @importFrom bs4Dash bs4DashSidebar menuItemOutput
#' @importFrom shiny NS
#' @importFrom htmltools tags
mod_sidebar_ui <- function(id) {
  ns <- shiny::NS(id)

  bs4Dash::bs4DashSidebar(
    id = ns("sidebar"),
    width = "250px",
    skin = "light",
    status = "primary",
    elevation = 3,
    customArea = htmltools::tags$div(
      style = "padding: 15px; text-align: center; position: absolute; bottom: 0; width: 100%;",
      htmltools::tags$a(
        href = "https://www.gmhcommunities.com/",
        htmltools::tags$img(
          style = "width: 90%; height: auto; margin: 0 auto;",
          src = "www/images/logos/gmh-logo.svg",
          alt = "GMH Communities"
        )
      )
    ),
    bs4Dash::menuItemOutput(outputId = ns("sidebar_menu"))
  )
}

#' @rdname mod_sidebar
#' @importFrom shiny moduleServer icon
#' @importFrom bs4Dash renderMenu sidebarMenu menuItem
mod_sidebar_server <- function(id) {
  shiny::moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns

      output$sidebar_menu <- bs4Dash::renderMenu({
        bs4Dash::sidebarMenu(
          id = ns("sidebar_menu"),
          bs4Dash::menuItem(
            text = "Dashboard",
            tabName = "dashboard",
            icon = shiny::icon("chart-line")
          ),
          bs4Dash::menuItem(
            text = "Reports",
            tabName = "reports",
            icon = shiny::icon("file-alt")
          ),
          bs4Dash::menuItem(
            text = "Leasing",
            tabName = "leasing",
            icon = shiny::icon("file-contract")
          ),
          bs4Dash::menuItem(
            text = "Properties",
            tabName = "Properties",
            icon = shiny::icon("building")
          )
        )
      })
    }
  )
}
