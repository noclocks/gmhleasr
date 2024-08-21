
#  ------------------------------------------------------------------------
#
# Title : Text Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

# Helper functions
# strip_phone_number <- function(phone) {
#   gsub("[^0-9]", "", phone)
# }
#
# display_phone_number <- function(phone) {
#   stripped <- strip_phone_number(phone)
#   if (nchar(stripped) == 10) {
#     paste0("(", substr(stripped, 1, 3), ") ", substr(stripped, 4, 6), "-", substr(stripped, 7, 10))
#   } else {
#     phone
#   }
# }

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
