# ------------------------------------------------------------------------
#
# Title : Entrata Leases
#    By : Jimmy Briggs
#  Date : 2024-08-28
#
# ------------------------------------------------------------------------

#' Retrieve Lease Information from Entrata API
#'
#' @description
#' This function retrieves lease information from the Entrata API. It allows for
#' filtering and customization of the lease data retrieval based on various parameters.
#'
#' @param property_id Required. Integer. The ID of the property to retrieve leases for.
#' @param application_id Optional. Integer. Filter leases by application ID.
#' @param customer_id Optional. Integer. Filter leases by customer ID.
#' @param lease_status_type_ids Optional. Integer vector. Filter leases by status type IDs.
#' @param lease_ids Optional. Integer vector. Retrieve specific leases by their IDs.
#' @param scheduled_ar_code_ids Optional. Integer vector. Filter leases by scheduled AR code IDs.
#' @param unit_number Optional. Character. Filter leases by unit number.
#' @param building_name Optional. Character. Filter leases by building name.
#' @param move_in_date_from Optional. Date. Filter leases with move-in date from this date.
#' @param move_in_date_to Optional. Date. Filter leases with move-in date up to this date.
#' @param lease_expiring_date_from Optional. Date. Filter leases expiring from this date.
#' @param lease_expiring_date_to Optional. Date. Filter leases expiring up to this date.
#' @param move_out_date_from Optional. Date. Filter leases with move-out date from this date.
#' @param move_out_date_to Optional. Date. Filter leases with move-out date up to this date.
#' @param include_other_income_leases Optional. Logical. Include other income leases in the results.
#' @param resident_friendly_mode Optional. Logical. Use resident-friendly mode for the results.
#' @param include_lease_history Optional. Logical. Include lease history information in the results.
#' @param include_ar_transactions Optional. Logical. Include AR transactions in the results.
#' @param pagination_page_number Integer. The page number for paginated results. Default is 1.
#' @param pagination_page_size Integer. Number of items per page. Default is 500.
#' @param include_pagination_links Logical. Include pagination links in the response. Default is FALSE.
#' @param ... Additional parameters to pass to the request.
#'
#' @return A tibble containing lease data with parsed and cleaned information.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Retrieve leases for a specific property
#' leases <- entrata_leases(property_id = 12345)
#'
#' # Retrieve leases with additional filters
#' filtered_leases <- entrata_leases(
#'   property_id = 12345,
#'   move_in_date_from = as.Date("2023-01-01"),
#'   move_in_date_to = as.Date("2023-12-31"),
#'   include_lease_history = TRUE
#' )
#' }
#'
#' @seealso
#' [parse_entrata_leases()] for details on how the API response is parsed.
#'
#' @importFrom httr2 req_headers req_url_query req_perform
#' @importFrom purrr compact
#' @importFrom cli cli_alert_warning cli_alert_info
entrata_leases <- function(
    property_id,
    application_id = as.integer(NULL),
    customer_id = as.integer(NULL),
    lease_status_type_ids = as.integer(c(NULL)),
    lease_ids = as.integer(c(NULL)),
    scheduled_ar_code_ids = as.integer(c(NULL)),
    unit_number = as.character(NULL),
    building_name = as.character(NULL),
    move_in_date_from = as.Date(NULL),
    move_in_date_to = as.Date(NULL),
    lease_expiring_date_from = as.Date(NULL),
    lease_expiring_date_to = as.Date(NULL),
    move_out_date_from = as.Date(NULL),
    move_out_date_to = as.Date(NULL),
    include_other_income_leases = FALSE,
    resident_friendly_mode = FALSE,
    include_lease_history = FALSE,
    include_ar_transactions = FALSE,
    pagination_page_number = 1,
    pagination_page_size = 500,
    include_pagination_links = FALSE,
    ...) {
  if (length(property_id) > 1) {
    cli::cli_alert_warning("The {.field getLeases} method requires a single {.field propertyId}.")
    property_id <- property_id[[1]]
    cli::cli_alert_info("Using the first property ID: {.field {property_id}}")
  }

  method_params <- list(
    propertyId = as.character(as.integer(property_id)),
    applicationId = application_id,
    customerId = customer_id,
    leaseStatusTypeIds = lease_status_type_ids,
    leaseIds = lease_ids,
    scheduledArCodeIds = scheduled_ar_code_ids,
    unitNumber = unit_number,
    buildingName = building_name,
    moveInDateFrom = move_in_date_from,
    moveInDateTo = move_in_date_to,
    leaseExpiringDateFrom = lease_expiring_date_from,
    leaseExpiringDateTo = lease_expiring_date_to,
    moveOutDateFrom = move_out_date_from,
    moveOutDateTo = move_out_date_to,
    includeOtherIncomeLeases = as.character(as.integer(include_other_income_leases)),
    residentFriendlyMode = as.character(as.integer(resident_friendly_mode)),
    includeLeaseHistory = as.character(as.integer(include_lease_history)),
    includeArTransactions = as.character(as.integer(include_ar_transactions))
  ) |>
    purrr::compact()

  req_body <- derive_req_body("getLeases", method_params, "r2")

  req <- entrata(
    endpoint = "leases",
    method = "getLeases",
    method_version = "r2",
    method_params = method_params,
    perform = FALSE,
    ...
  )

  if (include_pagination_links) {
    req <- req |>
      httr2::req_headers(`X-Send-Pagination-Links` = 1)
  }

  req <- req |>
    httr2::req_url_query(
      page_no = pagination_page_number,
      per_page = pagination_page_size
    )

  res <- req |>
    httr2::req_perform()

  parse_entrata_leases(res)
}


