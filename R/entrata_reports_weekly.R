

entrata_reports_pre_lease_weekly <- function(
  property_ids = get_property_ids_filter_param(),
  period_type = c("currentwk", "lastwk", "daterange"),
  period_start_date = get_weekly_period_start_date(),
  period_end_date = as.character(format(lubridate::today(), "%m/%d/%Y")),
  consolidate_by = c("no_consolidation", "consolidate_all_properties", "consolidate_by_property_groups"),
  occupied_as_of_date = period_start_date,
  details_only = c("0", "1"),
  space_options = c("0", "1"),
  ...
) {

  # get report version
  latest_report_version <- get_latest_report_version("gmh_weekly_pre_leasing_report")

  # prepare property ids
  property_ids <- unlist(property_ids)
  names(property_ids) <- NULL

  # period type
  period_type <- rlang::arg_match(period_type, multiple = FALSE)

  # period
  period <- list(
    daterange = list(
      `daterange-start` = period_start_date,
      `daterange-end` = period_end_date
    ),
    period_type = period_type
  )

  # occupied_as_of
  occupied_as_of <- list(
    date = occupied_as_of_date,
    period_type = "date"
  )

  # consolidate_by
  consolidate_by <- rlang::arg_match(consolidate_by, multiple = FALSE)

  # details and space options
  details_only <- rlang::arg_match(details_only, multiple = FALSE)
  space_options <- rlang::arg_match(space_options, multiple = FALSE)

  # prepare report request method parameters
  req_method_params <- list(
    reportName = "gmh_weekly_pre_leasing_report",
    reportVersion = latest_report_version,
    filters = list(
      property_group_ids = property_ids,
      period = period,
      consolidate_by = consolidate_by,
      occupied_as_of = occupied_as_of,
      details_only = details_only#,
      # space_options = space_options
    )
  )

  # initialize progress
  cli::cli_progress_step(
    paste0(
      "Performing Entrata API Request for the ",
      "{.field gmh_weekly_pre_leasing_report} report..."
    ),
    msg_done = paste0(
      "Successfully retrieved data for the ",
      "{.field gmh_weekly_pre_leasing_report} report."
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

  cli::cli_progress_step(
    c(
      "Successfully retrieved the Queue ID (JWT) for the ",
      "{.field gmh_weekly_pre_leasing_report} report: {.field {queue_id}}"
    ),
    class = ".alert-success"
  )

  # prepare request to get the report data
  req <- entrata(
    endpoint = "queue",
    method = "getResponse",
    version = "r1",
    method_params = list(
      queueId = queue_id,
      serviceName = "getReportData"
    )
  ) |>
    httr2::req_retry(
      max_tries = 20,
      max_seconds = 120,
      is_transient = req_retry_is_transient
    )

  cli::cli_progress_step(
    "Attempting to get report data using the queue id...",
    spinner = TRUE
  )

  # perform request iteratively until get back a response
  res <- httr2::req_perform(req)

  # extract/parse content from response
  res_content <- res |>
    httr2::resp_body_json()

  cli::cli_progress_step(
    "Successfully retrieved report data for the {.field gmh_weekly_pre_leasing_report} report.",
    class = ".alert-success"
  )

  # if (!purrr::pluck_exists(res_content, "response", "result", "reportData")) {
  #   return(res_content)
  # }

  # extract data
  extract_weekly_res_data(res_content)

}

extract_weekly_res_data <- function(res_content, ...) {

  res_data <- res_content |>
    purrr::pluck("response", "result", "reportData")

  leasing_summary <- purrr::pluck(
    res_data,
    "leasing_summary"
  ) |>
    purrr::map(tibble::as_tibble) |>
    dplyr::bind_rows()

  cumulative_rental_rate_summary <- purrr::pluck(
    res_data,
    "cumulative_rental_rate_summary"
  ) |>
    purrr::map(purrr::compact) |>
    purrr::map(tibble::as_tibble) |>
    dplyr::bind_rows()

  weekly_rental_rate_summary <- purrr::pluck(
    res_data,
    "weekly_rental_rate_summary"
  ) |>
    purrr::map(purrr::compact) |>
    purrr::map(tibble::as_tibble) |>
    dplyr::bind_rows()

  leasing_velocity <- purrr::pluck(
    res_data,
    "leasing_velocity"
  ) |>
    purrr::map(tibble::as_tibble) |>
    dplyr::bind_rows()

  other_monthly_income <- purrr::pluck(
    res_data,
    "other_monthly_income"
  ) |>
    purrr::map(tibble::as_tibble) |>
    dplyr::bind_rows()

  lease_term_summary <- purrr::pluck(
    res_data,
    "lease_term_summary"
  ) |>
    purrr::map(tibble::as_tibble) |>
    dplyr::bind_rows()

  summary_data <- weekly_rental_rate_summary |>
    dplyr::group_by("property_name") |>
    dplyr::summarise(
      new_leases = sum(.data$new_leases, na.rm = TRUE),
      new_renewals = sum(.data$renewals, na.rm = TRUE),
      new_total = new_leases + new_renewals
    ) |>
    dplyr::ungroup()

  list(
    summary_data = summary_data,
    leasing_summary = leasing_summary,
    cumulative_rental_rate_summary = cumulative_rental_rate_summary,
    weekly_rental_rate_summary = weekly_rental_rate_summary,
    leasing_velocity = leasing_velocity,
    other_monthly_income = other_monthly_income,
    lease_term_summary = lease_term_summary
  )

}

get_weekly_period_start_date = function(end_date = lubridate::today()) {
  hold <- lubridate::today() - lubridate::days(7)
  out <- format(hold, "%m/%d/%Y") |> as.character()
  out
}
