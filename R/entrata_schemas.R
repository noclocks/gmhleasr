#
# #  ------------------------------------------------------------------------
# #
# # Title : Entrata API Schemas
# #    By : Jimmy Briggs
# #  Date : 2024-08-28
# #
# #  ------------------------------------------------------------------------
#
# # internal ----------------------------------------------------------------
#
# derive_req_body <- function(method, method_params, method_version = "r1") {
#
#   list(
#     auth = list(
#       type = "basic"
#     ),
#     requestId = 15,
#     method = list(
#       name = method,
#       version = method_version,
#       params = method_params
#     )
#   ) |>
#     purrr::compact()
# }
#
# derive_req_body(
#   "getProperties",
#   list(
#     propertyIds = as.character(c("739084")),
#     propertyLookupCode = as.character(NULL),
#     showAllStatus = as.character(as.integer(FALSE))
#   ),
#   "r1"
# ) |>
#   jsonlite::toJSON(auto_unbox = TRUE, pretty = TRUE) |>
#   validator(verbose = TRUE, greed)
#
# get_json_schema <- function(endpoint, method, type = c("request", "response")) {
#
#   type <- match.arg(type)
#
#   root_path <- system.file("extdata/schemas", package = "gmhleasr")
#   endpoint_path <- fs::path(root_path, endpoint)
#   schema_file <- fs::path(endpoint_path, paste0(method, ".", type, ".schema.json"))
#   schema <- readLines(schema_file) |>
#     paste(collapse = "\n")
#
#   return(schema)
#
# }
#
# validate_request_body <- function(
#   req_body,
#   endpoint,
#   schema,
#   ...
# ) {
#
#   json_schema <- .get_json_schema(endpoint, method, "request")
#
#   json_schema2 <- tidyjson::json_schema(req_body)
#
#   validator <- jsonvalidate::json_validator(schema = json_schema, engine = "ajv")
#   validator <- purrr::partial(validator, verbose = TRUE, greedy = TRUE)
#
#   req_body_json <- req_body |>
#     jsonlite::toJSON(auto_unbox = TRUE, pretty = TRUE)
#
#   validator(json = req_body_json)
#
# }
