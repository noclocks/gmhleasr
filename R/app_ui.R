#  ------------------------------------------------------------------------
#
# Title : Shiny App User Interface
#    By : Jimmy Briggs
#  Date : 2024-08-13
#
#  ------------------------------------------------------------------------

app_ui <- function(req) {

  ui <- force(req)

  bs4Dash::bs4DashPage(
    title = "GMH Leasing Dashboard",
    header = mod_header_ui("header"),
    sidebar = mod_sidebar_ui(id = "sidebar"),
    controlbar = dashboardControlbar(
      skin = "light",
      sliderInput(
        inputId = "controller",
        label = "Update the first tabset",
        min = 1,
        max = 6,
        value = 2
      )
    ),
    footer = bs4DashFooter(),
    body = bs4Dash::bs4DashBody(
      shiny::tags$head(
        # favicon
        htmltools::tags$link(
          rel = "icon",
          type = "image/x-icon",
          href = "www/images/favicons/favicon.ico"
        ),
        # styles
        shiny::tags$link(rel = "stylesheet", type = "text/css", href = "styles/css/custom.css")
      )
    ),
    options = list(
      sidebarExpandOnHover = TRUE
    ),
    fullscreen = TRUE,
    help = TRUE,
    dark = FALSE,
    scrollToTop = TRUE#,
    # freshTheme = app_ui_theme(),
    # preloader = app_ui_preloader(),
    # body = app_body(),
    # controlbar = app_controlbar(),
    # footer = app_footer()
  )
}
