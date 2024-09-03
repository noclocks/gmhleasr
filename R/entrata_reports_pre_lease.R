#' Entrata Pre-Lease Report
#'
#' @description
#' This function generates a pre-lease report using the `reports` and `queue`
#' Entrata endpoints with their corresponding methods and input filter parameters.
#'
#' The response's report data will vary depending on the provided filter
#' parameters and should return a list with the extracted, un-processed report
#' data for the summary and details report "subtotals".
#'
#' @param property_ids A vector of property IDs to include in the report.
#'   Defaults to `get_property_ids_filter_param()`, which returns all available
#'   property IDs. The actual values passed to the request need to be unnamed and
#'   flattened to a character vector or single level list.
#' @param leasing_period_start_date The start date of the leasing period. Defaults
#'   to the result of `get_pre_lease_period_start_date()` which returns the date
#'   for September 1st of either the current year or the next year, depending on
#'   the current date. The date should be formatted as "m/d/Y".
#' @param leasing_period_type The type of leasing period. Defaults to "today".
#'   Can be one of "today" or "date".
#' @param summarize_by The method of summarizing the report. Defaults to "property".
#'   Can be one of "property", "unit_type", "floorplan_name", or "do_not_summarize".
#' @param group_by The method of grouping the report. Defaults to "do_not_group".
#'   Can be one of "do_not_group", "unit_type", "floorplan_name", or "lease_term".
#' @param consider_pre_leased_on The method of considering pre-leased units. Defaults
#'   to "33". Can be one of "32", "33", "34", "41", "42", "43", or "44", which
#'   (I believe) represent the various leasing occupancy types.
#' @param charge_code_detail The method of showing charge code details. Defaults to "0".
#'   If set to "1", the report will show charge code details.
#' @param space_options The method of showing space options. Defaults to "do_not_show".
#'   Can be one of "do_not_show", "show_preferred", or "show_actual".
#' @param additional_units_shown The method of showing additional units. Defaults to "available".
#'   Can be one of "available" or "excluded".
#' @param combine_unit_spaces_with_same_lease The method of combining unit spaces with the same lease.
#'   Defaults to "0". If set to "1", the report will combine unit spaces with the same lease.
#' @param consolidate_by The method of consolidating the report. Defaults to "no_consolidation".
#'   Can be one of "no_consolidation", "consolidate_all_properties", or "consolidate_by_property_groups".
#' @param arrange_by_property The method of arranging the report by property. Defaults to "0".
#'   If set to "1", the report will be arranged by property.
#' @param subtotals A list of subtotals to include in the report. Defaults to "summary" and "details".
#'   Can be one or both of "summary" and "details".
#' @param yoy The method of showing year-over-year data. Defaults to "1". If set to "0", the report
#'   will not show year-over-year data.
#' @param ... Additional parameters for the API request passed on to the downstream
#'   `entrata()` function.
#'
#' @details
#' The function performs the following steps:
#'
#' 1. Get the latest report version for the "pre_lease" report using the
#'    `get_latest_report_version()` function.
#' 2. Prepare the property IDs, leasing period start date, and period method parameters.
#' 3. Validate the input parameters for `summarize_by`, `group_by`, `consider_pre_leased_on`,
#'    `charge_code_detail`, `space_options`, `additional_units_shown`, `combine_unit_spaces_with_same_lease`,
#'    `consolidate_by`, `arrange_by_property`, `yoy`, and `subtotals`.
#' 4. Prepare the report request method parameters.
#' 5. Perform a request to get the queue ID.
#' 6. Extract the queue ID and display an alert message with the queue ID.
#' 7. Prepare a request to get the report data.
#' 8. Perform the request iteratively, throttling the retry until an actual response
#'    with data is received.
#' 9. Extract and parse the content from the response, separating "summary"
#'    and "details" data as necessary.
#' 10. Return a list with the extracted, un-processed report data for
#'     further downstream processing or analysis.
#'
#' @seealso [Entrata API Documentation](https://gmhcommunities.entrata.com/api/v1/documentation/getReportInfo)
#' @seealso [get_latest_report_version()], [get_property_ids_filter_param()], [get_pre_lease_period_start_date()]
#'
#' @return A list with the extracted, un-processed report data.
#'
#' @export
#'
#' @importFrom rlang .data .env arg_match
#' @importFrom cli cli_alert_info
#' @importFrom dplyr bind_rows
#' @importFrom httr2 resp_body_json req_retry req_perform
#' @importFrom lubridate mdy
#' @importFrom purrr pluck compact
entrata_pre_lease_report <- function(
    property_ids = get_property_ids_filter_param(),
    leasing_period_start_date = get_pre_lease_period_start_date(),
    leasing_period_type = c("today", "date"),
    summarize_by = c("property", "unit_type", "floorplan_name", "do_not_summarize"),
    group_by = c("do_not_group", "unit_type", "floorplan_name", "lease_term"),
    consider_pre_leased_on = c("33", "32", "34", "41", "42", "43", "44"),
    charge_code_detail = c("0", "1"),
    space_options = c("do_not_show", "show_preferred", "show_actual"),
    additional_units_shown = c("available", "excluded"),
    combine_unit_spaces_with_same_lease = c("0", "1"),
    consolidate_by = c("no_consolidation", "consolidate_all_properties", "consolidate_by_property_groups"),
    arrange_by_property = c("0", "1"),
    subtotals = list("summary", "details"),
    yoy = c("1", "0"),
    ...) {
  # get report version
  latest_report_version <- get_latest_report_version("pre_lease")

  # prepare property ids
  property_ids <- unlist(property_ids)
  names(property_ids) <- NULL

  # ensure leasing_period_start_date is character and formatted as "m/d/Y":
  leasing_period_start_date <- lubridate::mdy(leasing_period_start_date) |>
    format("%m/%d/%Y") |>
    as.character()

  # ensure leasing_period_type is one of "today" or "date":
  leasing_period_type <- rlang::arg_match(leasing_period_type, multiple = FALSE)

  # prepare period method parameter list
  period <- list(
    date = leasing_period_start_date,
    period_type = leasing_period_type
  )

  # validate summarize_by, group_by, consider_pre_leased_on, etc.
  summarize_by <- rlang::arg_match(summarize_by, multiple = FALSE)
  group_by <- rlang::arg_match(group_by, multiple = FALSE)
  consider_pre_leased_on <- rlang::arg_match(consider_pre_leased_on, multiple = FALSE)
  charge_code_detail <- rlang::arg_match(charge_code_detail, multiple = FALSE)
  space_options <- rlang::arg_match(space_options, multiple = FALSE)
  additional_units_shown <- rlang::arg_match(additional_units_shown, multiple = FALSE)
  combine_unit_spaces_with_same_lease <- rlang::arg_match(combine_unit_spaces_with_same_lease, multiple = FALSE)
  consolidate_by <- rlang::arg_match(consolidate_by, multiple = FALSE)
  arrange_by_property <- rlang::arg_match(arrange_by_property, multiple = FALSE)
  yoy <- rlang::arg_match(yoy, multiple = FALSE)

  # validate subtotals
  subtotals <- rlang::arg_match(subtotals, multiple = TRUE)

  # prepare report request method parameters
  req_method_params <- list(
    reportName = "pre_lease",
    reportVersion = latest_report_version,
    filters = list(
      property_group_ids = property_ids,
      period = period,
      summarize_by = summarize_by,
      group_by = group_by,
      consider_pre_leased_on = consider_pre_leased_on,
      charge_code_detail = charge_code_detail,
      space_options = space_options,
      additional_units_shown = additional_units_shown,
      combine_unit_spaces_with_same_lease = combine_unit_spaces_with_same_lease,
      consolidate_by = consolidate_by,
      arrange_by_property = arrange_by_property,
      subtotals = subtotals,
      yoy = yoy
    )
  )

  # perform request to get the queue ID
  res_queue_id <- entrata(
    endpoint = "reports",
    method = "getReportData",
    method_version = "r3",
    method_params = req_method_params,
    perform = TRUE
  )

  # extract queue id
  queue_id <- res_queue_id |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "queueId")

  cli::cli_alert_info(
    c(
      "Report generation request submitted.",
      "Queue ID: {.field {queue_id}}"
    )
  )

  # prepare request to get the report data
  req <- entrata(
    endpoint = "queue",
    method = "getResponse",
    method_params = list(
      queueId = queue_id,
      serviceName = "getReportData"
    ),
    enable_retry = TRUE,
    progress = TRUE,
    timeout = 60,
  ) |>
    httr2::req_retry(
      max_tries = 10,
      max_seconds = 60,
      is_transient = req_retry_is_transient,
      backoff = req_retry_backoff
    )

  # perform request iteratively until get back a response
  res <- httr2::req_perform(req)

  # extract/parse content from response
  res_content <- res_queue |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "reportData")

  # extract summary data
  res_data_summary <- NULL
  if ("summary" %in% subtotals) {
    res_data_summary <- res_content |>
      purrr::pluck("summary") |>
      dplyr::bind_rows()
  }

  # extract details data
  res_data_details <- NULL
  if ("details" %in% subtotals) {
    res_data_details <- res_content |>
      purrr::pluck("details") |>
      dplyr::bind_rows()
  }

  # return
  out <- list(summary = res_data_summary, details = res_data_details) |>
    purrr::compact()

  return(out)
}

# property ids ------------------------------------------------------------

#' Get Property IDs Filter Parameter
#'
#' @description
#' This function retrieves the list of property IDs to be used
#' as a filter parameter in Entrata API requests.
#'
#' @return A list of character strings representing property IDs.
#'
#' @export
#'
#' @importFrom httr2 resp_body_json
#' @importFrom purrr pluck map list_flatten
get_property_ids_filter_param <- function() {
  entrata(
    endpoint = "properties",
    method = "getProperties",
    perform = TRUE
  ) |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "PhysicalProperty", "Property") |>
    purrr::map(purrr::pluck, "PropertyID") |>
    purrr::map(as.character) |>
    purrr::list_flatten() |>
    unlist()
}
