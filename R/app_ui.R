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

  force(request)

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

  if (request$PATH_INFO == "/") {
    return(ui)
  } else if (request$PATH_INFO == "/login") {
    return(mod_login_ui("login"))
  } else {
    return(mod_error_ui("error"))
  }

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
    waiter::use_waiter(),
    waiter::waiterShowOnLoad(html = waiter::spin_fading_circles())
  )
}

mod_login_ui <- function(id) {

  ns <- shiny::NS(id)

  noClocksAuthR::sign_in_ui_default(
    sign_in_module = noClocksAuthR::sign_in_module_2_ui('sign_in'),
    color = '#14beea',
    company_name = 'Leasing Dashboard',
    icon_href = file.path(pkgload::pkg_name(), "img/gmh-favicon.png"),
    logo_top = shiny::tags$h1(
      # Make style better for title of Log In page
      style = 'margin-bottom: 2.5%; font-weight: 500; font-size: 3.5em; color: #FFF;',
      "GMH Leasing Dashboard"
    ),
    logo_bottom = shiny::tags$img(
      src = file.path(pkgload::pkg_name(), "img/gmh-logo.svg"),
      alt = 'GMH Communities',
      style = 'width: 40%; margin-top: 2.5%;'
    )
  )

}

mod_error_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tags$div(
    id = ns("error_ui"),
    shiny::tags$h1(
      "404 - Page Not Found",
      style = "color: #FFF; font-size: 3em; font-weight: 500; margin-top: 5%;"
    ),
    shiny::tags$p(
      "The page you are looking for does not exist.",
      style = "color: #FFF; font-size: 1.5em; font-weight: 300; margin-top: 2%;"
    )
  )


}

# mod_login_ui <- function(id) {
#
#   ns <- shiny::NS(id)
#
#   password_ui <- htmltools::tags$div(
#     id = ns("password_ui"),
#     htmltools::tags$div(
#       class = "form-group",
#       style = "width: 100%;",
#       htmltools::tags$label(
#         htmltools::tagList(
#           shiny::icon("unlock-alt"),
#           "password"
#         ),
#         class = "control-label",
#         `for` = ns("sign_in_password")
#       ),
#       htmltools::tags$input(
#         id = ns("sign_in_password"),
#         type = "password",
#         class = "form-control",
#         value = ""
#       )
#     ),
#     shinyFeedback::loadingButton(
#       ns("sign_in_submit"),
#       label = "Sign In",
#       class = "btn btn-primary btn-lg text-center",
#       style = "width: 100%",
#       loadingLabel = "Authenticating...",
#       loadingClass = "btn btn-primary btn-lg text-center",
#       loadingStyle = "width: 100%"
#     )
#   )
#
#   continue_ui <- htmltools::tags$div(
#     id = ns("continue_sign_in"),
#     shiny::actionButton(
#       inputId = ns("submit_continue_sign_in"),
#       label = "Continue",
#       width = "100%",
#       class = "btn btn-primary btn-lg"
#     )
#   )
#
#   email_ui <- htmltools::tags$div(
#     id = ns("email_ui"),
#     htmltools::tags$br(),
#     email_input(
#       inputId = ns("sign_in_email"),
#       label = htmltools::tagList(shiny::icon("envelope"), "email"),
#       value = "",
#       width = "100%"
#     ),
#     htmltools::tags$div(
#       id = ns("sign_in_panel_bottom"),
#       if (isTRUE(auth$is_invite_required)) {
#         htmltools::tagList(
#           continue_ui,
#           shinyjs::hidden(
#             password_ui
#           )
#         )
#       } else {
#         password_ui
#       },
#       htmltools::tags$div(
#         style = "text-align: center;",
#         htmltools::tags$br(),
#         send_password_reset_email_module_ui(ns("reset_password"))
#       )
#     )
#   )
#
#
# }

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
    html = htmltools::tagList(waiter::spin_flowers(), "Loading..."), color = "#007bff"
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
        mod_properties_ui("properties")
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
