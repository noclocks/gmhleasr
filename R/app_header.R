

#  ------------------------------------------------------------------------
#
# Title : App Header Module
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------

# internal ----------------------------------------------------------------


# module ------------------------------------------------------------------

#' App Header Module
#'
#' @name app_header
#'
#' @description
#' A module for creating a custom header for the GMH Leasing Dashboard.
#'
#' @details
#' The module includes both the UI and server functions for the header:
#' - `app_header_ui()`: The UI function for the header
#' - `app_header_server()`: The server function for the header
#'
#' The header will include the following elements:
#' - GMH Communities logo
#' - Dashboard title
#' - About button
#' - Refresh button
#' - Contact Us dropdown menu
#' - User Menu dropdown menu
#'
#' @param id The module id
#' @param title The title of the dashboard
#'
#' @return
#' - `app_header_ui()`: An [htmltools::tagList()] of the header UI elements
#' - `app_header_server()`: List of reactive expressions for the header
NULL


# ui ----------------------------------------------------------------------

#' @rdname app_header
#' @export
#' @importFrom bs4Dash bs4DashNavbar
#' @importFrom htmltools tagList tags
#' @importFrom shiny NS actionButton icon textOutput tags actionLink
#' @importFrom shinydashboard dropdownMenu
app_header_ui <- function(id, title = "GMH Leasing Dashboard", ...) {

  ns <- shiny::NS(id)

    bs4Dash::bs4DashNavbar(
      title = htmltools::tagList(
        htmltools::tags$a(
          href = "https://gmhcommunities.com",
          htmltools::tags$img(
            src = "www/images/logos/gmh-communities-logo.svg",
            alt = "GMH Communities",
            style = "width: 200px; height: auto;"
          )
        )
      ),
      skin = "light",
      status = "white",
      border = TRUE,
      leftUi = htmltools::tagList(
        htmltools::tags$li(
          class = "dropdown",
          shiny::actionButton(ns(
            "refresh"
          ), "Refresh", icon = shiny::icon("refresh"))
        ),
        htmltools::tags$li(
          class = "dropdown",
          shiny::actionButton(
            ns("about"),
            "About",
            icon = shiny::icon("info-circle"))
        ),
        htmltools::tags$li(
          class = "dropdown",
          shiny::actionButton(
            ns("techstack"),
            "Tech Stack",
            icon = shiny::icon("code")
          )
        )
      ),
      rightUi = shinydashboard::dropdownMenu(
        type = "messages",
        badgeStatus = NULL,
        icon = shiny::icon('user'),
        headerText = shiny::textOutput("signed_in_as"),
        shiny::tags$li(
          shiny::actionLink(
            ns("noclocksauthr__sign_out"),
            style = 'display: inline-flex; align-items: center; padding: 2.5px 50px; width: -webkit-fill-available;',
            label = "Sign Out",
            icon = shiny::icon("sign-out-alt")
          )
        )
      )
    )
}


# server ------------------------------------------------------------------

#' @rdname app_header
#' @export
#' @importFrom htmltools includeMarkdown
#' @importFrom shiny moduleServer bindEvent observe showModal modalDialog
#' @importFrom shinyWidgets confirmSweetAlert
app_header_server <- function(id, app_globals = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # content -----------------------------------------------------------------
    .render_content()

    # about -------------------------------------------------------------------
    shiny::observe({
      shiny::showModal(
        shiny::modalDialog(
          title = icon_text("file", "About GMH Leasing Dashboard"),
          easyClose = TRUE,
          fade = TRUE,
          size = "l",
          htmltools::includeMarkdown(app_sys("content/about.md"))
        )
      )
    }) |> shiny::bindEvent(input$about)

    # techstack ---------------------------------------------------------------
    shiny::observe({
      shiny::showModal(
        shiny::modalDialog(
          title = icon_text("file", "Tech Stack"),
          easyClose = TRUE,
          fade = TRUE,
          size = "l",
          htmltools::includeMarkdown(app_sys("content/techstack.md"))
        )
      )
    }) |> shiny::bindEvent(input$techstack)



    # refresh -----------------------------------------------------------------
    shiny::observe({
      shinyWidgets::confirmSweetAlert(
        session = session,
        inputId = session$ns("confirm_refresh"),
        title = "Confirm Application Refresh?",
        text = "All unsaved changes will be lost.",
        type = "question",
        btn_labels = c("Cancel", "Refresh"),
        closeOnClickOutside = TRUE
      )
    }) |>
      shiny::bindEvent(input$refresh)

    shiny::observe({
      if (isTRUE(input$confirm_refresh)) {
        session$reload()
      }
    }) |>
      shiny::bindEvent(input$confirm_refresh)
  })
}


