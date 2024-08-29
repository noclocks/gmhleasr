test_that("EntrataAPI class works as expected", {
  cfg <- list(
    username = "testuser",
    password = "testpass",
    base_url = "https://api.entrata.com"
  )

  api <- EntrataAPI$new(config = cfg)
  expect_s3_class(api, "EntrataAPI")
  expect_equal(api$config$username, "testuser")
  expect_equal(api$config$password, "testpass")
  expect_equal(api$config$base_url, "https://api.entrata.com")
})
