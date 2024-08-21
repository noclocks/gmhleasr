#  ------------------------------------------------------------------------
#
# Title : Schema (JSON/YAML) Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-16
#
#  ------------------------------------------------------------------------


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

yaml_to_json <- function(yaml) {
  yaml <- yaml_to_list(yaml)

  json <- jsonlite::toJSON(yaml, auto_unbox = TRUE) |>
    jsonlite::prettify()

  return(json)
}

yaml_to_list <- function(yaml) {
  if (!ymlthis:::is_yml(yaml)) {
    return(yaml)
  }
}