#' Parse Response for Entrata Leases
#'
#' @description
#' This function parses the response from the Entrata API's "getLeases" method.
#' It extracts and processes various components of the lease data, including
#' customer information, lease intervals, scheduled charges, and unit spaces.
#'
#' @details
#' The function performs the following steps:
#' 1. Extracts the main lease data from the API response.
#' 2. Parses specific components of the lease data using helper functions.
#' 3. Joins the parsed components back into a single tibble.
#' 4. Cleans and formats the data, including date parsing and type conversions.
#'
#' The following helper functions are used to parse specific components:
#' - `parse_entrata_lease_customers()`: Parses customer information
#' - `parse_entrata_lease_intervals()`: Parses lease interval data
#' - `parse_entrata_lease_scheduled_charges()`: Parses scheduled charges
#' - `parse_entrata_lease_unit_spaces()`: Parses unit space information
#'
#' @param res The [httr2::response()] object from the Entrata API
#'
#' @return A tibble containing parsed and cleaned lease data, including:
#' - Basic lease information (ID, status, dates, etc.)
#' - Customer information
#' - Lease interval details
#' - Scheduled charges
#' - Unit space information
#'
#' @seealso
#' [entrata_leases()] for retrieving lease data from the Entrata API.
#'
#' @export
#'
#' @importFrom httr2 resp_body_json
#' @importFrom purrr pluck map_dfr
#' @importFrom tibble as_tibble
#' @importFrom dplyr select mutate left_join distinct
#' @importFrom janitor clean_names
#' @importFrom lubridate parse_date_time
parse_entrata_leases <- function(res) {
  res_content <- res |>
    httr2::resp_body_json() |>
    purrr::pluck("response", "result", "leases", "lease") |>
    purrr::map_dfr(tibble::as_tibble) |>
    janitor::clean_names() |>
    dplyr::rename(lease_id = id)

  list_cols <- res_content |>
    dplyr::select(where(is.list)) |>
    names()

  res_content_df <- res_content |>
    dplyr::select(-dplyr::all_of(list_cols))

  res_lease_intervals <- parse_entrata_lease_intervals(res_content)
  res_customers <- parse_entrata_lease_customers(res_content)
  res_scheduled_charges <- parse_entrata_lease_scheduled_charges(res_content)
  res_unit_spaces <- parse_entrata_lease_unit_spaces(res_content)

  res_content_df |>
    dplyr::left_join(res_lease_intervals, by = c("lease_id", "lease_interval_id")) |>
    dplyr::left_join(res_customers, by = "lease_id") |>
    dplyr::left_join(dplyr::distinct(res_scheduled_charges), by = "lease_id", relationship = "many-to-many") |>
    dplyr::left_join(res_unit_spaces, by = "lease_id", relationship = "many-to-many") |>
    dplyr::mutate(
      move_in_date = lubridate::parse_date_time(move_in_date, orders = "mdy"),
      is_month_to_month = as.logical(is_month_to_month),
      lease_approved_on = lubridate::parse_date_time(lease_approved_on, orders = "mdy HMS"),
      application_completed_on = lubridate::parse_date_time(application_completed_on, orders = "mdy HMS"),
      lease_start_date = lubridate::parse_date_time(lease_start_date, orders = "mdy"),
      lease_end_date = lubridate::parse_date_time(lease_end_date, orders = "mdy"),
      is_active_lease_interval = ifelse(is_active_lease_interval == "t", TRUE, FALSE),
      lease_interval_start_date = lubridate::parse_date_time(lease_interval_start_date, orders = "mdy"),
      lease_interval_end_date = lubridate::parse_date_time(lease_interval_end_date, orders = "mdy"),
      lease_interval_application_completed_on = lubridate::parse_date_time(lease_interval_application_completed_on, orders = "mdy HMS"),
      lease_interval_date_time = lubridate::parse_date_time(lease_interval_date_time, orders = "mdy HMS"),
      customer_move_in_date = lubridate::parse_date_time(customer_move_in_date, orders = "mdy"),
      customer_phone_number = display_phone_number(strip_phone_number(customer_phone_number)),
      scheduled_charges_start_date = lubridate::parse_date_time(scheduled_charges_start_date, orders = "mdy"),
      scheduled_charges_end_date = lubridate::parse_date_time(scheduled_charges_end_date, orders = "mdy"),
      scheduled_charges_amount = as.numeric(scheduled_charges_amount)
    ) |>
    dplyr::select(-dplyr::where(~ all(is.na(.)))) |>
    dplyr::distinct()
}


