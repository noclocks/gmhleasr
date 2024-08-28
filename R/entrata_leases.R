# ------------------------------------------------------------------------
#
# Title : Entrata Leases
#    By : Jimmy Briggs
#  Date : 2024-08-28
#
# ------------------------------------------------------------------------

#' Entrata Leases
#'
#' @description
#' This function retrieves lease information from the Entrata API.
#'
#' @param property_ids Required. Integer vector of property IDs
#' @param application_id Optional. Integer value of the application ID
#' @param customer_id Optional. Integer value of the customer ID
#' @param lease_status_type_ids Optional. Integer vector of lease status type IDs
#' @param lease_ids Optional. Integer vector of lease IDs
#' @param scheduled_ar_code_ids Optional. Integer vector of scheduled AR code IDs
#' @param unit_number Optional. Character value of the unit number
#' @param building_name Optional. Character value of the building name
#' @param move_in_date_from Optional. Date value of the move-in date from
#' @param move_in_date_to Optional. Date value of the move-in date to
#' @param lease_expiring_date_from Optional. Date value of the lease expiring from
#' @param lease_expiring_date_to Optional. Date value of the lease expiring to
#' @param move_out_date_from Optional. Date value of the move-out date from
#' @param move_out_date_to Optional. Date value of the move-out date to
#' @param include_other_income_leases Optional. Logical value to include other income leases
#' @param resident_friendly_mode Optional. Logical value to include resident friendly mode
#' @param include_lease_history Optional. Logical value to include lease history information
#' @param include_ar_transactions Optional. Logical value to include AR transactions
#' @param pagination_page_number Pagination page number. Default is 1
#' @param pagination_page_size Number of items per page. Default is 500
#' @param include_pagination_links Logical value to include pagination links in the response. Default is FALSE
#' @param ... Additional parameters to pass to the request
#'
#' @return Parsed Response Body Content as a tibble with leases data.
#'
#' @export
#'
#' @seealso [parse_entrata_leases()]
#'
#' @importFrom httr2 req_headers req_url_query req_perform
#' @importFrom purrr compact
entrata_leases <- function(
    property_ids,
    application_id = NULL,
    customer_id = NULL,
    lease_status_type_ids = NULL,
    lease_ids = NULL,
    scheduled_ar_code_ids = NULL,
    unit_number = NULL,
    building_name = NULL,
    move_in_date_from = NULL,
    move_in_date_to = NULL,
    lease_expiring_date_from = NULL,
    lease_expiring_date_to = NULL,
    move_out_date_from = NULL,
    move_out_date_to = NULL,
    include_other_income_leases = NULL,
    resident_friendly_mode = NULL,
    include_lease_history = NULL,
    include_ar_transactions = NULL,
    pagination_page_number = 1,
    pagination_page_size = 500,
    include_pagination_links = FALSE,
    ...) {
  prop_ids <- paste(property_ids, collapse = ",")

  method_params <- purrr::compact(list(
    propertyId = prop_ids,
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
    includeOtherIncomeLeases = include_other_income_leases,
    residentFriendlyMode = resident_friendly_mode,
    includeLeaseHistory = include_lease_history,
    includeArTransactions = include_ar_transactions
  ))

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
#'
#' @details
#' The core function is `parse_entrata_leases()`, which parses the response
#' from the Entrata API's "getLeases" method called via [entrata_leases()].
#'
#' `parse_entrata_leases()` calls the following functions to parse the response:
#'   - `parse_entrata_lease_customers()`: Parse Entrata lease customers
#'   - `parse_entrata_lease_intervals()`: Parse Entrata lease intervals
#'   - `parse_entrata_lease_scheduled_charges()`: Parse Entrata lease scheduled charges
#'   - `parse_entrata_lease_unit_spaces()`: Parse Entrata lease unit spaces
#'
#' @param res The [httr2::response()] object from the Entrata API
#'
#' @return Parsed Response Body Content as a tibble with leases data.
#'
#' @seealso [entrata_leases()]
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
#' @export
#'
#' @return Parsed Response Body Content as a tibble with lease customer data.
#'
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom tidyr unnest_longer unnest
#' @importFrom dplyr select mutate rename_with left_join distinct
#' @importFrom stringr str_replace
#' @importFrom janitor clean_names
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
#' @export
#'
#' @return Parsed Response Body Content as a tibble with lease interval data.
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
#' @return Parsed Response Body Content as a tibble with lease scheduled charges data.
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
#' @return Parsed Response Body Content as a tibble with lease unit spaces data.
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
