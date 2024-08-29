#' Get Entrata Properties
#'
#' @description
#' Retrieves properties from the Entrata API.
#'
#' @param api An instance of the `EntrataAPI` class.
#' @param property_ids A vector of property IDs to retrieve.
#' @param property_lookup_codes A vector of property lookup codes to retrieve.
#' @param show_all_status Logical. Whether to return all properties regardless of status.
#' @param ... Additional parameters to pass to the underlying API request.
#'
#' @return A data frame with the retrieved property information.
#' @export
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
#'
#' @param res The [httr2::response()] object from the Entrata API.
#'
#' @return A data frame with the parsed property information.
#' @export
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
