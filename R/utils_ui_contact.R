# internal ----------------------------------------------------------------

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

# exported ----------------------------------------------------------------



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
          class = "fa fa-address-book"
        ),
        "Contact",
        style = "display: inline"
      ),
      htmltools::tags$ul(
        class = "dropdown-menu contact-dropdown",
        style = "width: 300px; padding: 10px;",
        items
      )
    )
  )
}

contact_item <- function(
    name,
    role = "Developer",
    company = NULL,
    phone = NULL,
    email = NULL,
    url = NULL,
    image = NULL
){
  image_html <- if (!is.null(image) && nzchar(image)) {
    # Check if the image file exists
    if (file.exists(image)) {
      # If it exists, use base64 encoding to embed the image
      img_type <- tools::file_ext(image)
      img_base64 <- base64enc::base64encode(image)
      src <- sprintf("data:image/%s;base64,%s", img_type, img_base64)
    } else {
      # If file doesn't exist, use a default icon
      src <- NULL
    }

    if (!is.null(src)) {
      htmltools::tags$img(
        src = src,
        alt = name,
        style = "width: 50px; height: 50px; border-radius: 50%; object-fit: cover; float: left; margin-right: 15px;"
      )
    } else {
      shiny::icon("user-circle", style = "font-size: 50px; float: left; margin-right: 15px; color: #007bff;")
    }
  } else {
    shiny::icon("user-circle", style = "font-size: 50px; float: left; margin-right: 15px; color: #007bff;")
  }

  contact_info <- htmltools::tagList(
    htmltools::h4(style = "margin: 0 0 5px 0; font-size: 18px; color: #333;", htmltools::tags$b(name)),
    htmltools::h5(style = "margin: 0 0 3px 0; font-size: 14px; color: #666;", htmltools::tags$i(role)),
    if (!is.null(company)) htmltools::h5(style = "margin: 0 0 5px 0; font-size: 14px; color: #888;", company)
  )

  contact_methods <- htmltools::tagList(
    if (!is.null(email)) htmltools::tags$a(shiny::icon("envelope"), email, href = paste0("mailto:", email), style = "display: block; font-size: 14px; margin-bottom: 5px; color: #007bff; text-decoration: none; transition: color 0.3s;"),
    if (!is.null(phone)) htmltools::tags$a(shiny::icon("phone"), display_phone_number(phone), href = paste0("tel:", strip_phone_number(phone)), style = "display: block; font-size: 14px; margin-bottom: 5px; color: #007bff; text-decoration: none; transition: color 0.3s;"),
    if (!is.null(url)) htmltools::tags$a(shiny::icon("external-link-alt"), "Profile", href = url, target = "_blank", style = "display: block; font-size: 14px; color: #007bff; text-decoration: none; transition: color 0.3s;")
  )

  htmltools::tags$li(
    style = "list-style-type: none; padding: 15px; border-bottom: 1px solid #eee; transition: background-color 0.3s;",
    htmltools::div(
      style = "overflow: hidden;",
      image_html,
      htmltools::div(
        style = "float: left; width: calc(100% - 65px);",
        contact_info,
        contact_methods
      )
    )
  )
}

#' Create Contact Menu
#'
#' @description
#' Creates a dropdown menu specific for contacts
#'
#' @param contacts list of contacts (name, role, company, phone, email, url, image)
#'
#' @return menu
#'
#' @export
#'
#' @importFrom purrr map
create_contact_menu <- function(contacts = .app_contacts()) {
  items <- purrr::map(
    contacts,
    ~ contact_item(
      name = .x$name,
      role = .x$role,
      company = .x$company,
      phone = .x$phone,
      email = .x$email,
      url = .x$url,
      image = .x$image
    )
  )

  contact_menu(items)
}



# shiny::shinyApp(ui = shinydashboard::dashboardPage(header = shinydashboard::dashboardHeader(.list = list(contact = contact_menu(.app_contacts()))), sidebar = shinydashboard::dashboardSidebar(), body = shinydashboard::dashboardBody()), server = function(input, output) {})