# internal ----------------------------------------------------------------

.render_content <- function(content_dir = app_sys("content")) {
  rmd_files <- fs::dir_ls(content_dir, glob = "*.Rmd")

  purrr::walk(rmd_files, function(rmd) {
    md <- fs::path_ext_set(rmd, "md") |> as.character()
    if (!file.exists(md) || file.mtime(md) < file.mtime(rmd)) {
      cli::cli_alert_info(c("Rendering {.field {rmd}} to {.field {md}}"))
      knitr::knit(input = rmd, output = md)
      cli::cli_alert_success(c("Successfully rendered {.field {rmd}} to {.field {md}}"))
    }
  })

}

# .header_dropdown <- function(id, text, icon) {
#
#   htmltools::tags$li(
#     shiny::actionLink(
#       id,
#       text,
#       icon = shiny::icon(icon)
#     ),
#     class = "dropdown"
#   )
#
# }
#
#
#
# app_header_elements_ui <- function(
    #   id,
#   contacts = NULL,
#   ...
# ) {
#
#   ns <- shiny::NS(id)
#
#   # title <- bs4Dash::bs4DashBrand(
#   #   title = "GMH Leasing Dashboard",
#   #   image = "public/images/logos/gmh-communities-logo.svg",
#   #   href = "https://gmhcommunities.com"
#   # )
#
#   refresh <- .header_dropdown(
#     ns("refresh"),
#     "Refresh",
#     "refresh"
#   )
#
#   about <- .header_dropdown(
#     ns("about"),
#     "About",
#     "info-circle"
#   )
#
#   help <- .header_dropdown(
#     ns("help"),
#     "Help",
#     "question-circle"
#   )
#
#   techstack <- .header_dropdown(
#     ns("techstack"),
#     "Tech Stack",
#     "code"
#   )
#
#   contact <- .header_dropdown(
#     ns("contact"),
#     "Contact Us",
#     "envelope"
#   )
#
#   user <- .header_dropdown(
#     ns("user"),
#     "User",
#     "user"
#   )
#
#   list(
#     refresh,
#     about,
#     help,
#     techstack,
#     contact,
#     user
#   )
#
# }
#
#
#
# app_header_elements_server <- function(id, app_globals = NULL) {
#
#   shiny::moduleServer(id, function(input, output, session) {
#
#     # content -----------------------------------------------------------------
#     .render_content()
#
#     # about -------------------------------------------------------------------
#     shiny::observe({
#       shiny::showModal(
#         shiny::modalDialog(
#           title = icon_text("file", "About GMH Leasing Dashboard"),
#           easyClose = TRUE,
#           fade = TRUE,
#           size = "l",
#           htmltools::includeMarkdown(
#             app_sys("content/about.md")
#           )
#         )
#       )
#     }) |> shiny::bindEvent(input$about)
#
#     # techstack ---------------------------------------------------------------
#     shiny::observe({
#       shiny::showModal(
#         shiny::modalDialog(
#           title = icon_text("file", "Tech Stack"),
#           easyClose = TRUE,
#           fade = TRUE,
#           size = "l",
#           htmltools::includeMarkdown(
#             app_sys("content/techstack.md")
#           )
#         )
#       )
#     }) |> shiny::bindEvent(input$techstack)
#
#
#
#     # refresh -----------------------------------------------------------------
#     shiny::observe({
#       shinyWidgets::confirmSweetAlert(
#         session = session,
#         inputId = session$ns("confirm_refresh"),
#         title = "Confirm Application Refresh?",
#         text = "All unsaved changes will be lost.",
#         type = "question",
#         btn_labels = c("Cancel", "Refresh"),
#         closeOnClickOutside = TRUE
#       )
#     }) |>
#       shiny::bindEvent(input$refresh)
#
#     shiny::observe({
#       if (isTRUE(input$confirm_refresh)) {
#         session$reload()
#       }
#     }) |>
#       shiny::bindEvent(input$confirm_refresh)
#
#   })
#
# }
