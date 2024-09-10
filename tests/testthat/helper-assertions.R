
#  ------------------------------------------------------------------------
#
# Title : Assertion/Expectation Testing Helpers
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

expect_dbi_conn <- function(conn) {
  testthat::expect_s3_class(conn, "DBIConnection")
}

expect_pool_conn <- function(conn) {
  testthat::expect_s3_class(conn, "Pool")
}

expect_db_conn <- function(conn) {
  expect_dbi_conn(conn) || expect_pool_conn(conn)
}

expect_entrata_api_response <- function(resp) {
  # expect a list with the structure of entrata's api response:
  # list(status_code = "200", headers = list(`Content-Type` = "application/json"), ...), body = ...))

}