# parsers -----------------------------------------------------------------

#' @describeIn parse_entrata_leases Parse Entrata Lease Customers
#'
#' @param res_content Response content to parse
#'
#' @return A tibble containing parsed customer data for each lease.
#'
#' @export
#'
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom tidyr unnest_longer unnest
#' @importFrom dplyr select mutate rename_with left_join distinct
#' @importFrom stringr str_replace
#' @importFrom janitor clean_names
#' @importFrom rlang .data .env
parse_entrata_lease_customers <- function(res_content) {
  res_content |>
    dplyr::select(lease_id, customers) |>
    tidyr::unnest_longer(customers) |>
    jsonlite::toJSON(auto_unbox = TRUE) |>
    jsonlite::fromJSON(flatten = TRUE) |>
    tidyr::unnest("customers.addresses.address") |>
    tidyr::unnest("customers.phones.phone") |>
    tidyr::unnest("customers.customerContacts.customerContact") |>
    janitor::clean_names() |>
    dplyr::rename_with(
      ~ stringr::str_replace(.x, "customers_", "customer_"),
      dplyr::starts_with("customers_")
    ) |>
    dplyr::select(
      lease_id,
      customer_id,
      customer_type = "customer_customer_type",
      customer_name = "customer_name_full",
      customer_email = "customer_email_address",
      customer_lease_status = "customer_lease_customer_status",
      customer_relationship = "customer_relationship_name",
      customer_move_in_date = "customer_move_in_date",
      customer_payment_allowance_type = "customer_payment_allowance_type",
      customer_address_street = "street_line",
      customer_address_city = "city",
      customer_address_state = "state",
      customer_address_zip_code = "postal_code",
      customer_phone_number = "phone_number",
      customer_phone_type = "phone_type"
    ) |>
    dplyr::mutate(
      lease_id = as.character(lease_id),
      customer_id = as.character(customer_id)
    )
}


