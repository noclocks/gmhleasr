#' Executive Dashboard UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_dashboard_ui <- function(id) {
  ns <- NS(id)

  htmltools::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        bs4Dash::valueBoxOutput(
          ns("number_of_properties"),
          width = 4
        ),
        bs4Dash::valueBoxOutput(
          ns("total_portfolio_value"),
          width = 4
        ),
        bs4Dash::valueBoxOutput(
          ns("total_portfolio_return"),
          width = 4
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        picker_entrata_properties(ns("properties")),
        htmltools::tags$h1(
          "Leasing Summary Report",
          style = "text-align: center; margin-top: 20px;"
        ),
        htmltools::tags$div(
          style = "display: flex; justify-content: center; align-items: center;",
          shiny::downloadButton(ns("download_excel"), "Export to Excel")
        ),
        htmltools::tags$div(
          style = "text-align: center;",
          shinyFeedback::loadingButton(
            ns("refresh_data"),
            "Refresh Data"
          ),
          htmltools::tags$h5(
            "Last Refresh:",
            htmltools::tags$text(
              style = "font-weight: bolder;",
              shiny::textOutput(ns("data_last_refreshed"))
            )
          )
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        DT::DTOutput(ns("summary_table")) |> shinycustomloader::withLoader()
      )
    ),
    htmltools::tags$br()
  )
}

#' Executive Dashboard Server Function
#'
#' @noRd
mod_dashboard_server <- function(id, app_globals) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    reports_queue_id <- shiny::reactiveVal(NULL)
    pre_lease_summary_data <- shiny::reactiveValues(
      summary = NULL,
      details = NULL
    )

    # get "pre_lease" summary data from reports endpoint
    pre_lease_report_data <- shiny::reactive({
      shiny::req(input$properties)

      entrata_pre_lease_report(
        property_ids = input$properties
      )
    }) |>
      shiny::bindCache(
        input$properties,
        cache = "app"
      ) |>
      shiny::bindEvent(
        input$refresh_data,
        ignoreInit = TRUE,
        ignoreNULL = TRUE,
        label = "refresh_data"
      )

    shiny::observe({
      shiny::req(pre_lease_report_data())
      pre_lease_summary_data$summary <- pre_lease_report_data()$summary
      pre_lease_summary_data$details <- pre_lease_report_data()$details
    }) |>
      shiny::bindEvent(pre_lease_report_data())


    output$portfolio_table <- DT::renderDataTable({
      # Add your portfolio performance data here
    })

    output$property_leasing_table <- DT::renderDataTable({
      # Add your property leasing information data here
    })


    # valueboxes --------------------------------------------------------------
    num_properties <- shiny::reactive({
      shiny::req(input$properties)
      length(input$properties)
    })

    output$number_of_properties <- bs4Dash::renderValueBox({
      shiny::req(num_properties())
      bs4Dash::valueBox(
        value = num_properties(),
        subtitle = "Total Properties",
        icon = shiny::icon("building"),
        color = "primary",
        width = 12,
        footer = htmltools::tags$a(
          href = "#",
          "View Details"
        )
      )
    })

    output$total_portfolio_value <- bs4Dash::renderValueBox({
      shiny::req(input$properties)
      shiny::req(pre_lease_summary_data$summary)
      bs4Dash::valueBox(
        value = shiny::prettyNum(
          pre_lease_summary_data$summary$total_portfolio_value,
          big.mark = ","
        ),
        subtitle = "Total Portfolio Value",
        icon = shiny::icon("dollar-sign"),
        color = "success",
        width = 12,
        footer = htmltools::tags$a(
          href = "#",
          "View Details"
        )
      )
    })
  })
}
