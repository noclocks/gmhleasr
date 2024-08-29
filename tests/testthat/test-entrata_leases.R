# httptest2::capture_requests({
#
#   test_prop_id_1 <- "739084"
#   test_prop_id_2 <- "641240"
#
#   res_leases <- entrata(
#     endpoint = "leases",
#     method = "getLeases",
#     method_params = list("propertyId" = test_prop_id_1),
#     method_version = "r2",
#     perform = TRUE
#   )
#
#   entrata_leases(property_id = test_prop_id_2)
# })

httptest2::with_mock_api({
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

  test_that("entrata_leases function works correctly", {
    result <- entrata_leases(property_id = "641240")
    expect_s3_class(result, "data.frame")
    expect_true("lease_id" %in% names(result))
    expect_true("move_in_date" %in% names(result))
    expect_true("customer_name" %in% names(result))
  })
})
