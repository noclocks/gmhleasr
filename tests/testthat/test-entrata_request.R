#  ------------------------------------------------------------------------
#
# Title : Entrata Request Tests
#    By : Jimmy Briggs
#  Date : 2024-08-28
#
#  ------------------------------------------------------------------------

test_that("entrata function creates a valid request object", {
  req <- entrata(
    endpoint = "status",
    method = "getStatus",
    config = cfg
  )

  expect_s3_class(req, "httr2_request")
  expect_equal(req$url, "https://gmhcommunities.entrata.com/api/v1/status")
  expect_equal(req$method, "POST")
  expect_true("Authorization" %in% names(req$headers))

  body_data <- req$body$data
  expect_equal(body_data$method$name, "getStatus")
  expect_equal(body_data$method$version, "r1")
  expect_equal(body_data$requestId, 15)
})

test_that("entrata function handles different endpoints and methods", {
  req1 <- entrata(endpoint = "status", method = "getStatus", config = cfg)
  req2 <- entrata(endpoint = "properties", method = "getProperties", config = cfg)

  expect_match(req1$url, "/status$")
  expect_match(req2$url, "/properties$")

  body1 <- req1$body$data
  body2 <- req2$body$data

  expect_equal(body1$method$name, "getStatus")
  expect_equal(body2$method$name, "getProperties")
})

test_that("entrata function respects custom configurations", {
  custom_cfg <- list(
    username = "custom_user",
    password = "custom_pass",
    base_url = "https://custom.entrata.com"
  )

  req <- entrata(endpoint = "status", method = "getStatus", config = custom_cfg)

  expect_match(req$url, "^https://custom.entrata.com")
  expect_match(req$headers$Authorization, "^Basic Y3VzdG9tX3VzZXI6Y3VzdG9tX3Bhc3M=")
})

test_that("entrata function respects dry_run parameter", {
  expect_message(
    entrata(endpoint = "status", method = "getStatus", dry_run = TRUE, config = cfg),
    "Dry Run: Request will not be performed"
  )
})

test_that("entrata function handles timeout parameter", {
  req <- entrata(endpoint = "status", method = "getStatus", timeout = 30, config = cfg)
  expect_equal(req$options$timeout_ms / 1000, 30)
})

test_that("entrata function respects enable_retry parameter", {
  req <- entrata(endpoint = "status", method = "getStatus", enable_retry = TRUE, config = cfg)
  expected_names <- c("retry_max_tries", "retry_max_wait", "retry_is_transient", "retry_backoff")
  expect_true(all(expected_names %in% names(req$policies)))
  expect_true(req$policies$retry_max_tries > 0)
  expect_true(req$policies$retry_max_wait > 0)
  expect_identical(typeof(req$policies$retry_is_transient), "closure")
  expect_identical(typeof(req$policies$retry_backoff), "closure")
})

