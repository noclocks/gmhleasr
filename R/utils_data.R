#  ------------------------------------------------------------------------
#
# Title : Data Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-29
#
#  ------------------------------------------------------------------------


# parsing -----------------------------------------------------------------

#' Reparse a Data Frame
#'
#' @description
#' `parse_guess_all()` is a function to reparse a data frame by guessing the
#' data types of each column.
#'
#' @param df data frame
#'
#' @return a data frame with re-parsed data types
#'
#' @export
#'
#' @importFrom purrr modify
#' @importFrom readr parse_guess
#'
#' @examples
#' my_df <- tibble::tibble(a = "1", b = "a", c = 5)
#' str(my_df)
#' # tibble [1 × 3] (S3: tbl_df/tbl/data.frame)
#' # $ a: chr "1"
#' # $ b: chr "a"
#' # $ c: num 5
#'
#' parsed_df <- parse_guess_all(my_df)
#' str(parsed_df)
#' # tibble [1 × 3] (S3: tbl_df/tbl/data.frame)
#' # $ a: num 1
#' # $ b: chr "a"
#' # $ c: num 5
parse_guess_all <- function(df) {
  purrr::modify(
    df,
    function(x) {
      x |>
        as.character() |>
        readr::parse_guess()
    }
  )
}
