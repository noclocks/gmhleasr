
# merge pre_lease & weekly ------------------------------------------------

# get_pre_lease_summary_table <- function() {
#
#   report_data_pre_lease <- entrata_pre_lease_report()
#   report_data_weekly <- entrata_reports_pre_lease_weekly()
#
#   report_data_pre_lease_summary <- report_data_pre_lease$summary
#   report_data_weekly_summary <- report_data_weekly
#
#   out <- dplyr::left_join(
#     report_data_pre_lease_summary,
#     report_data_weekly_summary,
#     by = c("property_name")
#   )
#
# }

# report version ----------------------------------------------------------

#' Get Latest Report Version from Entrata
#'
#' @description
#' This function retrieves the latest version of a specified report from Entrata.
#' It's useful when you need to ensure you're working with the most up-to-date
#' version of a particular report.
#'
#' @param report_name A character string representing the name of the report.
#'
#' @return A character string representing the latest version of the report.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get the latest version of the "pre_lease" report
#' latest_version <- get_latest_report_version("pre_lease")
#' print(latest_version)
#' }
#'
#' @seealso
#' \code{\link{get_entrata_reports_list}} for getting a list of all available reports
#' \code{\link{get_entrata_report_info}} for getting detailed information about a specific report
#'
#' @importFrom dplyr filter pull
#' @importFrom rlang .data .env
get_latest_report_version <- function(report_name) {
  validate_entrata_report_name(report_name)

  latest_report_version <- get_entrata_reports_list(latest_only = TRUE) |>
    dplyr::filter(
      .data$report_name == {{ report_name }}
    ) |>
    dplyr::pull("report_version")

  return(latest_report_version)
}


# reports list ------------------------------------------------------------

#' Get List of Available Entrata Reports
#'
#' @description
#' This function retrieves a list of reports available in the Entrata system.
#' It provides information about each report, including its name, ID, system name,
#' and version. You can choose to get only the latest version of each report or
#' all available versions.
#'
#' @param latest_only Logical, if TRUE (default), returns only the latest version
#' of each report. If FALSE, returns all versions of all reports.
#'
#' @return A tibble containing report information with the following columns:
#' \itemize{
#'   \item report_id: Integer ID of the report
#'   \item report_name: Character string, name of the report
#'   \item system_name: Character string, system name of the report
#'   \item report_version: Character string, version of the report
#'   \item is_latest: Logical, indicating if this is the latest version (only when latest_only = FALSE)
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get the latest version of all reports
#' latest_reports <- get_entrata_reports_list()
#'
#' # Get all versions of all reports
#' all_reports <- get_entrata_reports_list(latest_only = FALSE)
#'
#' # View the first few rows of the reports list
#' head(latest_reports)
#' }
#'
#' @seealso
#' \code{\link{get_latest_report_version}} for getting the latest version of a specific report
#' \code{\link{get_entrata_report_info}} for getting detailed information about a specific report
#'
#' @importFrom dplyr filter left_join select
#' @importFrom tibblify tspec_df tib_int tib_chr tib_row tib_df tib_lgl
#' @importFrom purrr pluck set_names list_rbind
#' @importFrom httr2 req_perform resp_body_json
#' @importFrom rlang .data .env
get_entrata_reports_list <- function(latest_only = TRUE) {
  req <- entrata(endpoint = "reports", method = "getReportList")
  res <- httr2::req_perform(req)
  res_content <- res |>
    httr2::resp_body_json()

  reports_specs <- list(
    "getReportList" = list(
      main = tibblify::tspec_df(
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
      ),
      versions = tibblify::tspec_row(
        tibblify::tib_chr("version"),
        tibblify::tib_lgl("isLatest"),
        tibblify::tib_chr("titleAddendum", required = FALSE),
        tibblify::tib_chr("expiryDate", required = FALSE)
      )
    )
  )

  res_data <- res_content |>
    purrr::pluck("response", "result", "reports", "report") |>
    tibblify::tibblify(reports_specs$getReportList$main)

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

# report info -------------------------------------------------------------

#' Get Detailed Information for a Specific Entrata Report
#'
#' @description
#' This function retrieves detailed information for a specified report from Entrata,
#' including the report's name, description, and available filters. This is particularly
#' useful when you need to understand the structure and capabilities of a specific report
#' before running it or analyzing its data.
#'
#' @param report_name A character string representing the name of the report.
#' @param report_version A character string representing the version of the report.
#'   Defaults to "latest", which will automatically fetch the most recent version.
#'
#' @return A list containing the following elements:
#' \itemize{
#'   \item report_name: Character string, name of the report
#'   \item report_description: Character string, description of the report
#'   \item report_filters: A tibble containing information about the available filters for the report
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get information for the latest version of the "pre_lease" report
#' report_info <- get_entrata_report_info("pre_lease")
#'
#' # Print the report description
#' cat(report_info$report_description)
#'
#' # View the available filters for the report
#' print(report_info$report_filters)
#'
#' # Get information for a specific version of a report
#' specific_version_info <- get_entrata_report_info("pre_lease", report_version = "1.0")
#' }
#'
#' @seealso
#' \code{\link{get_entrata_reports_list}} for getting a list of all available reports
#' \code{\link{get_latest_report_version}} for getting the latest version of a specific report
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
        "report_name" == {{ report_name }}
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
