library(shiny)
library(bslib)

ui <- bslib::page_sidebar(
  title = "Leasing Dashboard",
  fillable = TRUE,
  fillable_mobile = FALSE,
  theme = bslib::bs_theme(version = 5),
  window_title = "GMH Leasing Dashboard",
  lang = "en",
  sidebar = bslib::sidebar(
    title = "GMH Leasing Dashboard",
    shiny::sliderInput(
      "obs",
      "Number of observations:",
      min = 0,
      max = 1000,
      value = 500
    )
  ),
  "Content",
  htmltools::h3("URL Components"),
  shiny::verbatimTextOutput("url_text"),
  htmltools::h3("Parsed Query String"),
  shiny::verbatimTextOutput("query_text"),
  htmltools::h3("Client Data"),
  shiny::tableOutput("client_data_tbl"),
  shiny::mainPanel(
    htmltools::h3("Plot"),
    shiny::plotOutput("myplot"),
    htmltools::tagAppendAttributes(
      shiny::textOutput("info"),
      class = "shiny-report-theme"
    )
  )
)

server <- function(input, output, session) {
  bslib::bs_themer()

  client_data <- reactive({
    session$clientData |>
      shiny::reactiveValuesToList() |>
      unlist() |>
      tibble::enframe()
  })

  output$client_data_tbl <- shiny::renderTable({
    client_data()
  })

  output$url_text <- shiny::renderText({
    protocol <- session$clientData$url_protocol
    hostname <- session$clientData$url_hostname
    pathname <- session$clientData$url_pathname
    port <- session$clientData$url_port
    search <- session$clientData$url_search

    glue::glue(
      "Protocol: {protocol}\n",
      "Hostname: {hostname}\n",
      "Pathname: {pathname}\n",
      "Port: {port}\n",
      "Search: {search}\n"
    )

  })

  output$query_text <- shiny::renderText({
    query <- shiny::parseQueryString(session$clientData$url_search)
    paste(names(query), query, sep = "=", collapse = ", ")
  })

  output$myplot <- renderPlot({
    info <- shiny::getCurrentOutputInfo()
    hist(rnorm(input$obs), main = "Generated in renderPlot()")
  })

  output$info <- shiny::renderText({
    paste("Plot last rendered at", Sys.time())
  })

  hold <- shiny::reactive({
    info <- getCurrentOutputInfo()
    jsonlite::toJSON(
      list(
        bg = info$bg(),
        fg = info$fg(),
        accent = info$accent(),
        font = info$font()
      ),
      auto_unbox = TRUE
    )
  })

}

shinyApp(ui, server)
