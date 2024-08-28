# mod_header_elements ------------------------------------------------------

# Header Elements UI Module





# Header Elements UI Module

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

    if (config$special) {
      return(create_user_menu(ns))
    }

    htmltools::tags$li(
      shiny::actionLink(
        ns(element_id),
        config$label,
        shiny::icon(config$icon)
      ),
      class = "dropdown"
    )
  }

  elements <- purrr::map(names(element_configs), ~ create_element(.x, element_configs[[.x]]))
  if (include_elements$contact) {
    elements <- c(elements, list(create_element("contact", NULL)))
  }
  purrr::compact(elements)
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

create_contact_menu <- function(contacts) {
  contact_items <- purrr::map(contacts, function(contact) {
    contact_item(
      name = contact$name,
      role = contact$role,
      phone = contact$phone,
      email = contact$email
    )
  })

  do.call(contact_menu, contact_items)
}

#' Creates a dropdown menu specific for contacts
#'
#' @param ... contact items to put into dropdown
#'
#' @return menu
#' @export
#' @importFrom htmltools tags div
contact_menu <- function(...){
  items <- c(list(...))
  htmltools::tags$li(
    class = "dropdown",
    htmltools::tags$a(
      href = "#",
      class = "dropdown-toggle",
      `data-toggle` = "dropdown",
      htmltools::div(
        htmltools::tags$i(
          class = "fa fa-phone"
        ),
        "Contact",
        style = "display: inline"
      ),
      htmltools::tags$ul(
        class = "dropdown-menu",
        items)
    )
  )
}

#' Contact Item
#'
#' Creates an item to be placed in a contact dropdownmenu.
#'
#' @param name Name
#' @param role Role
#' @param phone Phone
#' @param email Email
#'
#' @return contact menu item
#' @export
#' @importFrom htmltools tagList tags a h4 h5
#' @importFrom shiny icon
contact_item <- function(name = "First Name, Last Name",
                         role = "Role",
                         phone = "###-###-####",
                         email = "first.last@oliverwyman.com"){
  htmltools::tagList(
    htmltools::tags$li(
      htmltools::a(
        href = "#",
        htmltools::h4(htmltools::tags$b(name)),
        htmltools::h5(htmltools::tags$i(role))
      )
    ),
    htmltools::tags$li(
      htmltools::a(
        shiny::icon("envelope"), href = paste0("mailto:", email),
        email
      )
    ),
    htmltools::tags$li(
      htmltools::a(shiny::icon("phone"), href = "#", phone)
    ),
    htmltools::tags$hr()
  )
}

# Header Elements Server Module

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
    input, output, session,
    parent_session = NULL,
    paths = list(
      help = fs::path_package("mypackage", "reports/help.Rmd"),
      about = fs::path_package("mypackage", "reports/about.Rmd")
    )
) {

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


# internal ----------------------------------------------------------------

app_header_title_ui <- function(
    img_src = "https://www.gmhcommunities.com/wp-content/uploads/2019/07/GMH-Logo-Color-1.png",
    img_alt = "GMH Communities",
    href = "https://www.gmhcommunities.com/",
    title = "GMH Leasing Dashboard"
) {

  htmltools::tags$div(
    class = "app-header-title",
    htmltools::tags$a(
      href = href,
      htmltools::tags$img(
        src = img_src,
        alt = img_alt,
        class = "app-header-title-img",
        width = 200
      )
    ),
    htmltools::tags$h1(
      title,
      class = "app-header-title-text"
    )
  )

}
