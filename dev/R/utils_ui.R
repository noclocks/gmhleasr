show_refresh_confirm <- function() {
  shinyWidgets::confirmSweetAlert(
    session = session,
    inputId = session$ns("confirmrefresh"),
    title = "Confirm Application Refresh?",
    text = "All progress will be lost.",
    type = "question",
    btn_labels = c("Cancel", "Confirm"),
    closeOnClickOutside = TRUE
  )
}

show_modal <- function(title, icon, path) {
  shiny::showModal(
    shiny::modalDialog(
      title = icon_text(icon, title),
      easyClose = TRUE, fade = TRUE, size = "l",
      shiny::includeMarkdown(path)
    )
  )
}

icon_text <- function(icon, text) {
  htmltools::div(shiny::icon(icon), text)
}

create_user_menu <- function(ns) {
  htmltools::tags$li(
    class = "dropdown",
    htmltools::tags$a(
      href = "#",
      class = "dropdown-toggle",
      `data-toggle` = "dropdown",
      htmltools::div(
        htmltools::tags$i(class = "fa fa-user"),
        "User",
        style = "display: inline"
      )
    ),
    htmltools::tags$ul(
      class = "dropdown-menu",
      htmltools::tags$li(
        htmltools::a(
          shiny::icon("sign-out-alt"),
          "Logout",
          href = "__logout__"
        )
      )
    )
  )
}
