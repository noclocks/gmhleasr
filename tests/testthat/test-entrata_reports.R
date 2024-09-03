# httptest2::capture_requests({
#   reports <- get_entrata_reports_list()
#   report_info <- get_entrata_report_info("pre_lease")
#   latest_version <- get_latest_report_version("pre_lease")
# })

httptest2::with_mock_api({
  test_that("get_entrata_reports_list() works", {
    hold <- get_entrata_reports_list()
    expect_s3_class(hold, "tbl_df")
    expect_equal(nrow(hold), 54)
    expect_equal(ncol(hold), 4)
  })

  test_that("get_entrata_report_info() works", {
    hold <- get_entrata_report_info("pre_lease")
    expect_true(is.list(hold))
    expect_equal(names(hold), c("report_name", "report_description", "report_filters"))
    expect_equal(hold$report_name, "pre_lease")
    expect_s3_class(hold$report_filters, "tbl_df")
    expect_equal(nrow(hold$report_filters), 16)
    expect_equal(ncol(hold$report_filters), 5)
  })

  test_that("get_latest_report_version() works", {
    hold <- get_latest_report_version("pre_lease")
    expect_true(is.character(hold))
    expect_equal(length(hold), 1)
  })
})
