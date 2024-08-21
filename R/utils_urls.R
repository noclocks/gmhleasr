#  ------------------------------------------------------------------------
#
# Title : URL Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------



# get_page_from_url -------------------------------------------------------

get_page_from_url <- function(url, session = shiny::getDefaultReactiveDomain()) {
  utils::URLdecode(
    sub(
      "#",
      "",
      session$clientData$url_hash
    )
  )
}
