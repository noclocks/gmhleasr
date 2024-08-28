

# internal ----------------------------------------------------------------

validate_entrata_report_name <- function(report_name) {

  report_names <- entrata_reports() |>
    dplyr::pull(report_name) |>
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

get_property_ids_filter_param <- function() {

  entrata(endpoint = "properties", method = "getProperties", perform = TRUE) |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "PhysicalProperty", "Property") |>
    purrr::map(purrr::pluck, "PropertyID") |>
    purrr::map(as.character) |>
    purrr::list_flatten()

}

get_latest_report_version <- function(report_name) {

  latest_report_version <- entrata_reports(latest_only = TRUE) |>
    dplyr::filter(
      .data$report_name == .env$report_name
    ) |>
    dplyr::pull(report_version)

  return(latest_report_version)

}


# reports list ------------------------------------------------------------

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
    report_id = id,
    report_name = reportName,
    system_name = systemName,
    -reportVersions
  ) |>
    dplyr::left_join(
      res_data_report_versions,
      by = "report_name"
    ) |>
    dplyr::select(
      report_id,
      report_name,
      system_name,
      report_version = version,
      is_latest = isLatest,
      -c("titleAddendum", "expiryDate")
    )

  if (!latest_only) {
    return(res_data_merged)
  }

  res_data_merged |>
    dplyr::filter(
      is_latest == TRUE
    ) |>
    dplyr::select(
      -is_latest
    )

}


# report info -------------------------------------------------------------

get_entrata_report_info <- function(report_name, report_version = "latest") {

  validate_entrata_report_name(report_name)

  if (report_version == "latest") {
    latest_report_version <- entrata_reports(latest_only = TRUE) |>
      dplyr::filter(
        .data$report_name == .env$report_name
      ) |>
      dplyr::pull(report_version)
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

  spec <- tibblify::tspec_df(
    tibblify::tib_chr("name"),
    tibblify::tib_chr("description"),
    tibblify::tib_row(
      "filters",
      tibblify::tib_df(
        "filter",
        tibblify::tib_chr("name"),
        tibblify::tib_lgl("required"),
        tibblify::tib_row(
          "values",
          tibblify::tib_variant("value"),
        ),
        tibblify::tib_lgl("isArray"),
        tibblify::tib_lgl("allow_future_periods", required = FALSE),
      )
    )
  )

  res_data <- res |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "reports", "report", 1) |>
    tibble::as_tibble()

  res_data_filters <- res_data |>
    purrr::pluck("filters", "filter") |>
    purrr::map(tibble::as_tibble) |>
    purrr::list_rbind()

  res_data_merged <- dplyr::select(
    res_data,
    name,
    description,
    -filters
  ) |>
    dplyr::left_join(
      res_data_filters,
      by = "name"
    )

  return(res_data_merged)

}


# pre-lease report --------------------------------------------------------

prep_pre_lease_report_params <- function(
  latest_report_version,
  property_group_ids,
  period_start_date = "09/01/2024",
  period_type = "date",
  summarize_by = "property",
  group_by = "do_not_group",
  consider_pre_leased_on = "332",
  charge_code_detail = 0,
  space_options = 'do_not_show',
  additional_units_shown = 'available',
  combine_unit_spaces_with_same_lease = 0,
  consolidate_by = 'no_consolidation',
  arrange_by_property = 0,
  subtotals = list("summary", "details"),
  yoy = 1,
  ...
) {

  list(
    reportName = "pre_lease",
    reportVersion = latest_report_version,
    filters = list(
      property_group_ids = unlist(property_group_ids),
      period = list(
        date = "09/01/2024",
        period_type = "date"
      ),
      summarize_by = "property",
      group_by = "do_not_group",
      consider_pre_leased_on = "332",
      charge_code_detail = 0,
      space_options = 'do_not_show',
      additional_units_shown = 'available',
      combine_unit_spaces_with_same_lease = 0,
      consolidate_by = 'no_consolidation',
      arrange_by_property = 0,
      subtotals = list("summary", "details"),
      yoy = 1
    )
  )
}

entrata_pre_lease_report <- function(
  property_ids = c(NULL),
  period_start = "09/01/2024",
  ...
) {

  latest_report_version <- get_latest_report_version("pre_lease")
  property_group_ids <- get_property_ids_filter_param()

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
      max_tries = 5,
      max_seconds = 60,
      is_transient = report_queue_transient_retry,
      backoff = report_queue_backoff
    )

  res_queue <- httr2::req_perform(req_queue)

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

  leasing_season_ending <- lubridate::ymd("2025-08-01")

  # get number of weeks between today and leasing_season_ending date
  weeks_left_to_lease <- leasing_season_ending %--% today() |>
    lubridate::as.duration() |>
    as.numeric("weeks") |>
    floor()

  res_queue_data <- res_queue |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "reportData", "summary") |>
    jsonlite::toJSON(auto_unbox = TRUE, pretty = TRUE) |>
    jsonlite::fromJSON(flatten = TRUE) |>
    tibble::as_tibble() |>
    dplyr::rowwise() |>
    dplyr::mutate(
      leases_count = rowSums(
        dplyr::across(dplyr::all_of(sum_cols)),
        na.rm = TRUE
      ),
      total_beds = available_count,
      model_beds = 0,
      current_occupency = occupied_count / total_beds, # Total Leases / Total Beds
      total_new = approved_new_count,
      total_renewals = approved_renewal_count,
      total_leases = leases_count,
      prelease_percent = approved_percent,
      # prelease_percent = units / approved_count, # total beds / total leases
      prior_total_new = approved_new_count_prior,
      prior_total_renewals = approved_renewal_count_prior,
      prior_total_leases = approved_count_prior,
      prior_prelease_percent = prior_total_leases / total_beds, # Prior total leases / total beds
      yoy_variance_1 = total_leases - prior_total_leases,
      yoy_variance_2 = prelease_percent - prior_prelease_percent,
      # TODO: Preleasing Activity - Prior 7 days
      seven_new = 0,
      seven_renewal = 0,
      seven_total = seven_new + seven_renewal,
      seven_percent_gained = seven_total / total_beds,
      beds_left = total_beds - total_leases,
      leased_this_week = seven_total,
      vel_90 = beds_left * .9 / weeks_left_to_lease,
      vel_95 = beds_left * .95 / weeks_left_to_lease,
      vel_100 = beds_left * 1 / weeks_left_to_lease
    ) |>
    dplyr::select(
      # excluded_units = excluded_unit_count,
      property_name,
      total_beds,
      model_beds,
      current_occupency, # TODO: Check `available_count`
      total_new,
      total_renewals,
      total_leases,
      prelease_percent,
      # prelease_percent, # total beds / total leases
      prior_total_new,
      prior_total_renewals,
      prior_total_leases,
      prior_prelease_percent, # Prior total leases / total beds
      yoy_variance_1,
      yoy_variance_2,
      seven_new,
      seven_renewal,
      seven_total,
      seven_percent_gained,
      beds_left,
      leased_this_week,
      vel_90,
      vel_95,
      vel_100
    )

}




