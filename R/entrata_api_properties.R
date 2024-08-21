#  ------------------------------------------------------------------------
#
# Title : Entrata Properties Endpoint Requests
#    By : Jimmy Briggs
#  Date : 2024-08-17
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------




# exportetd ---------------------------------------------------------------

entrata_api_request_properties <- function(
    property_ids = c(NULL),
    property_lookup_codes = NULL,
    show_all_status = FALSE,
    ...) {
  # validate parameters -----------------------------------------------------
  prop_ids <- if (is.null(property_ids)) {
    paste()
  }
}
