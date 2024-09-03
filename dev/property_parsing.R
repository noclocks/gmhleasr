library(unnest)
library(httr2)

req_properties <- entrata(
  endpoint = "properties",
  method = "getProperties",
  method_version = NULL,
  method_params = list(
    showAllStatus = "1"
  ),
  perform = TRUE
)

resp_properties <- req_properties |>
  httr2::resp_body_json() |>
  purrr::pluck(
    "response",
    "result",
    "PhysicalProperty",
    "Property"
  )

property_names <- purrr::map_chr(
  resp_properties,
  purrr::pluck,
  "MarketingName"
)

names(resp_properties) <- property_names

library(tibblify)

property_tspecs <- purrr::map(
  resp_properties,
  tibblify::guess_tspec,
  simplify_list = TRUE,
  empty_list_unspecified = TRUE
) |>
  rlang::set_names(property_names)

properties_parsed <- purrr::map2(
  resp_properties,
  property_tspecs,
  tibblify::tibblify,
  unspecified = "list",
  .progress = TRUE
)

property_addresses <- purrr::map(
  properties_parsed,
  purrr::pluck,
  "Address"
) |>
  purrr::map(
    tibblify::tibblify,
    unspecified = "list"
  )

