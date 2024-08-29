

# internal ----------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom memoise memoise timeout
#' @importFrom cachem cache_mem
#' @importFrom rlang ns_env
#' @importFrom glue glue
#' @importFrom cli cli_alert_info
.cache_function <- function(
  function_name,
  pkg,
  duration = 86400,
  omit_args = c(),
  cache = cachem::cache_mem(),
  rename_prefix = "mem_",
  quiet = TRUE,
  ...
) {

  fn <- base::get(function_name, envir = rlang::ns_env(pkg))

  mem_fn <- memoise::memoise(
    fn,
    ~ memoise::timeout(duration),
    omit_args = omit_args,
    cache = cache
  )

  mem_function_name <- glue::glue("{rename_prefix}{function_name}")

  assign(mem_function_name, mem_fn, envir = rlang::ns_env(pkg))

  if (!quiet) {
    cli::cli_alert_info("Created a cached function for {.field {function_name}} as {.field {mem_function_name}}.")
    cli::cli_alert_info("The cache will expire in {.field {duration}} seconds.")
  }

  return(invisible(TRUE))
}

# onLoad ------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom purrr walk
.onLoad <- function(libname, pkgname) {

  # cache functions ---------------------------------------------------------
  c(
    "get_entrata_reports_list",
    "get_entrata_report_info",
    "get_latest_report_version",
    "get_property_ids_filter_param"
  ) |>
    purrr::walk(.cache_function, pkg = pkgname, quiet = FALSE)

}
