# internal ----------------------------------------------------------------

#' Validate Entrata Report Name
#'
#' @description This function checks if a provided report name exists in the
#' list of available Entrata reports. If the report name is not valid,
#' an error is thrown with suggestions for valid report names.
#'
#' @param report_name A character string representing the report name to validate.
#'
#' @return NULL. Throws an error if the report name is invalid.
#'
#' @export
#'
#' @importFrom cli cli_alert_danger cli_alert_info cli_abort
#' @importFrom dplyr filter pull
validate_entrata_report_name <- function(report_name) {

  report_names <- get_entrata_reports_list(latest_only = TRUE) |>
    dplyr::pull("report_name") |>
    unique()

  if (!report_name %in% report_names) {
    cli::cli_alert_danger(
      "The report name provided, {.field {report_name}}, is not valid."
    )

    cli::cli_alert_info(
      "Available report names are: {.field {report_names}}"
    )

    cli::cli_abort("Invalid Report Name.")
  }
}

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
    purrr::list_flatten()
}



# reports list ------------------------------------------------------------

#' Get Entrata Reports List
#'
#' @description
#' This function retrieves a list of reports available in the
#' Entrata system, optionally filtering to only the latest version of each report.
#'
#' @param latest_only Logical, if TRUE (default), returns only the latest version
#' of each report.
#'
#' @return A tibble containing report information including report name, ID,
#' system name, and version.
#'
#' @export
#'
#' @importFrom dplyr filter left_join select
#' @importFrom tibblify tspec_df tib_int tib_chr tib_row tib_df tib_lgl
#' @importFrom purrr pluck set_names list_rbind
#' @importFrom httr2 req_perform resp_body_json
#' @importFrom rlang .data .env
get_entrata_reports_list <- function(latest_only = TRUE) {

  req <- entrata(endpoint = "reports", method = "getReportList")

  spec <- tibblify::tspec_df(
    tibblify::tib_int("id"),
    tibblify::tib_chr("reportName"),
    tibblify::tib_chr("systemName"),
    tibblify::tib_row(
      "reportVersions",
      tibblify::tib_df(
        "reportVersion",
        tibblify::tib_chr("version"),
        tibblify::tib_lgl("isLatest"),
        tibblify::tib_chr("titleAddendum", required = FALSE),
        tibblify::tib_chr("expiryDate", required = FALSE),
      )
    )
  )

  spec_versions <- tibblify::tspec_row(
    tibblify::tib_chr("version"),
    tibblify::tib_lgl("isLatest"),
    tibblify::tib_chr("titleAddendum", required = FALSE),
    tibblify::tib_chr("expiryDate", required = FALSE)
  )

  res <- httr2::req_perform(req)

  res_data <- res |>
    httr2::resp_body_json() |>
    purrr::pluck(
      "response",
      "result",
      "reports",
      "report"
    ) |>
    tibblify::tibblify(spec)

  report_names <- res_data$reportName

  res_data_report_versions <- purrr::pluck(
    res_data,
    "reportVersions",
    "reportVersion"
  ) |>
    rlang::set_names(report_names) |>
    purrr::list_rbind(names_to = "report_name")

  res_data_merged <- dplyr::select(
    res_data,
    "report_id" = "id",
    "report_name" = "reportName",
    "system_name" = "systemName",
    -c("reportVersions")
  ) |>
    dplyr::left_join(
      res_data_report_versions,
      by = "report_name"
    ) |>
    dplyr::select(
      "report_id",
      "report_name",
      "system_name",
      "report_version" = "version",
      "is_latest" = "isLatest",
      -c("titleAddendum", "expiryDate")
    )

  if (!latest_only) {
    return(res_data_merged)
  }

  res_data_merged |>
    dplyr::filter(
      .data$is_latest == TRUE
    ) |>
    dplyr::select(
      -c("is_latest")
    )
}



#' Get Latest Report Version
#'
#' @description
#' This function retrieves the latest version of a specified
#' report from Entrata.
#'
#' @param report_name A character string representing the name of the report.
#'
#' @return A character string representing the latest version of the report.
#'
#' @export
#'
#' @importFrom dplyr filter pull
#' @importFrom rlang .data .env
get_latest_report_version <- function(report_name) {

  validate_entrata_report_name(report_name)

  latest_report_version <- get_entrata_reports_list(latest_only = TRUE) |>
    dplyr::filter(
      .data$report_name == {{report_name}}
    ) |>
    dplyr::pull("report_version")

  return(latest_report_version)
}



# report info -------------------------------------------------------------

#' Get Entrata Report Info
#'
#' @description
#' This function retrieves detailed information for a specified
#' report from Entrata, including filters and descriptions.
#'
#' @param report_name A character string representing the name of the report.
#' @param report_version A character string representing the version of the report.
#'   Defaults to "latest".
#'
#' @return A list containing report name, description, and filters.
#'
#' @export
#'
#' @importFrom dplyr filter pull
#' @importFrom rlang .data .env
#' @importFrom purrr pluck map list_rbind
#' @importFrom httr2 req_perform resp_body_json
get_entrata_report_info <- function(report_name, report_version = "latest") {
  validate_entrata_report_name(report_name)

  if (report_version == "latest") {
    latest_report_version <- mem_get_entrata_reports_list(latest_only = TRUE) |>
      dplyr::filter(
        "report_name" == {{report_name}}
      ) |>
      dplyr::pull("report_version")
  }

  req <- entrata(
    endpoint = "reports",
    method = "getReportInfo",
    method_params = list(
      reportName = report_name,
      reportVersion = latest_report_version
    )
  )

  res <- httr2::req_perform(req)

  res_content <- res |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "reports", "report", 1)

  res_report_name <- res_content |> purrr::pluck("name")
  res_report_description <- res_content |> purrr::pluck("description")
  res_report_filters <- res_content |>
    purrr::pluck("filters", "filter") |>
    purrr::map(tibble::as_tibble) |>
    purrr::list_rbind()

  res_report_info <- list(
    report_name = res_report_name,
    report_description = res_report_description,
    report_filters = res_report_filters
  )

  return(res_report_info)
}



# pre-lease report --------------------------------------------------------

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
    period_start_date = "09/01/2024",
    period_type = "date",
    summarize_by = "unit_type",
    group_by = "unit_type",
    consider_pre_leased_on = "33",
    charge_code_detail = 1,
    space_options = "do_not_show",
    additional_units_shown = "available",
    combine_unit_spaces_with_same_lease = 0,
    consolidate_by = "no_consolidation",
    arrange_by_property = 0,
    subtotals = list("summary", "details"),
    yoy = 1,
    ...) {
  list(
    reportName = "pre_lease",
    reportVersion = latest_report_version,
    filters = list(
      property_group_ids = unlist(property_group_ids),
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
    property_ids = c(NULL),
    period_start = "09/01/2024",
    ...
) {

  latest_report_version <- mem_get_latest_report_version("pre_lease")
  property_group_ids <- mem_get_property_ids_filter_param()

  req_method_params <- prep_pre_lease_report_params(
    latest_report_version = latest_report_version,
    property_group_ids = property_group_ids
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
    )
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

  leasing_season_ending <- lubridate::ymd("2025-08-01")

  # get number of weeks between today and leasing_season_ending date
  weeks_left_to_lease <- leasing_season_ending %--% today() |>
    lubridate::as.duration() |>
    as.numeric("weeks") |>
    floor()

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
