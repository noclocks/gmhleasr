app_server <- function(input, output, session) {

  mod_header_server("header")
  mod_sidebar_server(id = "sidebar")
}