#' @describeIn parse_entrata_leases Parse Entrata Lease Intervals
#'
#' @param res_content Response content to parse
#'
#' @return A tibble containing parsed lease interval data for each lease.
#'
#' @export
#'
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom tidyr unnest_longer unnest
#' @importFrom dplyr select mutate rename_with
#' @importFrom stringr str_replace
#' @importFrom janitor clean_names
parse_entrata_lease_intervals <- function(res_content) {
  res_content |>
    dplyr::select(lease_id, lease_intervals) |>
    tidyr::unnest_longer("lease_intervals") |>
    jsonlite::toJSON(auto_unbox = TRUE) |>
    jsonlite::fromJSON(flatten = TRUE) |>
    tidyr::unnest(c("lease_intervals.applications.application")) |>
    janitor::clean_names() |>
    dplyr::rename_with(
      ~ stringr::str_replace(.x, "lease_intervals_", "lease_interval_"),
      dplyr::starts_with("lease_intervals_")
    ) |>
    dplyr::select(
      lease_id,
      lease_approved_on,
      application_completed_on,
      lease_term,
      lease_start_date,
      lease_end_date,
      lease_interval_id,
      is_active_lease_interval,
      lease_interval_start_date,
      lease_interval_end_date,
      lease_interval_type_id = "lease_interval_lease_interval_type_id",
      lease_interval_type = "lease_interval_lease_interval_type_name",
      lease_interval_status_type_id = "lease_interval_lease_interval_status_type_id",
      lease_interval_status_type = "lease_interval_lease_interval_status_type_name",
      lease_interval_application_completed_on = "lease_interval_application_completed_on",
      lease_interval_application_id = "lease_interval_application_id",
      lease_interval_date_time = "lease_interval_interval_date_time"
    ) |>
    dplyr::mutate(
      lease_id = as.character(lease_id),
      lease_interval_id = as.character(lease_interval_id),
      lease_interval_type_id = as.character(lease_interval_type_id),
      lease_interval_status_type_id = as.character(lease_interval_status_type_id)
    )
}


#' @describeIn parse_entrata_leases Parse Entrata Lease Scheduled Charges
#'
#' @param res_content Response content to parse
#'
#' @return A tibble containing parsed scheduled charges data for each lease.
#'
#' @export
#'
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom tidyr unnest_longer
#' @importFrom dplyr select mutate
#' @importFrom janitor clean_names
parse_entrata_lease_scheduled_charges <- function(res_content) {
  res_content |>
    dplyr::select(lease_id, scheduled_charges) |>
    tidyr::unnest_longer("scheduled_charges") |>
    jsonlite::toJSON(auto_unbox = TRUE) |>
    jsonlite::fromJSON(flatten = TRUE) |>
    janitor::clean_names() |>
    dplyr::mutate(
      lease_id = as.character(lease_id),
      scheduled_charges_id = as.character(scheduled_charges_id)
    )
}

#' @describeIn parse_entrata_leases Parse Entrata Lease Unit Spaces
#'
#' @param res_content Response content to parse
#'
#' @return A tibble containing parsed unit spaces data for each lease.
#'
#' @export
#'
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom tidyr unnest_longer
#' @importFrom dplyr select mutate
#' @importFrom janitor clean_names
parse_entrata_lease_unit_spaces <- function(res_content) {
  res_content |>
    dplyr::select(lease_id, unit_spaces) |>
    tidyr::unnest_longer("unit_spaces") |>
    jsonlite::toJSON(auto_unbox = TRUE) |>
    jsonlite::fromJSON(flatten = TRUE) |>
    janitor::clean_names() |>
    dplyr::select(
      lease_id,
      unit_space_id = "unit_spaces_unit_space_id",
      unit_space = "unit_spaces_unit_space"
    ) |>
    dplyr::mutate(
      lease_id = as.character(lease_id),
      unit_space_id = as.character(unit_space_id)
    )
}
