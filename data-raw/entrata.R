#  ------------------------------------------------------------------------
#
# Title : Entrata Data Preparation
#    By : Jimmy Briggs
#  Date : 2024-08-17
#
#  ------------------------------------------------------------------------

source("data-raw/entrata/entrata_req_res.R")
source("data-raw/entrata/entrata_endpoints.R")
source("data-raw/entrata/entrata_properties.R")

# save --------------------------------------------------------------------

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
