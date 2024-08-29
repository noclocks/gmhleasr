# httptest2::start_capturing(simplify = TRUE)
#
# test_prop_ids <- c("739084")
#
# prop_ids <- paste(test_prop_ids, collapse = ",")
#
# res <- entrata(
#   endpoint = "leases",
#   method = "getLeases",
#   method_params = list("propertyId" = prop_ids),
#   method_version = "r2",
#   perform = TRUE
# )
#
# httptest2::stop_capturing()

httptest2::with_mock_dir("leases", {
  test_that("Can call leases endpoint getLeases method", {
    test_prop_id <- "739084"
    res <- entrata(
      endpoint = "leases",
      method = "getLeases",
      method_params = list("propertyId" = test_prop_id),
      method_version = "r2",
      perform = TRUE
    )
    expect_equal(res$status_code, 200)
  })
})

httptest2::with_mock_dir("leases", {
  test_that("entrata_leases function works correctly", {
    result <- entrata_leases(property_id = "641240")
    expect_s3_class(result, "data.frame")
    expect_true("lease_id" %in% names(result))
    expect_true("move_in_date" %in% names(result))
    expect_true("customer_name" %in% names(result))
  })
})
