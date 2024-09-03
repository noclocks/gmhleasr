#  ------------------------------------------------------------------------
#
# Title : Entrata Reports Data Preparations
#    By : Jimmy Briggs
#  Date : 2024-09-02
#
#  ------------------------------------------------------------------------


# load --------------------------------------------------------------------
pkgload::load_all()

# call the reports endpoint's getReportList method:
entrata_reports <- get_entrata_reports_list(latest_only = TRUE)
entrata_report_names <- entrata_reports$report_name

# derive "choices"
entrata_report_choices <- entrata_report_names |>
  rlang::set_names(
    entrata_reports$system_name
  )

# retrieve information for each report
entrata_reports_info <- purrr::map(
  entrata_report_names,
  get_entrata_report_info
) |>
  rlang::set_names(entrata_report_names)

qs::qsave(entrata_reports_info, file = "data-raw/cache/entrata_reports_info.qs")

entrata_reports_info_df <- purrr::map(
  entrata_reports_info,
  tibble::as_tibble
) |>
  purrr::map(
    ~ tidyr::unnest(.x, cols = report_filters)
  ) |>
  purrr::list_rbind() |>
  dplyr::select(
    report_name,
    report_description,
    filter_name = name,
    filter_required = required,
    filter_values = values,
    filter_is_array = isArray,
    filter_allow_future_periods = allow_future_periods,
    filter_is_dependent_filter = isDependentFilter,
    filter_dependencies = dependencies
  )

entrata_report_descriptions <- entrata_reports_info_df |>
  dplyr::select("report_name", "report_description") |>
  dplyr::distinct()

entrata_reports <- dplyr::left_join(
  entrata_reports,
  entrata_report_descriptions,
  by = "report_name"
)

entrata_report_filters <- entrata_reports_info_df |>
  dplyr::select(
    report_name,
    filter_name,
    filter_required,
    filter_is_array,
    filter_allow_future_periods,
    filter_is_dependent_filter,
    filter_dependencies,
    filter_values
  )
