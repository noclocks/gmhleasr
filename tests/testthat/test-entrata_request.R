context("Entrata API Request")

# Mock configuration for testing
mock_config <- create_entrata_config()

test_that("entrata function creates a valid request object", {
  req <- entrata(
    endpoint = "properties",
    method = "getProperties",
    config = mock_config,
    perform = FALSE
  )

  expect_s3_class(req, "httr2_request")
  expect_equal(req$url, paste0(mock_config$base_url, "/api/v1/properties"))
  expect_equal(req$method, "POST")
  expect_true("Authorization" %in% names(req$headers))
  expect_equal(req$headers$`Content-Type`, "application/json; charset=UTF-8")
})

test_that("entrata function handles different endpoints and methods", {
  req1 <- entrata(endpoint = "leases", method = "getLeases", config = mock_config, perform = FALSE)
  req2 <- entrata(endpoint = "reports", method = "getReportList", config = mock_config, perform = FALSE)

  expect_equal(req1$url, paste0(mock_config$base_url, "/api/v1/leases"))
  expect_equal(req2$url, paste0(mock_config$base_url, "/api/v1/reports"))
})

test_that("entrata function handles method parameters correctly", {
  params <- list(propertyId = 12345, startDate = "2023-01-01")
  req <- entrata(
    endpoint = "leases",
    method = "getLeases",
    method_params = params,
    config = mock_config,
    perform = FALSE
  )

  body <- jsonlite::fromJSON(req$body)
  expect_equal(body$method$params$propertyId, 12345)
  expect_equal(body$method$params$startDate, "2023-01-01")
})

# Note: The following tests require mocking HTTP responses and are more complex.
# They are included as examples and may need to be adjusted based on your specific mocking setup.

test_that("entrata function handles successful API responses", {
  skip("Requires mocking HTTP responses")
  # Example using httptest2 package
  # httptest2::with_mock_api({
  #   response <- entrata(endpoint = "properties", method = "getProperties", config = mock_config, perform = TRUE)
  #   expect_s3_class(response, "httr2_response")
  #   expect_equal(httr2::resp_status(response), 200)
  # })
})

test_that("entrata function handles API errors correctly", {
  skip("Requires mocking HTTP responses")
  # Example using httptest2 package
  # httptest2::with_mock_api({
  #   expect_error(
  #     entrata(endpoint = "invalid", method = "invalid", config = mock_config, perform = TRUE),
  #     "API request failed"
  #   )
  # })
})

test_that("entrata function uses caching when enabled", {
  skip("Requires setting up a temporary cache directory")
  # This test would involve setting up a temporary cache directory,
  # making multiple requests, and verifying that subsequent requests
  # return cached responses.
})
