

# pre-lease report --------------------------------------------------------

# {
#   "response": {
#     "requestId": "15",
#     "code": 200,
#     "result": {
#       "reports": {
#         "report": [
#           {
#             "name": "pre_lease",
#             "description": "This is primarily created to assist Student properties in their pre leasing process.",
#             "filters": {
#               "property_group_ids": [
#                 518041,
#                 518042,
#                 518044,
#                 518046,
#                 577897,
#                 641240,
#                 676055,
#                 739076,
#                 739079,
#                 739080,
#                 739084,
#                 739085,
#                 833617,
#                 952515,
#                 1115679,
#                 1143679,
#                 1161867,
#                 1197886,
#                 1197887,
#                 1311849
#               ],
#               "period": {
#                 "date": "m/d/Y",
#                 "period_type": "today,date"
#               },
#               "lease_occupancy_types": [],
#               "summarize_by": "unit_type,floorplan_name,property,do_not_summarize",
#               "group_by": "unit_type,floorplan_name,lease_term,do_not_group",
#               "consider_pre_leased_on": "32,33,34,41,42,43,44",
#               "leases_included": [],
#               "ledger_charge_code": [],
#               "charge_code_detail": "0,1",
#               "space_options": "show_preferred,show_actual,do_not_show",
#               "additional_units_shown": [
#                 "available",
#                 "excluded"
#               ],
#               "combine_unit_spaces_with_same_lease": "0,1",
#               "consolidate_by": "no_consolidation,consolidate_all_properties,consolidate_by_property_groups",
#               "arrange_by_property": "0,1",
#               "subtotals": [
#                 "summary",
#                 "details"
#               ],
#               "yoy": "0,1"
#             }
#           }
#         ]
#       }
#     }
#   }
# }

# Defaults
# All properties
# Period start date: (need to verify) - 9/1 of the next year (if past 9/1 this year else 9/1 of this year)
# lease occupancy types: all
# summarize by: unit type
# group by: unit type
# lease occupancy types: all (blank in JSON)
# consider pre leased on: 33 (report params is 'Lease: Partially Completed')
# leases included: report params lists all leases, json response above is blank
# charge code details: 1 (for TRUE) to show
# space options: do not show
# combine unit spaces with same lease: 0 (for FALSE)
# consolidate by: no consolidation
# arrange by property: 0 (for FALSE)
# subtotals: summary, details
# yoy: 1 (for TRUE)

