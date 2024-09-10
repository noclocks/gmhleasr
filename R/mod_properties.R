
#  ------------------------------------------------------------------------
#
# Title : Properties Shiny Module
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

#' Properties Module
#'
#' @name mod_properties
#'
#' @description
#' A module for displaying the GMH Communities Properties data.
#'
#' @details
#' The module includes both the UI and server functions for the properties:
#' - `mod_properties_ui()`: The UI function for the properties
#' - `mod_properties_server()`: The server function for the properties
#'
#' The properties module will include the following elements:
#' - Properties Table
#' - Properties Map
#' - Properties Chart
#' - Properties Info
#'
#' @param id The module id
#' @param input,output,session Internal parameters for {shiny}.
#' @param ... Additional parameters
#'
#' @return
#' - `mod_properties_ui()`: An [htmltools::tagList()] of the properties UI elements
#' - `mod_properties_server()`: List of reactive expressions for the properties
NULL

#' @rdname mod_properties
#' @export
#' @importFrom shiny NS icon tabPanel fluidRow column
#' @importFrom bs4Dash tabBox boxLabel boxDropdown boxDropdownItem
#' @importFrom DT dataTableOutput
#' @importFrom htmltools tags
#' @importFrom shinycustomloader withLoader
mod_properties_ui <- function(id) {

  ns <- shiny::NS(id)

  bs4Dash::tabBox(
    id = ns("tabbox"),
    title = "Properties",
    width = 12,
    type = "tabs",
    footer = "GMH Communities Properties Data Pulled from Entrata API.",
    status = "primary",
    solidHeader = TRUE,
    collapsible = TRUE,
    closable = FALSE,
    maximizable = TRUE,
    icon = shiny::icon("building"),
    headerBorder = TRUE,

    label = bs4Dash::boxLabel(
      text = "Properties",
      status = "primary",
      tooltip = "GMH Communities Properties"
    ),

    dropdownMenu = bs4Dash::boxDropdown(
      icon = shiny::icon("ellipsis-v"),
      bs4Dash::boxDropdownItem(
        id = ns("item1"),
        href = "#",
        icon = shiny::icon("building")
      )
    ),

    shiny::tabPanel(
      title = " ",
      value = ns("tab_properties_table"),
      icon = shiny::icon("table"),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          DT::dataTableOutput(ns("properties_table")) |>
            shinycustomloader::withLoader()
        )
      )
    ),

    shiny::tabPanel(
      title = " ",
      value = ns("tab_properties_map"),
      icon = shiny::icon("map"),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          htmltools::tags$iframe(
            src = "https://www.google.com/maps/d/embed?mid=19tP5Bf66khGcrNnqTBsk879W2fS-u7U&ehbc=2E312F&noprof=1",
            width = "100%",
            height = 600
          )
        )
      )
    ),

    shiny::tabPanel(
      title = " ",
      value = ns("tab_properties_chart"),
      icon = shiny::icon("chart-line"),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          # highcharter::highchartOutput(ns("properties_chart")) |>
            # shinycustomloader::withLoader()
        )
      )
    ),

    shiny::tabPanel(
      title = " ",
      value = ns("tab_properties_info"),
      icon = shiny::icon("info"),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          htmltools::tags$h2("About the GMH Communities Properties Data"),
          htmltools::tags$p(
            "The GMH Communities Properties data is pulled from the Entrata API. ",
            "The data is updated every 24 hours and is used to provide insights into the performance of the properties."
          )
        )
      )
    )
  )
}

#' @rdname mod_properties
#' @export
#' @importFrom DT renderDataTable
#' @importFrom googleway renderGoogle_map
#' @importFrom highcharter renderHighchart
#' @importFrom shiny moduleServer reactive
mod_properties_server <- function(id, ...) {

  shiny::moduleServer(
    id,
    function(input, output, session) {

      ns <- session$ns

      properties_data_rv <- shiny::reactive({

      })

      output$properties_table <- DT::renderDataTable({
        # Add properties data here
      })

      output$properties_map <- googleway::renderGoogle_map({
        # Add properties map here
      })

      output$properties_chart <- highcharter::renderHighchart({
        # Add properties chart here
      })

  })
}
