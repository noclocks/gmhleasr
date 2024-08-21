
#  ------------------------------------------------------------------------
#
# Title : Schemas Data Preparation
#    By : Jimmy Briggs
#  Date : 2024-08-16
#
#  ------------------------------------------------------------------------


# config schema -----------------------------------------------------------


# db config ---------------------------------------------------------------

db_config_schema <- list(
    host = "",
    port = 5432,
    dbname = "",
    user = "",
    password = "",
    url = "",
    sslmode = ""
)

db_config_schema |> jsonlite::toJSON(auto_unbox = TRUE) |>



jsonlite::toJSON(db_config_schema, pretty = TRUE) |>
  cat(file = "data-raw/meta/schemas/config.db.schema.json")

