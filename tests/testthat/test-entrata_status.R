httptest2::with_mock_dir(
  dir = "status",
  test_that("Can ping API status endpoint", {
    res <- entrata(
      endpoint = "status",
      method = "getStatus",
      perform = TRUE,
      config = cfg
    )
    expect_equal(res$status_code, 200)
  })
)