#' Prepare Pre-Lease Report Parameters
#'
#' @description
#' This function prepares the parameters required for generating a
#' pre-lease report in Entrata.
#'
#' @param latest_report_version A character string representing the latest
#' version of the pre-lease report. Defaults to fetching the latest version.
#' @param property_group_ids A list of property group IDs to include in the report.
#' @param period_start_date The start date of the reporting period. Defaults to "09/01/2024".
#' @param period_type The type of period for the report. Defaults to "date".
#' @param summarize_by The level at which to summarize the report. Defaults to "unit_type".
#' @param group_by The level at which to group the report. Defaults to "unit_type".
#' @param consider_pre_leased_on A string representing the pre-leased on date. Defaults to "33".
#' @param charge_code_detail An integer for charge code details. Defaults to 1.
#' @param space_options A string representing space options. Defaults to "do_not_show".
#' @param additional_units_shown A string representing additional units shown. Defaults to "available".
#' @param combine_unit_spaces_with_same_lease An integer indicating whether to combine unit spaces. Defaults to 0.
#' @param consolidate_by A string indicating consolidation options. Defaults to "no_consolidation".
#' @param arrange_by_property An integer indicating whether to arrange by property. Defaults to 0.
#' @param subtotals A list of subtotals to include in the report. Defaults to c("summary", "details").
#' @param yoy An integer indicating whether to include year-over-year data. Defaults to 1.
#' @param ... Additional parameters for the report.
#'
#' @return A list of parameters for the pre-lease report.
#'
#' @export
prep_pre_lease_report_params <- function(
    latest_report_version = mem_get_latest_report_version("pre_lease"),
    property_group_ids = mem_get_property_ids_filter_param(),
    period_start_date = get_pre_lease_period_start_date(),
    period_type = c("date", "today"),
    summarize_by = c("unit_type", "floorplan_name", "property", "do_not_summarize"),
    group_by = c("unit_type", "floorplan_name", "lease_term", "do_not_group"),
    consider_pre_leased_on = c("33", "32", "34", "41", "42", "43", "44"),
    charge_code_detail = c("0", "1"),
    space_options = c("do_not_show", "show_preferred", "show_actual"),
    additional_units_shown = c("available", "excluded"),
    combine_unit_spaces_with_same_lease = c("0", "1"),
    consolidate_by = c("no_consolidation", "consolidate_all_properties", "consolidate_by_property_groups"),
    arrange_by_property = c("0", "1"),
    subtotals = list("summary", "details"),
    yoy = c("1", "0"),
    ...
) {

  if (!is.character(latest_report_version)) latest_report_version <- as.character(latest_report_version)
  if (is.list(property_group_ids)) property_group_ids <- unlist(property_group_ids)
  names(property_group_ids) <- NULL
  period_type <- rlang::arg_match(period_type, c("date", "today"), multiple = FALSE)
  summarize_by <- rlang::arg_match(summarize_by, c("unit_type", "floorplan_name", "property", "do_not_summarize"), multiple = FALSE)
  group_by <- rlang::arg_match(group_by, c("unit_type", "floorplan_name", "lease_term", "do_not_group"), multiple = FALSE)
  consider_pre_leased_on <- rlang::arg_match(consider_pre_leased_on, c("33", "32", "34", "41", "42", "43", "44"), multiple = FALSE)
  charge_code_detail <- rlang::arg_match(charge_code_detail, c("0", "1"), multiple = FALSE)
  space_options <- rlang::arg_match(space_options, c("do_not_show", "show_preferred", "show_actual"), multiple = FALSE)
  additional_units_shown <- rlang::arg_match(additional_units_shown, c("available", "excluded"), multiple = FALSE)
  combine_unit_spaces_with_same_lease <- rlang::arg_match(combine_unit_spaces_with_same_lease, c("0", "1"), multiple = FALSE)
  consolidate_by <- rlang::arg_match(consolidate_by, c("no_consolidation", "consolidate_all_properties", "consolidate_by_property_groups"), multiple = FALSE)
  arrange_by_property <- rlang::arg_match(arrange_by_property, c("0", "1"), multiple = FALSE)
  yoy <- rlang::arg_match(yoy, c("1", "0"), multiple = FALSE)

  list(
    reportName = "pre_lease",
    reportVersion = latest_report_version,
    filters = list(
      property_group_ids = property_group_ids,
      # period_type = "today",
      period = list(
        date = period_start_date,
        period_type = period_type
      ),
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
}



#' Generate Pre-Lease Report
#'
#' @description
#' This function generates a pre-lease report in Entrata based on
#' the provided parameters and returns the summary and details of the report.
#'
#' @param property_ids A vector of property IDs to include in the report.
#' @param period_start The start date of the reporting period. Defaults to "09/01/2024".
#'
#' @param ... Additional parameters for the report.
#'
#' @return A list containing the summary and details of the pre-lease report.
#'
#' @export
#'
#' @importFrom dplyr bind_rows transmute across all_of
#' @importFrom lubridate ymd today %--% as.duration
#' @importFrom httr2 req_perform resp_body_json req_retry
#' @importFrom purrr pluck
#' @importFrom rlang .data .env
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
    ...
) {

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

prepare_pre_lease_summary_data_from_response <- function(
    res_data_summary,
    ...
) {




}



period = list(date = get_pre_lease_period_start_date(), period_type = "today"),

period_start = get_pre_lease_period_start_date(),
...) {

  latest_report_version <- mem_get_latest_report_version("pre_lease")

  if (is.null(property_ids)) {
    property_ids <- mem_get_property_ids_filter_param()
  }

  req_method_params <- prep_pre_lease_report_params(
    latest_report_version = latest_report_version,
    property_group_ids = property_ids,
    period_start_date = period_start
  )

  req <- entrata(
    endpoint = "reports",
    method = "getReportData",
    method_version = "r3",
    method_params = req_method_params
  )

  res <- httr2::req_perform(req)

  res_queue_id <- res |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "queueId")

  req_queue <- entrata(
    endpoint = "queue",
    method = "getResponse",
    method_params = list(
      queueId = res_queue_id,
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

  res_queue <- httr2::req_perform(req_queue)

  res_content <- res_queue |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "reportData")

  res_data_summary <- res_content |>
    purrr::pluck("summary") |>
    dplyr::bind_rows()

  res_data_details <- res_content |>
    purrr::pluck("details") |>
    dplyr::bind_rows()

  leasing_season_ending_year <- lubridate::mdy(period_start) |>
    lubridate::year() + 1

  leasing_season_ending <- lubridate::ymd(
    paste0(
      as.character(leasing_season_ending_year),
      "-08-01"
    )
  )

  leasing_season_start_date <- lubridate::mdy(period_start)
  leasing_season_end_date <- leasing_season_start_date + lubridate::years(1) - lubridate::days(1)

  # get number of weeks between today and leasing_season_start date
  weeks_left_to_lease <- leasing_season_start_date %--% today() |>
    lubridate::as.duration() |>
    as.numeric("weeks") |>
    floor() * -1

  sum_cols <- c(
    "approved_count",
    "completed_count",
    "completed_renewal_count",
    "partially_completed_count",
    "partially_completed_new_count",
    "partially_completed_renewal_count",
    "preleased_count",
    "preleased_new_count",
    "preleased_renewal_count"
  )

  res_data_summary_out <- res_data_summary |>
    dplyr::transmute(
      property_id = .data$property_id,
      property_name = .data$property_name,
      leases_count = rowSums(
        dplyr::across(dplyr::all_of(sum_cols)),
        na.rm = TRUE
      ),
      total_beds = .data$available_count,
      model_beds = 0,
      current_occupied = .data$occupied_count,
      current_occupency = .data$occupied_count / .data$total_beds, # Total Leases / Total Beds
      total_new = .data$approved_new_count + .data$partially_completed_new_count + .data$completed_new_count,
      total_renewals = .data$approved_renewal_count + .data$partially_completed_renewal_count + .data$completed_renewal_count,
      total_leases = .data$total_new + .data$total_renewals, # leases_count,
      prelease_percent = .data$approved_percent,
      # prelease_percent = units / approved_count, # total beds / total leases
      prior_total_new = .data$approved_new_count_prior + .data$partially_completed_new_count_prior + .data$completed_new_count_prior,
      prior_total_renewals = .data$approved_renewal_count_prior + .data$partially_completed_renewal_count_prior + .data$completed_renewal_count_prior,
      prior_total_leases = .data$approved_count_prior + .data$partially_completed_count_prior + .data$completed_count_prior,
      prior_prelease_percent = .data$prior_total_leases / .data$total_beds,
      yoy_variance_1 = .data$total_leases - .data$prior_total_leases,
      yoy_variance_2 = .data$prelease_percent - .data$prior_prelease_percent,
      seven_new = 0,
      seven_renewal = 0,
      seven_total = .data$seven_new + .data$seven_renewal,
      seven_percent_gained = .data$seven_total / .data$total_beds,
      beds_left = .data$total_beds - .data$total_leases,
      leased_this_week = .data$seven_total,
      vel_90 = .data$beds_left * .9 / .env$weeks_left_to_lease,
      vel_95 = .data$beds_left * .95 / .env$weeks_left_to_lease,
      vel_100 = .data$beds_left * 1 / .env$weeks_left_to_lease
    )

  res_data_details_out <- res_data_details

  list(
    summary = res_data_summary_out,
    details = res_data_details_out
  )
}




