
#  ------------------------------------------------------------------------
#
# Title : Entrata Properties
#    By : Jimmy Briggs
#  Date : 2024-08-28
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------

#' @describeIn entrata_properties Parse Entrata Properties Response
#'
#' @description
#' This function parses the response from the Entrata API's "getProperties" method.
#'
#' @param res A response object from the Entrata API
#'
#' @return A tibble with the property information
#'
#' @export
#'
#' @importFrom httr2 resp_body_json
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom tibble as_tibble
#' @importFrom janitor clean_names
#' @importFrom dplyr rename
parse_properties_response <- function(res) {

  out <- httr2::resp_body_json(res) |>
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

  return(out)

}


# exported ----------------------------------------------------------------

#' Entrata API Properties Endpoint
#'
#' @name entrata_properties
#'
#' @description
#' This function retrieves properties from the Entrata API.
#'
#' @param property_ids Character Vector of Property IDs to include in the request
#'   body parameters. If `NULL`, all properties will be returned. Default is
#'   `NULL`.
#' @param property_lookup_code Character string with a "Property Lookup Code"
#'   to include in the request's body. Default is `NULL`.
#' @param show_all_status Logical: if `TRUE` will return all properties, regardless
#'   of status. Default is `FALSE`.
#'
#' @inheritDotParams entrata
#'
#' @seealso [entrata()]
#' @seealso https://gmhcommunities.entrata.com/api/v1/documentation/getProperties
#'
#' @return A tibble with the property information
#'
#' @export
#'
#' @example examples/ex_entrata_properties.R
#'
#' @importFrom httr2 req_perform
#' @importFrom purrr compact
entrata_properties <- function(
    property_ids = c(NULL),
    property_lookup_codes = NULL,
    show_all_status = FALSE,
    ...
) {

  prop_ids <- if (!is.null(property_ids)) {
    paste(property_ids, collapse = ",")
  } else {
    NULL
  }

  # body params -------------------------------------------------------------
  method_params <- list(
    propertyIds = prop_ids,
    propertyLookupCode = property_lookup_codes,
    showAllStatus = as.integer(show_all_status)
  ) |>
    purrr::compact()

  # build & perform request ------------------------------------------------
  res <- entrata(
    endpoint = "properties",
    method = "getProperties",
    method_params = method_params,
    perform = TRUE,
    ...
  )

  # parse results -----------------------------------------------------------
  res |> parse_properties_response()

}

