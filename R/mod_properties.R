#' Properties UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_properties_ui <- function(id){
  ns <- NS(id)
  tagList(
    bs4Card(
      title = "Leasing Performance",
      status = "primary",
      width = 12,
      plotly::plotlyOutput(ns("leasing_performance_chart"))
    ),
    bs4Card(
      title = "Weekly Stats",
      status = "primary",
      width = 12,
      DT::dataTableOutput(ns("weekly_stats_table"))
    )
  )
}

#' Properties Server Function
#'
#' @noRd
mod_properties_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$leasing_performance_chart <- plotly::renderPlotly({
      # Add your leasing performance chart here
    })

    output$weekly_stats_table <- DT::renderDataTable({
      # Add your weekly stats data here
    })
  })
}
