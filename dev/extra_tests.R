# Mock the API response
mock_entrata_api_response <- function(endpoint, method, method_params) {
  if (endpoint == "reports" && method == "getReportList") {
    return(list(
      response = list(
        result = list(
          reports = list(
            report = list(
              list(
                id = 1,
                reportName = "Pre-Lease Report",
                systemName = "pre_lease",
                reportVersions = list(
                  reportVersion = list(
                    list(
                      version = "2.0",
                      isLatest = TRUE,
                      titleAddendum = NULL,
                      expiryDate = NULL
                    )
                  )
                )
              )
            )
          )
        )
      )
    ))
  } else if (endpoint == "reports" && method == "getReportInfo") {
    return(list(
      response = list(
        result = list(
          reports = list(
            report = list(
              list(
                name = "Pre-Lease Report",
                description = "Detailed pre-lease information",
                filters = list(
                  filter = list(
                    list(
                      fieldName = "property_group_ids",
                      fieldValue = "123,456"
                    )
                  )
                )
              )
            )
          )
        )
      )
    ))
  } else if (endpoint == "reports" && method == "getReportData") {
    return(list(
      response = list(
        result = list(
          reportData = list(
            summary = list(
              list(
                property_name = "Test Property",
                available_count = 100,
                occupied_count = 80
              )
            ),
            details = list(
              list(
                property_name = "Test Property",
                unit_number = "101",
                move_in_date = "2023-01-01"
              )
            )
          )
        )
      )
    ))
  } else {
    return(NULL)
  }
}

test_that("EntrataAPI class works as expected", {
  api <- EntrataAPI$new(config = cfg_test)
  expect_s3_class(api, "EntrataAPI")
  expect_equal(api$config$username, "testuser")
  expect_equal(api$config$password, "testpass")
  expect_equal(api$config$base_url, "https://api.entrata.com")
})

test_that("get_reports_list works as expected", {
  with_mocked_bindings(
    `EntrataAPI$send_request` = function(...) {
      mock_entrata_api_response("reports", "getReportList", NULL)
    },
    {
      api <- EntrataAPI$new()
      reports_list <- api$get_reports_list()
      expect_data_frame(reports_list)
      expect_equal(nrow(reports_list), 1)
      expect_equal(reports_list$report_name, "Pre-Lease Report")
      expect_equal(reports_list$report_version, "2.0")
      expect_true(reports_list$is_latest)
    }
  )
})

test_that("get_report_info works as expected", {
  with_mocked_bindings(
    `EntrataAPI$send_request` = function(...) {
      mock_entrata_api_response("reports", "getReportInfo", list(
        reportName = "Pre-Lease Report",
        reportVersion = "2.0"
      ))
    },
    {
      api <- EntrataAPI$new()
      report_info <- api$get_report_info("Pre-Lease Report")
      expect_type(report_info, "list")
      expect_equal(report_info$report_name, "Pre-Lease Report")
      expect_equal(report_info$report_description, "Detailed pre-lease information")
      expect_data_frame(report_info$report_filters)
      expect_equal(nrow(report_info$report_filters), 1)
      expect_equal(report_info$report_filters$fieldName, "property_group_ids")
      expect_equal(report_info$report_filters$fieldValue, "123,456")
    }
  )
})

test_that("generate_pre_lease_report works as expected", {
  with_mocked_bindings(
    `EntrataAPI$send_request` = function(...) {
      mock_entrata_api_response("reports", "getReportData", NULL)
    },
    {
      api <- EntrataAPI$new()
      pre_lease_report <- api$generate_pre_lease_report(property_ids = c(123, 456))
      expect_type(pre_lease_report, "list")
      expect_data_frame(pre_lease_report$summary)
      expect_data_frame(pre_lease_report$details)
      expect_equal(nrow(pre_lease_report$summary), 1)
      expect_equal(pre_lease_report$summary$property_name, "Test Property")
      expect_equal(pre_lease_report$summary$available_count, 100)
      expect_equal(pre_lease_report$summary$occupied_count, 80)
      expect_equal(nrow(pre_lease_report$details), 1)
      expect_equal(pre_lease_report$details$property_name, "Test Property")
      expect_equal(pre_lease_report$details$unit_number, "101")
      expect_equal(pre_lease_report$details$move_in_date, "2023-01-01")
    }
  )
})

test_that("handle_api_error works as expected", {
  with_mocked_bindings(
    `EntrataAPI$send_request` = function(...) {
      res <- httr2::response(list(
        response = list(
          error = list(
            code = 404,
            message = "Not Found"
          )
        )
      ))
      class(res) <- "response"
      res
    },
    {
      api <- EntrataAPI$new()
      expect_error(
        api$get_reports_list(),
        "Error Code: 404\nError Message: Not Found"
      )
    }
  )
})

test_that("handle_api_retry works as expected", {
  with_mocked_bindings(
    `EntrataAPI$send_request` = function(...) {
      res <- httr2::response(list(
        response = list(
          error = list(
            code = 429,
            message = "Too Many Requests"
          )
        )
      ))
      class(res) <- "response"
      res
    },
    {
      api <- EntrataAPI$new()
      expect_message(
        api$get_reports_list(enable_retry = TRUE),
        "Retrying request due to transient error"
      )
    }
  )
})
