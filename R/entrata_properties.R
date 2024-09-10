# exported ----------------------------------------------------------------

#' Retrieve Properties from Entrata API
#'
#' @description
#' This function retrieves property information from the Entrata API. It allows for
#' filtering properties based on IDs, lookup codes, and status.
#'
#' @param property_ids Character vector of Property IDs to include in the request.
#'   If NULL, all properties will be returned. Default is NULL.
#' @param property_lookup_codes Character string with a "Property Lookup Code"
#'   to include in the request. Default is NULL.
#' @param show_all_status Logical: if TRUE, will return all properties, regardless
#'   of status. Default is FALSE.
#' @param include_lease_terms Logical: if TRUE, will include lease term information
#'   in the results. Default is FALSE.
#' @param ... Additional parameters to pass to the underlying [entrata()] function.
#'
#' @return If include_lease_terms is FALSE (default), returns a tibble with property information.
#'   If include_lease_terms is TRUE, returns a list with two elements:
#'   \item{properties}{A tibble with property information}
#'   \item{lease_terms}{A tibble with lease term information for each property}
#'
#' @export
#'
#' @seealso [entrata()], [parse_property_res_data()]
#' @seealso \url{https://gmhcommunities.entrata.com/api/v1/documentation/getProperties}
#'
#' @examples
#' \dontrun{
#' # Retrieve all properties
#' all_properties <- entrata_properties()
#'
#' # Retrieve specific properties by ID
#' specific_properties <- entrata_properties(property_ids = c("123", "456"))
#'
#' # Retrieve properties with lease terms
#' properties_with_lease_terms <- entrata_properties(include_lease_terms = TRUE)
#' }
#'
#' @importFrom httr2 req_perform
#' @importFrom purrr compact pluck
entrata_properties <- function(
  property_ids = NULL,
  property_lookup_codes = NULL,
  show_all_status = FALSE,
  include_lease_terms = FALSE,
  ...
) {
  prop_ids <- if (!is.null(property_ids)) {
    paste(property_ids, collapse = ",")
  } else {
    NULL
  }

  method_params <- list(
    propertyIds = prop_ids,
    propertyLookupCode = property_lookup_codes,
    showAllStatus = as.integer(show_all_status)
  ) |>
    purrr::compact()

  res <- entrata(
    endpoint = "properties",
    method = "getProperties",
    method_params = method_params,
    perform = TRUE,
    ...
  )

  res_content <- httr2::resp_body_json(res)

  res_data <- res_content |>
    purrr::pluck(
      "response",
      "result",
      "PhysicalProperty",
      "Property"
    )

  parse_property_res_data(res_data, lease_terms = include_lease_terms)
}

#' Parse Entrata Properties Response Data
#'
#' @description
#' This function parses the response from the Entrata API's "getProperties" method.
#' It extracts and processes various components of the property data, including
#' address information, lease terms, and other property details.
#'
#' @param res_data Response data from the Entrata API's "getProperties" method.
#' @param lease_terms Logical: if TRUE, will include lease term information in the results.
#'   Default is FALSE.
#'
#' @return If lease_terms is FALSE (default), returns a tibble with property information.
#'   If lease_terms is TRUE, returns a list with two elements:
#'   \item{properties}{A tibble with property information}
#'   \item{lease_terms}{A tibble with lease term information for each property}
#'
#' @export
#'
#' @importFrom dplyr select distinct
#' @importFrom tibblify tspec_df tib_int tib_chr tib_row tib_unspecified tib_df tib_lgl tibblify
#' @importFrom tidyr unnest
parse_property_res_data <- function(res_data, lease_terms = FALSE) {

  tspec <- tibblify::tspec_df(
    property_id = tibblify::tib_int("PropertyID"),
    property_name = tibblify::tib_chr("MarketingName"),
    property_type = tibblify::tib_chr("Type"),
    property_website = tibblify::tib_chr("webSite"),
    property_description_short = tibblify::tib_chr("ShortDescription", required = FALSE),
    property_description_long = tibblify::tib_chr("LongDescription", required = FALSE),
    is_disabled = tibblify::tib_int("IsDisabled"),
    is_featured = tibblify::tib_int("IsFeaturedProperty"),
    parent_property_id = tibblify::tib_int("ParentPropertyID", required = FALSE),
    year_built = tibblify::tib_chr("YearBuilt", required = FALSE),
    property_address = tibblify::tib_row(
      "Address",
      tibblify::tib_row(
        "@attributes",
        address_type = tibblify::tib_chr("AddressType"),
      ),
      address = tibblify::tib_chr("Address"),
      city = tibblify::tib_chr("City"),
      state = tibblify::tib_chr("State"),
      zip = tibblify::tib_chr("PostalCode"),
      country = tibblify::tib_chr("Country"),
      email = tibblify::tib_chr("Email"),
    ),
    tibblify::tib_unspecified(
      "Addresses"
    ),
    property_post_months = tibblify::tib_row(
      "PostMonths",
      ar_post_month = tibblify::tib_chr("ArPostMonth"),
      ap_post_month = tibblify::tib_chr("ApPostMonth"),
      gl_post_month = tibblify::tib_chr("GlPostMonth")
    ),
    tibblify::tib_unspecified(
      "PropertyHours"
    ),
    tibblify::tib_unspecified(
      "SpaceOptions"
    ),
    property_lease_terms = tibblify::tib_row(
      "LeaseTerms",
      .required = FALSE,
      lease_term = tibblify::tib_df(
        "LeaseTerm",
        .required = FALSE,
        lease_term_id = tibblify::tib_int("Id"),
        lease_term_name = tibblify::tib_chr("Name"),
        lease_term_months = tibblify::tib_int("TermMonths"),
        lease_term_is_prospect = tibblify::tib_lgl("IsProspect"),
        lease_term_is_renewal = tibblify::tib_lgl("IsRenewal"),
        tibblify::tib_row(
          "LeaseStartWindows",
          .required = FALSE,
          tibblify::tib_df(
            "LeaseStartWindow",
            .required = FALSE,
            lease_start_window_id = tibblify::tib_int("Id"),
            lease_start_window_start_date = tibblify::tib_chr("WindowStartDate"),
            lease_start_window_end_date = tibblify::tib_chr("WindowEndDate"),
          )
        )
      )
    ),
    tibblify::tib_unspecified("SpaceOption"),
    tibblify::tib_unspecified("Phone"),
    tibblify::tib_unspecified("CustomKeysData")
  )

  hold <- tibblify::tibblify(res_data, tspec, unspecified = "drop") |>
    tidyr::unnest(cols = c("property_address", "property_post_months", "property_lease_terms")) |>
    tidyr::unnest(cols = c("lease_term")) |>
    tidyr::unnest(cols = c("LeaseStartWindows")) |>
    tidyr::unnest(cols = c("LeaseStartWindow")) |>
    dplyr::select(-c("@attributes")) |>
    dplyr::select(
      property_id,
      property_name,
      property_type,
      property_website,
      property_email = email,
      property_description_short,
      property_description_long,
      is_disabled,
      is_featured,
      parent_property_id,
      year_built,
      address_street = address,
      address_city = city,
      address_state = state,
      address_zip = zip,
      address_country = country,
      property_ar_post_month = ar_post_month,
      property_ap_post_month = ap_post_month,
      property_gl_post_month = gl_post_month,
      lease_term_id,
      lease_term_name,
      lease_term_months,
      lease_term_is_prospect,
      lease_term_is_renewal,
      lease_start_window_id,
      lease_start_window_start_date,
      lease_start_window_end_date
    )

  hold_props <- hold |>
    dplyr::select(
      "property_id":"address_country",
      "property_ar_post_month":"property_gl_post_month"
    ) |>
    dplyr::distinct()

  if (!lease_terms) {
    return(hold_props)
  }

  hold_lease_terms <- hold |>
    dplyr::select(
      "property_id":"property_type",
      "lease_term_id":"lease_start_window_end_date"
    ) |>
    dplyr::distinct() |>
    dplyr::select(
      "property_id",
      "lease_term_id",
      "property_name",
      "lease_term_name",
      "property_type",
      "lease_term_months":"lease_start_window_end_date"
    )

  return(list(
    properties = hold_props,
    lease_terms = hold_lease_terms
  ))
}

