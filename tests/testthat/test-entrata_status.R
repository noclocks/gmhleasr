httptest2::capture_requests({
  cfg <- config::get("entrata")

  res <- entrata(
    endpoint = "status",
    method = "getStatus",
    perform = TRUE,
    config = cfg
  )
})

httptest2::with_mock_api({
  test_that("Can ping API status endpoint", {
    res <- entrata(
      endpoint = "status",
      method = "getStatus",
      perform = TRUE,
      config = cfg
    )
    expect_equal(res$status_code, 200)
  })
})
