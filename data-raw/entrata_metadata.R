
#  ------------------------------------------------------------------------
#
# Title : Entrata API Metadata Preparation
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------


# sources -----------------------------------------------------------------

source("data-raw/entrata/entrata_req_res.R")
source("data-raw/entrata/entrata_request_endpoints.R")
source("data-raw/entrata/entrata_request_endpoint_methods.R")
source("data-raw/entrata/entrata_request_endpoint_method_parameters.R")

# derive endpoint methods merged ------------------------------------------

entrata_api_request_endpoint_methods <- tibble::enframe(
  entrata_api_request_methods,
  name = "endpoint",
  value = "method"
) |>
  tidyr::unnest(cols = c(method)) |>
  dplyr::left_join(
    y = tibble::enframe(
      important_entrata_request_endpoint_methods,
      name = "endpoint",
      value = "method"
    ) |>
      tidyr::unnest(cols = c(method)) |>
      dplyr::mutate(
        important = TRUE
      ),
    by = c("endpoint", "method")
  ) |>
  dplyr::mutate(
    important = dplyr::coalesce(important, FALSE)
  ) |>
  dplyr::arrange(dplyr::desc(important))


# derive endpoint method parameters table ---------------------------------

entrata_api_request_endpoint_method_parameters_tbl <- entrata_api_request_parameters |>
  tibble::enframe(name = "endpoint", value = "methods") |>
  tidyr::unnest_longer(methods) |>
  dplyr::mutate(method = names(methods)) |>
  tidyr::unnest_longer(methods, values_to = "parameters") |>
  dplyr::mutate(parameter = names(parameters)) |>
  tidyr::unnest_wider(parameters, names_sep = "_") |>
  dplyr::mutate(multiple = dplyr::coalesce(parameters_multiple, FALSE)) |>
  dplyr::select(
    endpoint,
    method,
    parameter,
    type = parameters_type,
    required = parameters_required,
    multiple,
    description = parameters_description
  ) |>
  dplyr::arrange(endpoint, method, dplyr::desc(required), parameter)


# derive merged metadata table --------------------------------------------

# merge into single tibble with endpoint, method, method param information
entrata_api_request_endpoint_method_parameters <- entrata_api_request_parameters_tbl |>
  dplyr::left_join(
    y = entrata_api_request_endpoint_methods,
    by = c("endpoint", "method")
  ) |>
  dplyr::select(
    endpoint,
    method,
    parameter,
    type,
    required,
    multiple,
    description
  ) |>
  dplyr::arrange(endpoint, method, dplyr::desc(required))

# save metadata -----------------------------------------------------------
usethis::use_data(
  entrata_api_request_endpoints,
  entrata_api_request_methods,
  entrata_api_request_parameters,
  entrata_api_request_endpoint_methods,
  entrata_api_request_endpoint_method_parameters,
  entrata_api_request_parameters_tbl,
  entrata_default_req_body,
  entrata_default_resp_body,
  important_entrata_request_endpoint_methods,
  internal = TRUE,
  overwrite = TRUE
)
