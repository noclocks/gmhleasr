#
# #  ------------------------------------------------------------------------
# #
# # Title : Entrata Report Information
# #    By : Jimmy Briggs
# #  Date : 2024-08-31
# #
# #  ------------------------------------------------------------------------
#
# entrata_reports_info <- qs::qread("data-raw/cache/entrata_reports_info.qs")
#
# # reports -----------------------------------------------------------------
#
# entrata_reports <- get_entrata_reports_list()
# entrata_report_names <- entrata_reports$report_name
#
# entrata_reports_info <- purrr::map(
#   entrata_report_names,
#   ~ get_entrata_report_info(.x)
# ) |>
#   rlang::set_names(entrata_report_names)
#
# fs::dir_create("data-raw/cache")
# qs::qsave(entrata_reports_info, file = "data-raw/cache/entrata_reports_info.qs")
#
# entrata_reports_tbl <- purrr::map_dfr(
#   entrata_reports_info,
#   ~ tibble::as_tibble(.x)
# ) |>
#   dplyr::transmute(
#     report_name = .data$report_name,
#     report_description = .data$report_description,
#     filter_name = .data$report_filters$name,
#     filter_required = .data$report_filters$required,
#     filter_values = .data$report_filters$values,
#     filter_is_array = .data$report_filters$isArray,
#     filter_allow_future_periods = .data$report_filters$allow_future_periods,
#     filter_is_dependent_filter = .data$report_filters$isDependentFilter,
#     filter_dependencies = .data$report_filters$dependencies
#   )
#
# # pre-lease report --------------------------------------------------------
#
# pre_lease_report_filters <- entrata_reports_tbl |>
#   dplyr::filter(report_name == "pre_lease")
#
# property_ids_filter_param_values <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "property_group_ids") |>
#   dplyr::pull(filter_values) |>
#   purrr::map(~ as.character(.x)) |>
#   purrr::flatten_chr()
#
# res_properties <- entrata("properties", "getProperties", perform = TRUE)
#
# res_properties_content <- res_properties |>
#   httr2::resp_body_json() |>
#   purrr::pluck(
#     "response",
#     "result",
#     "PhysicalProperty",
#     "Property"
#   )
#
# property_names_and_ids <- res_properties_content |>
#   purrr::map_dfr(
#     function(x) {
#       name <- purrr::pluck(x, "MarketingName")
#       id <- purrr::pluck(x, "PropertyID")
#       tibble::tibble(name = name, id = id)
#     }
#   )
#
# property_ids_filter_param_values_2 <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "property_group_ids") |>
#   dplyr::pull(filter_values) |>
#   purrr::map(~ as.character(.x)) |>
#   purrr::flatten_chr() |>
#   rlang::set_names(
#      property_names_and_ids$name
#   )
#
# # pre_lease_report_filter_param_choice_opts <- list(
# #   "property_group_ids" = list(
# #     choices = property_ids_filter_param_values,
# #     selected = property_names_and_ids$id,
# #     multiple = TRUE,
# #     options = shinyWidgets::pickerOptions(
# #       actionsBox = TRUE,
# #       liveSearch = TRUE,
# #       liveSearchPlaceholder = "Search..."
# #     )
# #   )
# #
# #
# #     property_ids_filter_param_values,
# #   "period_start_date" = default_period_start_date,
# #
#
#
#
# # september 1st of current year
# default_period_start_date <- lubridate::make_date(
#   year = lubridate::year(lubridate::today()),
#   month = 9,
#   day = 1
# ) |>
#   format(
#     format = "%m/%d/%Y"
#   )
#
# period_types <- c("date", "today")
# default_period_type <- "date"
#
# summarize_by_options <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "summarize_by") |>
#   dplyr::pull(filter_values) |>
#   purrr::pluck("value") |>
#   purrr::flatten_chr()
#
# default_summarize_by <- "unit_type"
#
# group_by_options <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "group_by") |>
#   dplyr::pull(filter_values) |>
#   purrr::pluck("value") |>
#   purrr::flatten_chr()
#
# default_group_by <- "unit_type"
#
# consider_pre_leased_on_options <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "consider_pre_leased_on") |>
#   dplyr::pull(filter_values) |>
#   purrr::pluck("value") |>
#   purrr::flatten_int() |>
#   as.character()
#
# default_consider_pre_leased_on <- "33"
#
# charge_code_detail_options <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "charge_code_detail") |>
#   dplyr::pull(filter_values) |>
#   purrr::pluck("value") |>
#   purrr::flatten_chr() |>
#   as.integer()
#
# default_charge_code_detail <- 1
#
# space_options_options <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "space_options") |>
#   dplyr::pull(filter_values) |>
#   purrr::pluck("value") |>
#   purrr::flatten_chr()
#
# default_space_options <- "do_not_show"
#
# additional_units_shown_options <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "additional_units_shown") |>
#   dplyr::pull(filter_values) |>
#   purrr::pluck("value") |>
#   purrr::flatten_chr()
#
# default_additional_units_shown <- "available"
#
# combine_unit_spaces_with_same_lease_options <- c(0,1)
# default_combine_unit_spaces_with_same_lease <- 0
#
# consolidate_by_options <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "consolidate_by") |>
#   dplyr::pull(filter_values) |>
#   purrr::pluck("value") |>
#   purrr::flatten_chr()
#
# default_consolidate_by <- "no_consolidation"
#
# arrange_by_property_options <- c(0,1)
# default_arrange_by_property <- 0
#
# subtotals_options <- pre_lease_report_filters |>
#   dplyr::filter(filter_name == "subtotals") |>
#   dplyr::pull(filter_values) |>
#   purrr::pluck("value") |>
#   purrr::flatten_chr()
#
# default_subtotals <- list("summary", "details")
#
# yoy_options <- c(0,1)
# default_yoy <- 1
#
# get_default_pre_lease_filter_params <- function(...) {
#
#
#
#   list(
#     property_group_ids = property_ids_filter_param_values,
#     period_start_date = default_period_start_date,
#     period_type = default_period_type,
#     summarize_by = default_summarize_by,
#     group_by = default_group_by,
#     consider_pre_leased_on = default_consider_pre_leased_on,
#     charge_code_detail = default_charge_code_detail,
#     space_options = default_space_options,
#     additional_units_shown = default_additional_units_shown,
#     combine_unit_spaces_with_same_lease = default_combine_unit_spaces_with_same_lease,
#     consolidate_by = default_consolidate_by,
#     arrange_by_property = default_arrange_by_property,
#     subtotals = default_subtotals,
#     yoy = default_yoy
#   )
# }
#
# default_pre_lease_filter_params <- list(
#   property_group_ids = property_ids_filter_param_values,
#   period_start_date = "09/01/2024",
#   period_type = "date",
#   summarize_by = "unit_type",
#   group_by = "unit_type",
#   consider_pre_leased_on = "33",
#   charge_code_detail = 1,
#   space_options = "do_not_show",
#   additional_units_shown = "available",
#   combine_unit_spaces_with_same_lease = 0,
#   consolidate_by = "no_consolidation",
#   arrange_by_property = 0,
#   subtotals = list("summary", "details"),
#   yoy = 1
#
# )
#
# validate_pre_lease_report_filter_params <- function(
#   property_group_ids = property_ids_filter_param_values,
#   period_start_date = "09/01/2024",
#     period_type = "date",
#     summarize_by = "unit_type",
#     group_by = "unit_type",
#     consider_pre_leased_on = "33",
#     charge_code_detail = 1,
#     space_options = "do_not_show",
#     additional_units_shown = "available",
#     combine_unit_spaces_with_same_lease = 0,
#     consolidate_by = "no_consolidation",
#     arrange_by_property = 0,
#     subtotals = list("summary", "details"),
#     yoy = 1,
#     ...
# ) {
#     list(
#         reportName = "pre_lease",
#         reportVersion = latest_report_version,
#         filters = list(
#             property_group_ids = unlist(property_group_ids),
#             # period_type = "today",
#             period = list(
#                 date = period_start_date,
#                 period_type = period_type
#             ),
#             summarize_by = summarize_by,
#             group_by = group_by,
#             consider_pre_leased_on = consider_pre_leased_on,
#             charge_code_detail = charge_code_detail,
#             space_options = space_options,
#             additional_units_shown = additional_units_shown,
#             combine_unit_spaces_with_same_lease = combine_unit_spaces_with_same_lease,
#             consolidate_by = consolidate_by,
#             arrange_by_property = arrange_by_property,
#             subtotals = subtotals,
#             yoy = yoy
#         )
#     )
# }
# )
#
#
# prep_pre_lease_report_params <- function(
#     latest_report_version = mem_get_latest_report_version("pre_lease"),
#     property_group_ids = mem_get_property_ids_filter_param(),
#     period_start_date = "09/01/2024",
#     period_type = "date",
#     summarize_by = "unit_type",
#     group_by = "unit_type",
#     consider_pre_leased_on = "33",
#     charge_code_detail = 1,
#     space_options = "do_not_show",
#     additional_units_shown = "available",
#     combine_unit_spaces_with_same_lease = 0,
#     consolidate_by = "no_consolidation",
#     arrange_by_property = 0,
#     subtotals = list("summary", "details"),
#     yoy = 1,
#     ...) {
#   list(
#     reportName = "pre_lease",
#     reportVersion = latest_report_version,
#     filters = list(
#       property_group_ids = unlist(property_group_ids),
#       # period_type = "today",
#       period = list(
#         date = period_start_date,
#         period_type = period_type
#       ),
#       summarize_by = summarize_by,
#       group_by = group_by,
#       consider_pre_leased_on = consider_pre_leased_on,
#       charge_code_detail = charge_code_detail,
#       space_options = space_options,
#       additional_units_shown = additional_units_shown,
#       combine_unit_spaces_with_same_lease = combine_unit_spaces_with_same_lease,
#       consolidate_by = consolidate_by,
#       arrange_by_property = arrange_by_property,
#       subtotals = subtotals,
#       yoy = yoy
#     )
#   )
# }
