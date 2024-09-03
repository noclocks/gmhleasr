
#  ------------------------------------------------------------------------
#
# Title : Shiny App Inputs
#    By : Jimmy Briggs
#  Date : 2024-09-02
#
#  ------------------------------------------------------------------------

# internal ----------------------------------------------------------------


# picker inputs -----------------------------------------------------------

#' Picker Input
#'
#' @description
#' `picker()` is a function to create a picker input for a Shiny app.
#'
#' @param id Input ID for the picker
#' @param label Label for the picker
#' @param choices Choices for the picker
#' @param selected Selected choices
#' @param multiple Are multiple selections allowed?
#' @param count_threshold Threshold for displaying count of selected items,
#'   default is `3`.
#' @param choice_options Passed through to [shinyWidgets::pickerInput()]'s `choicesOpt`
#'   argument.
#' @param ... Additional arguments passed to [shinyWidgets::pickerInput()].
#'
#' @return A select input control that can be added to the app's UI.
#'
#' @seealso [shinyWidgets::pickerInput()]
#'
#' @export
#'
#' @importFrom shinyWidgets pickerInput pickerOptions
picker <- function(
  id,
  label,
  choices,
  selected = choices,
  multiple = TRUE,
  count_threshold = 3,
  choice_options = NULL,
  ...
) {

  shinyWidgets::pickerInput(
    id = id,
    label = label,
    choices = choices,
    selected = selected,
    multiple = multiple,
    choicesOpt = choice_options,
    options = shinyWidgets::pickerOptions(
      liveSearch = TRUE,
      liveSearchPlaceholder = "Search...",
      liveSearchNormalize = TRUE,
      actionsBox = TRUE,
      selectedTextFormat = paste0("count > ", count_threshold),
      countSelectedText = "{0} / {1} Selected",
      virtualScroll = 100,
      dropupAuto = FALSE,
      dropdownAlignRight = TRUE
    ),
    stateInput = TRUE,
    autocomplete = TRUE,
    ...
  )

}

#' Picker Input for Entrata Reports
#'
#' @param id id
#' @param label label
#' @param selected selected
#' @param ... dots
#'
#' @return a
#' @export
picker_entrata_reports <- function(
  id,
  label = "Select Report",
  selected = "pre_lease",
  ...
) {

  entrata_reports <- get_entrata_reports_list()
  entrata_report_names <- entrata_reports$report_name

  available_reports <- entrata_report_names |> unique() |> sort()

  picker(
    id = id,
    label = label,
    choices = available_reports,
    selected = selected,
    multiple = FALSE,
    ...
  )

}

picker_entrata_properties <- function(
  id,
  label = "Select Property",
  selected = NULL,
  multiple = TRUE,
  ...
) {

  entrata_properties <- entrata_properties()
  entrata_property_names <- entrata_properties$property_name
  entrata_property_ids <- entrata_properties$property_id

  property_choices <- entrata_property_ids
  names(property_choices) <- entrata_property_names

  picker(
    id = id,
    label = label,
    choices = property_choices,
    selected = property_choices,
    multiple = multiple,
    ...
  )

}

# picker_date <- function() {
#   shinyWidgets::airDatepickerInput(
#     airDatepickerInput(
#       inputId,
#       label = NULL,
#       value = NULL,
#       multiple = FALSE,
#       range = FALSE,
#       timepicker = FALSE,
#       separator = " - ",
#       placeholder = NULL,
#       dateFormat = "yyyy-MM-dd",
#       firstDay = NULL,
#       minDate = NULL,
#       maxDate = NULL,
#       disabledDates = NULL,
#       disabledDaysOfWeek = NULL,
#       highlightedDates = NULL,
#       view = c("days", "months", "years"),
#       startView = NULL,
#       minView = c("days", "months", "years"),
#       monthsField = c("monthsShort", "months"),
#       clearButton = FALSE,
#       todayButton = FALSE,
#       autoClose = FALSE,
#       timepickerOpts = timepickerOptions(),
#       position = NULL,
#       update_on = c("change", "close"),
#       onlyTimepicker = FALSE,
#       toggleSelected = TRUE,
#       addon = c("right", "left", "none"),
#       addonAttributes = list(class = "btn-outline-secondary"),
#       language = "en",
#       inline = FALSE,
#       readonly = FALSE,
#       onkeydown = NULL,
#       width = NULL
#     )
#
# }
