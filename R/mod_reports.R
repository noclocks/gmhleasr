#  ------------------------------------------------------------------------
#
# Title : Reports Module
#    By : Jimmy Briggs
#  Date : 2024-09-02
#
#  ------------------------------------------------------------------------


# UI ----------------------------------------------------------------------

mod_reports_ui <- function(id, ...) {
  ns <- shiny::NS(id)

  htmltools::tagList(
    flucol(
      htmltools::tags$div(
        style = "display: inline-flex; justify-content: space-around;",
        picker_entrata_reports(id = ns("report"))
      )
    ),
    flucol(
      DT::DTOutput(ns("summary_table")) |>
        shinycustomloader::withLoader()
    )
  )
}

# SERVER ------------------------------------------------------------------

mod_reports_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    tbl_prep <- shiny::reactive({
      data <- entrata_pre_lease_report()
    })

    output$summary_table <- DT::renderDT({
      shiny::req(input$report, tbl_prep())

      dat <- tbl_prep()$summary

      tbl_prep() |>
        purrr::pluck("summary") |>
        dplyr::group_by()
    })
  })
}
