
#  ------------------------------------------------------------------------
#
# Title : App User Interface
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------

#' App User Interface
#'
#' @description
#' The user interface for the GMH Leasing Dashboard.
#'
#' @param request Internal parameter for `{shiny}`.
#'
#' @return A `{shiny}` UI object.
#'
#' @export
#'
#' @importFrom bs4Dash bs4DashPage
#' @importFrom htmltools tagList tags
app_ui <- function(request) {

  ui <- force(request)

  ui <- htmltools::tagList(
    add_external_resources(),
    bs4Dash::bs4DashPage(
      title = "GMH Leasing Dashboard",
      # freshTheme = app_theme(),
      preloader = app_preloader(),
      options = app_options_ui(),
      fullscreen = TRUE,
      help = TRUE,
      dark = FALSE,
      scrollToTop = TRUE,
      header = app_header_ui("header"),
      sidebar = app_sidebar_ui("sidebar"),
      body = app_body_ui(),
      controlbar = app_controlbar_ui("controlbar"),
      footer = app_footer_ui("footer")
    )
  )

  ui

}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @importFrom htmltools tags
#' @importFrom golem activate_js favicon bundle_resources
#' @importFrom shinyjs useShinyjs
#'
#' @noRd
add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys()
  )

  htmltools::tags$head(
    app_favicon(),
    golem::bundle_resources(
      path = app_sys(),
      app_title = "gmhleasr"
    ),
    shinyjs::useShinyjs(),
    waiter::use_waiter()
  )
}

#' Add Resource Path
#'
#' This function is internally used to add a resource path
#' to the Shiny application.
#'
#' @param prefix The prefix to use for the resource path.
#' @param directoryPath The directory path to add as a resource path.
#' @param warn_empty Logical, should a warning be issued if the directory is empty?
#'
#' @importFrom shiny addResourcePath
#'
#' @noRd
add_resource_path <- function(prefix, directoryPath, warn_empty = FALSE) {
  list_f <- length(list.files(path = directoryPath)) == 0
  if (list_f) {
    if (warn_empty) {
      warning("No resources to add from resource path (directory empty).")
    }
  } else {
    shiny::addResourcePath(prefix, directoryPath)
  }
}

# clear_app_resources <- function() {
#   paths <- shiny::resourcePaths()
#   purrr::walk(names(paths), shiny::removeResourcePath)
# }
#
# add_app_resources <- function() {
#
#   shiny::addResourcePath(
#     "www",
#     fs::path_package("gmhleasr", "app/www")
#   )
#
#   htmltools::tags$head(
#     app_meta(),
#     shinyjs::useShinyjs(),
#     shinyFeedback::useShinyFeedback(feedback = FALSE),
#     waiter::useWaiter()
#   )
#
# }

app_theme <- function() {
  fresh::create_theme(
    fresh::bs4dash_vars(
      navbar_light_color = "#bec5cb",
      navbar_light_active_color = "#FFF",
      navbar_light_hover_color = "#FFF"
    ),
    fresh::bs4dash_yiq(
      contrasted_threshold = 10,
      text_dark = "#FFF",
      text_light = "#272c30"
    ),
    fresh::bs4dash_layout(
      main_bg = "#353c42"
    ),
    fresh::bs4dash_sidebar_light(
      bg = "#272c30",
      color = "#bec5cb",
      hover_color = "#FFF",
      submenu_bg = "#272c30",
      submenu_color = "#FFF",
      submenu_hover_color = "#FFF"
    ),
    fresh::bs4dash_status(
      primary = "#5E81AC",
      danger = "#BF616A",
      light = "#272c30"
    ),
    fresh::bs4dash_color(
      gray_900 = "#FFF",
      white = "#272c30"
    )
  )
}

app_preloader <- function() {
  list(
    html = waiter::spin_3k(), color = "#007bff"
  )
}

app_options_ui <- function() {
  list(NULL)
}

app_body_ui <- function() {
  bs4Dash::bs4DashBody(
    bs4Dash::tabItems(
      bs4Dash::tabItem(
        tabName = "dashboard",
        mod_dashboard_ui("dashboard")
      ),
      bs4Dash::tabItem(
        tabName = "reports",
        bs4Dash::box(
          status = "primary"
        )
      ),
      bs4Dash::tabItem(
        tabName = "properties",
        bs4Dash::box(
          status = "orange"
        )
      )
    )
  )
}



.app_contacts <- function() {
  list(
    "jimmy" = contact_item(
      name = "Jimmy Briggs",
      role = "Developer",
      company = "No Clocks, LLC",
      phone = "6784914856",
      email = "jimmy.briggs@noclocks.dev",
      url = "https://github.com/jimbrig",
      image = "inst/assets/images/noclocks/team/jimmy-headshot.png"
    ),
    "patrick" = contact_item(
      name = "Patrick Howard",
      role = "Developer",
      company = "NoClocks",
      phone = "4044082500",
      email = "patrick.howard@noclocks.dev",
      url = "https://github.com/phoward38",
      image = "inst/assets/images/noclocks/team/patrick-headshot.png"
    )
  )
}

