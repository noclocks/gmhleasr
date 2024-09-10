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
        picker_entrata_properties(id = ns("properties")),
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
    htmltools::tags$br(),
    shiny::fluidRow(
      bs4Dash::valueBoxOutput(
        ns("number_of_properties"),
        width = 4
      ),
      bs4Dash::valueBoxOutput(
        ns("number_of_units"),
        width = 4
      ),
      bs4Dash::valueBoxOutput(
        ns("avg_sch_rent"),
        width = 4
      )
    ),
    htmltools::tags$br(),
    shiny::fluidRow(
      shiny::column(
        width = 12,
        DT::DTOutput(ns("summary_table")) |> shinycustomloader::withLoader()
      )
    )
  )
}

#' Executive Dashboard Server Function
#'
#' @noRd
mod_dashboard_server <- function(id, global_data) {

  shiny::moduleServer(id, function(input, output, session) {

    ns <- session$ns

    # get "pre_lease" summary data from reports endpoint
    pre_lease_report_data <- shiny::reactive({
      shiny::req(input$properties, global_data$pre_lease)

      summary_data <- global_data$pre_lease$summary |>
        dplyr::filter(
          property_id %in% input$properties
        )

      details_data <- global_data$pre_lease$details |>
        dplyr::filter(
          property_id %in% input$properties
        )

      list(
        summary = summary_data,
        details = details_data
      )
    })

    output$summary_table <- DT::renderDataTable({
      shiny::req(pre_lease_report_data())
      dat <- pre_lease_report_data()$summary
      DT::datatable(
        dat,
        rownames = FALSE,
        options = list(
          autoWidth = TRUE,
          pageLength = 10
        )
      )
    })

    output$details_table <- DT::renderDataTable({
      shiny::req(pre_lease_report_data())
      dat <- pre_lease_report_data()$details
      DT::datatable(
        dat,
        rownames = FALSE,
        options = list(
          autoWidth = TRUE,
          pageLength = 10
        )
      )
    })

    # valueboxes --------------------------------------------------------------
    num_properties <- shiny::reactive({
      shiny::req(input$properties)
      length(input$properties)
    })

    output$number_of_properties <- bs4Dash::renderValueBox({
      shiny::req(num_properties())
      bs4Dash::valueBox(
        value = paste0(as.character(num_properties()), " Properties"),
        subtitle = "Number of Properties",
        icon = shiny::icon("building"),
        color = "primary",
        width = 12,
        footer = "Number of Properties",
        gradient = TRUE
      )
    })

    output$number_of_units <- bs4Dash::renderValueBox({
      shiny::req(input$properties)
      shiny::req(pre_lease_report_data()$summary)
      bs4Dash::valueBox(
        value = prettyNum(
          sum(pre_lease_report_data()$summary$units, na.rm = TRUE),
          big.mark = ","
        ),
        subtitle = "Total Units",
        icon = shiny::icon("house"),
        color = "success",
        width = 12,
        footer = "Number of Units"
      )
    })

    output$avg_sch_rent <- bs4Dash::renderValueBox({
      shiny::req(input$properties)
      shiny::req(pre_lease_report_data()$summary)
      bs4Dash::valueBox(
        value = paste0(
          "$",
          prettyNum(
            round(mean(pre_lease_report_data()$summary$avg_scheduled_rent, na.rm = TRUE), 2),
            big.mark = ","
          )
        ),
        subtitle = "Average Scheduled Rent",
        icon = shiny::icon("dollar-sign"),
        color = "info",
        width = 12,
        footer = "Average Scheduled Rent"
      )
    })
  })
}
