
#  ------------------------------------------------------------------------
#
# Title : Caching Utilities
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

#' Clear Cache
#'
#' @description
#' Clear the cache and remove all cached files.
#'
#' @param cache_dir The directory path to the cache.
#'
#' @details
#' This function will remove all files and directories under the specified cache directory.
#'
#' @return NULL
#'
#' @export
clear_cache <- function(
  cache_dir = getOption("gmh.cache_dir", default = rappdirs::user_cache_dir("gmhleasr"))
) {

  unlink(cache_dir, recursive = TRUE, force = TRUE)

  cli::cli_alert_success(
    c(
      "Successfully cleared the cache and removed all cached files under: {.path {cache_dir}}."
    )
  )

  # memoise::forget(get_memoise_cache)

}

