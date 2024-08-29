#  ------------------------------------------------------------------------
#
# Title : Schema (JSON/YAML) Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-16
#
#  ------------------------------------------------------------------------


#' Schema (JSON/YAML) Utilities
#'
#' @name utils_schema
#'
#' @description
#' - `write_json_schema()`: Write JSON schema to file
#' - `yaml_to_json()`: Convert YAML to JSON
#' - `yaml_to_list()`: Convert YAML to list
#'
#' @param schema JSON schema
#' @param path File path
#'
#' @return
#' - `write_json_schema()`: Invisible file path
#' - `yaml_to_json()`: JSON string
#' - `yaml_to_list()`: List
NULL


#' @rdname utils_schema
#' @export
#' @importFrom jsonlite toJSON prettify
#' @importFrom cli cli_alert_warning
write_json_schema <- function(schema, path) {
  json <- jsonlite::toJSON(schema, auto_unbox = TRUE) |>
    jsonlite::prettify()

  if (file.exists(path)) {
    cli::cli_alert_warning("Warning: File at {.path {path}} already exists. Overwriting file.")
    file.remove(path)
  }

  write(json, file = path)

  return(invisible(path))
}

#' @rdname utils_schema
#' @export
#' @importFrom jsonlite toJSON prettify
yaml_to_json <- function(yaml) {
  yaml <- yaml_to_list(yaml)

  json <- jsonlite::toJSON(yaml, auto_unbox = TRUE) |>
    jsonlite::prettify()

  return(json)
}

#' @rdname utils_schema
#' @export
#' @importFrom ymlthis is_yml
yaml_to_list <- function(yaml) {
  if (!ymlthis::is_yml(yaml)) {
    return(yaml)
  }
}
