
#  ------------------------------------------------------------------------
#
# Title : Entrata Requests
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

pkgload::load_all()

property_ids <- get_property_ids_filter_param()
test_property_id <- property_ids[1]

# status ------------------------------------------------------------------
req_status <- entrata("status", "getStatus", perform = FALSE)
req_status


# customers ---------------------------------------------------------------
req_customers <- entrata("customers", "getCustomers", method_params = list(propertyId = "641240"), perform = FALSE)
req_customers

# leases ------------------------------------------------------------------
req_leases <- entrata("leases", "getLeases", method_params = list(propertyId = "641240"), perform = FALSE)
req_leases


# test --------------------------------------------------------------------

reqs <- list(
  req_status,
  req_customers,
  req_leases
)

paths <- c(
  "data-raw/entrata/status.request.json",
  "data-raw/entrata/customers.request.json",
  "data-raw/entrata/leases.request.json"
)

resps_seq <- httr2::req_perform_sequential(reqs, paths, progress = TRUE)
resps_seq

resps_parallel <- httr2::req_perform_parallel(reqs, paths, progress = TRUE)
resps_parallel

resps_parallel |> httr2::resps_successes() |> httr2::resps_requests()


# promise -----------------------------------------------------------------

library(promises)
library(future)
plan(multisession)

resolve_promise_response <- function(res_promise, name = "res_content") {

  requireNamespace("promises", quietly = TRUE)

  if (name %in% ls(globalenv())) {
    cli::cli_alert_warning(
      c(
        "Provided name {.field {name}} already exists in the global environment.",
        "and will be overwritten."
      )
    )
    rm(name, envir = globalenv())
  }

  res_promise$then(
    onFulfilled = function(value) {
      cli::cli_alert_success("Promise Successfully Resolved.")
      httr2::resp_body_json(value)
    },
    onRejected = function(value) {
      cli::cli_alert_danger("Promise Failed.")
      return(NULL)
    }
  ) %...>% base::assign(name, ., envir = globalenv())

  repeat {
    res_out <- try(
      invisible(
        base::get(name, envir = globalenv())
      ),
      silent = TRUE
    )

    if (inherits(res_out, "list")) {


  }


    return(res_out)
  }

}

rm("res_promise")

res_promise <- httr2::req_perform_promise(req_status, "data-raw/entrata/status.request.json")
res_promise |> resolve_promise_response("res_content")

res_promise$then(onFulfilled = httr2::resp_body_json) %...>% assign("res_content", ., envir = globalenv())

res_content

res_content %...>% promise_resolve() %...>% assign("resp_status", ., envir = globalenv())
