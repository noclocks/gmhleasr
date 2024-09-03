#' Leases UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_leases_ui <- function(id){
  ns <- NS(id)
  tagList(
    bs4Card(
      title = "Lease Information",
      status = "primary",
      width = 12,
      uiOutput(ns("lease_info"))
    )
  )
}

#' Leases Server Function
#'
#' @noRd
mod_leases_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$lease_info <- renderUI({
      # Add your lease information UI elements here
    })
  })
}
