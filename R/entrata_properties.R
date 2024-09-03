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
#' @param property_lookup_codes Character string with a "Property Lookup Code"
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
    ...) {
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

  res_content <- httr2::resp_body_json(res)

  res_data <- res_content |>
    purrr::pluck(
      "response",
      "result",
      "PhysicalProperty",
      "Property"
    )

  # parse results -----------------------------------------------------------
  res_data |> parse_property_res_data()
}

#' @describeIn entrata_properties Parse Entrata Properties Response Data
#'
#' @description
#' This function parses the response from the Entrata API's "getProperties" method.
#'
#' @param res_data Response data from the Entrata API's "getProperties" method.
#'
#' @return A tibble with the property information
#'
#' @export
#'
#' @importFrom dplyr select
#' @importFrom tibblify tspec_df tib_int tib_chr tib_row tib_unspecified tib_df tib_lgl tibblify
#' @importFrom tidyr unnest
parse_property_res_data <- function(res_data) {
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

  tibblify::tibblify(res_data, tspec, unspecified = "drop") |>
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
}



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


#' @importFrom httr2 resp_body_json
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom tibble as_tibble
#' @importFrom janitor clean_names
#' @importFrom dplyr rename
# parse_properties_response <- function(res) {
#
#   out <- httr2::resp_body_json(res) |>
#     purrr::pluck("response", "result", "PhysicalProperty", "Property") |>
#     jsonlite::toJSON() |>
#     jsonlite::fromJSON(flatten = TRUE) |>
#     tibble::as_tibble() |>
#     janitor::clean_names() |>
#     dplyr::rename(
#       property_name = marketing_name,
#       property_type = type,
#       website = web_site,
#       is_featured = is_featured_property,
#       address_street = address_address,
#       email = address_email,
#       ar_post_month = post_months_ar_post_month,
#       ap_post_month = post_months_ap_post_month,
#       gl_post_month = post_months_gl_post_month,
#       office_hours = property_hours_office_hours_office_hour,
#       pool_hours = property_hours_pool_hours_pool_hour,
#       space_options = space_options_space_option,
#       lease_terms = lease_terms_lease_term,
#       phone = phone_phone_number,
#       phone_description = phone_phone_description
#     )
#
#   return(out)
#
# }


# res_data_tbl <- tibble::tibble(
#   PropertyID = purrr::map_int(res_data, "PropertyID"),
#   MarketingName = purrr::map_chr(res_data, "MarketingName"),
#   Type = purrr::map_chr(res_data, "Type"),
#   webSite = purrr::map_chr(res_data, "webSite"),
#   Address = purrr::map(res_data, "Address"),
#   Addresses = purrr::map(res_data, "Addresses"),
#   PostMonths = purrr::map(res_data, "PostMonths"),
#   PropertyHours = purrr::map(res_data, "PropertyHours"),
#   SpaceOptions = purrr::map(res_data, "SpaceOptions"),
#   LeaseTerms = purrr::map(res_data, "LeaseTerms")
# ) |>
#   tidyr::unnest_wider(
#     "Address",
#     names_sep = "_"
#   ) |>
#   dplyr::select(
#     -c("Address_@attributes")
#   ) |>
#   tidyr::unnest_wider(
#     "PropertyHours",
#     names_sep = "_"
#   )
#
# res_data_addresses_tbl <- res_data_tbl |>
#   dplyr::select(c("PropertyID", "Addresses")) |>
#   tidyr::unnest_longer(
#     "Addresses"
#   ) |>
#   tidyr::unnest_wider(
#     "Addresses",
#     names_sep = "_"
#   )
#
# res_data_post_months_tbl <- res_data_tbl |>
#   dplyr::select(c("PropertyID", "PostMonths")) |>
#   tidyr::unnest_wider(
#     "PostMonths",
#     names_sep = "_"
#   )
#
# res_data_office_hours_tbl <- res_data_tbl |>
#   dplyr::select(c("PropertyID", "PropertyHours_OfficeHours")) |>
#   tidyr::unnest_longer(
#     "PropertyHours_OfficeHours"
#   ) |>
#   tidyr::unnest_wider(
#     "PropertyHours_OfficeHours",
#     names_sep = "_"
#   )
#
# if ("PropertyHours_PoolHours" %in% colnames(res_data_tbl)) {
#   res_data_pool_hours_tbl <- res_data_tbl |>
#     dplyr::select("PropertyID", "PropertyHours_PoolHours") |>
#     tidyr::unnest_longer("PropertyHours_PoolHours") |>
#     tidyr::unnest_wider("PropertyHours_PoolHours", names_sep = "_")
# }
#
# res_data_lease_terms_tbl <- res_data_tbl |>
#   dplyr::select("PropertyID", "LeaseTerms") |>
#   tidyr::unnest_longer("LeaseTerms") |>
#   tidyr::unnest_wider("LeaseTerms", names_sep = "_")
#
# # Now, drop the unnested list columns from the main tibble
# properties_tbl <- properties_tbl |>
#   select(-Addresses, -PropertyHours_OfficeHours,
#          -PropertyHours_PoolHours, -LeaseTerms)
#
# res_data_tbl_props <- res_data_tbl
#
# prop_ids <- purrr::map_int(
#   res_data,
#   purrr::pluck,
#   "PropertyID"
# )
#
# prop_names <- purrr::map_chr(
#   res_data,
#   purrr::pluck,
#   "MarketingName"
# )
#
# prop_types <- purrr::map_chr(
#   res_data,
#   purrr::pluck,
#   "Type"
# )
#
# prop_sites <- purrr::map_chr(
#   res_data,
#   purrr::pluck,
#   "webSite"
# )
#
# prop_addresses <- purrr::map(
#   res_data,
#   purrr::pluck,
#   "Address"
# )
#
# prop_addresses_address <- prop_addresses |>
#   purrr::map_chr(
#     purrr::pluck,
#     "Address"
#   )
#
# prop_addresses_city <- prop_addresses |>
#   purrr::map_chr(
#     purrr::pluck,
#     "City"
#   )
#
# prop_addresses_state <- prop_addresses |>
#   purrr::map_chr(
#     purrr::pluck,
#     "State"
#   )
#
# prop_addresses_zip <- prop_addresses |>
#   purrr::map_chr(
#     purrr::pluck,
#     "PostalCode"
#   )
#
# prop_emails <- prop_addresses |>
#   purrr::map_chr(
#     purrr::pluck,
#     "Email"
#   )
#
# prop_post_months <- purrr::map(
#   res_data,
#   purrr::pluck,
#   "PostMonths"
# ) |>
#   rlang::set_names(prop_names)
#
# prop_hours <- purrr::map(
#   res_data,
#   purrr::pluck,
#   "PropertyHours"
# ) |>
#   rlang::set_names(prop_names)
