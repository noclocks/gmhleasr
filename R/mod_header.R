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
    ...) {
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
    ...) {
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