#' Get Entrata Properties
#'
#' @description
#' Retrieves properties from the Entrata API using an EntrataAPI instance.
#' This function is designed to be used with the EntrataAPI class and provides
#' a more object-oriented approach to interacting with the Entrata API.
#'
#' @param api An instance of the `EntrataAPI` class.
#' @param property_ids A vector of property IDs to retrieve. If NULL, all properties will be returned.
#' @param property_lookup_codes A vector of property lookup codes to retrieve.
#' @param show_all_status Logical. Whether to return all properties regardless of status.
#' @param ... Additional parameters to pass to the underlying API request.
#'
#' @return A data frame with the retrieved property information.
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming you have an EntrataAPI instance called 'api'
#' properties <- get_properties(api)
#'
#' # Retrieve specific properties
#' specific_properties <- get_properties(api, property_ids = c("123", "456"))
#' }
get_properties <- function(api, property_ids = NULL, property_lookup_codes = NULL, show_all_status = FALSE, ...) {
  method_params <- list(
    propertyIds = if (!is.null(property_ids)) paste(property_ids, collapse = ",") else NULL,
    propertyLookupCode = property_lookup_codes,
    showAllStatus = as.character(as.integer(show_all_status))
  ) |>
    purrr::compact()

  res <- api$send_request(
    endpoint = "properties",
    method = "getProperties",
    method_params = method_params,
    enable_retry = TRUE,
    ...
  )

  parse_entrata_properties(res)
}

#' Parse Entrata Properties
#'
#' @description
#' Parses the response from the Entrata API's "getProperties" method.
#' This function is used internally by `get_properties()` to process
#' the raw API response into a usable data frame.
#'
#' @param res The [httr2::response()] object from the Entrata API.
#'
#' @return A data frame with the parsed property information.
#' @export
#'
#' @importFrom httr2 resp_body_json
#' @importFrom purrr pluck
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom tibble as_tibble
#' @importFrom janitor clean_names
#' @importFrom dplyr rename
parse_entrata_properties <- function(res) {
  httr2::resp_body_json(res) |>
    purrr::pluck("response", "result", "PhysicalProperty", "Property") |>
    jsonlite::toJSON() |>
    jsonlite::fromJSON(flatten = TRUE) |>
    tibble::as_tibble() |>
    janitor::clean_names() |>
    dplyr::rename(
      property_name = marketing_name,
      property_type = type,
      website = web_site,
      is_featured = is_featured_property,
      address_street = address_address,
      email = address_email,
      ar_post_month = post_months_ar_post_month,
      ap_post_month = post_months_ap_post_month,
      gl_post_month = post_months_gl_post_month,
      office_hours = property_hours_office_hours_office_hour,
      pool_hours = property_hours_pool_hours_pool_hour,
      space_options = space_options_space_option,
      lease_terms = lease_terms_lease_term,
      phone = phone_phone_number,
      phone_description = phone_phone_description
    )
}
