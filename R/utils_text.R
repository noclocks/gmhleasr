#  ------------------------------------------------------------------------
#
# Title : Text Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------


# trim whitespace ---------------------------------------------------------

#' Trim Whitespace
#'
#' @name trim_ws
#'
#' @description `trim_ws()` is an efficient function to trim leading and trailing
#' white space from character vectors or strings.
#'
#' @param str Character vector, or a data frame.
#' @param ... Currently not used.
#'
#' @return Character vector, where trailing and leading white spaces are removed.
#'
#' @export
#'
#' @examples
#' trim_ws("  no space!  ")
trim_ws <- function(str, ...) {
  UseMethod("trim_ws")
}

#' @export
trim_ws.default <- function(str, ...) {
  UseMethod("trim_ws.character")
}

#' @rdname trim_ws
#' @export
trim_ws.character <- function(x, ...) {
  gsub("^\\s+|\\s+$", "", x, perl = TRUE, useBytes = TRUE)
}

#' @rdname trim_ws
#' @export
trim_ws.data.frame <- function(x, character_only = TRUE, ...) {
  if (character_only) {
    chars <- which(vapply(x, is.character, FUN.VALUE = logical(1L)))
  } else {
    chars <- seq_len(ncol(x))
  }
  if (length(chars)) {
    x[chars] <- lapply(x[chars], trim_ws)
  }
  x
}

#' @rdname trim_ws
#' @export
trim_ws.list <- function(x, character_only = TRUE, ...) {
  if (character_only) {
    chars <- which(vapply(x, is.character, FUN.VALUE = logical(1L)))
  } else {
    chars <- seq_len(length(x))
  }
  if (length(chars)) {
    x[chars] <- lapply(x[chars], trim_ws)
  }
  x
}



# compact -----------------------------------------------------------------





#' Strip Phone Number
#'
#' @description
#' Strip phone number of all non-numeric characters and add country code.
#' Used to format phone numbers properly for use with the `tel://` `HTML`
#' attribute's protocol.
#'
#' @param phone String representing a phone number.
#'
#' @return Formatted string of the phone number.
#'
#' @export
#'
#' @examples
#' strip_phone_number("(555) 555-5555")
#' strip_phone_number("555-555-5555")
#' strip_phone_number("555.555.5555")
strip_phone_number <- function(phone) {
  phone <- gsub("-", "", phone)
  phone <- gsub("\\s", "", phone)
  phone <- gsub("\\(", "", phone)
  phone <- gsub("\\)", "", phone)
  phone <- gsub("\\.", "", phone)
  phone <- gsub(" ", "", phone)
  phone <- paste0("+1", phone)
  phone
}


#' Displau Phone Number
#'
#' @description
#' Display phone number in a formatted string.
#'
#' @param phone String representing a phone number.
#'
#' @return Formatted string of the phone number.
#'
#' @export
#'
#' @examples
#' display_phone_number("5555555555")
display_phone_number <- function(phone) {
  phone <- gsub("-", "", phone)
  phone <- gsub("\\s", "", phone)
  phone <- gsub("\\(", "", phone)
  phone <- gsub("\\)", "", phone)
  phone <- gsub("\\.", "", phone)
  phone <- gsub(" ", "", phone)
  phone <- paste0("(", substr(phone, 1, 3), ") ", substr(phone, 4, 6), "-", substr(phone, 7, 10))
  phone
}
