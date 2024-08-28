app_server <- function(input, output, session) {

  app_globals <- shiny::reactiveValues()

  shiny::observe({
    app_globals$screen_width <- input$screen_width
    app_globals$header <- shiny::ns("header")
  })



  mod_header_server("header")
  mod_sidebar_server(id = "sidebar")
}
