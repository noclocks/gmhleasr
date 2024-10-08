% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/entrata_reports_pre_lease.R
\name{entrata_pre_lease_report}
\alias{entrata_pre_lease_report}
\title{Entrata Pre-Lease Report}
\usage{
entrata_pre_lease_report(
  property_ids = get_property_ids_filter_param(),
  leasing_period_start_date = get_pre_lease_period_start_date(),
  leasing_period_type = c("today", "date"),
  summarize_by = c("property", "unit_type", "floorplan_name", "do_not_summarize"),
  group_by = c("do_not_group", "unit_type", "floorplan_name", "lease_term"),
  consider_pre_leased_on = c("33", "32", "34", "41", "42", "43", "44"),
  charge_code_detail = c("0", "1"),
  space_options = c("do_not_show", "show_preferred", "show_actual"),
  additional_units_shown = c("available", "excluded"),
  combine_unit_spaces_with_same_lease = c("0", "1"),
  consolidate_by = c("no_consolidation", "consolidate_all_properties",
    "consolidate_by_property_groups"),
  arrange_by_property = c("0", "1"),
  subtotals = list("summary", "details"),
  yoy = c("1", "0"),
  ...
)
}
\arguments{
\item{property_ids}{A vector of property IDs to include in the report.
Defaults to \code{get_property_ids_filter_param()}, which returns all available
property IDs. The actual values passed to the request need to be unnamed and
flattened to a character vector or single level list.}

\item{leasing_period_start_date}{The start date of the leasing period. Defaults
to the result of \code{get_pre_lease_period_start_date()} which returns the date
for September 1st of either the current year or the next year, depending on
the current date. The date should be formatted as "m/d/Y".}

\item{leasing_period_type}{The type of leasing period. Defaults to "today".
Can be one of "today" or "date".}

\item{summarize_by}{The method of summarizing the report. Defaults to "property".
Can be one of "property", "unit_type", "floorplan_name", or "do_not_summarize".}

\item{group_by}{The method of grouping the report. Defaults to "do_not_group".
Can be one of "do_not_group", "unit_type", "floorplan_name", or "lease_term".}

\item{consider_pre_leased_on}{The method of considering pre-leased units. Defaults
to "33". Can be one of "32", "33", "34", "41", "42", "43", or "44", which
(I believe) represent the various leasing occupancy types.}

\item{charge_code_detail}{The method of showing charge code details. Defaults to "0".
If set to "1", the report will show charge code details.}

\item{space_options}{The method of showing space options. Defaults to "do_not_show".
Can be one of "do_not_show", "show_preferred", or "show_actual".}

\item{additional_units_shown}{The method of showing additional units. Defaults to "available".
Can be one of "available" or "excluded".}

\item{combine_unit_spaces_with_same_lease}{The method of combining unit spaces with the same lease.
Defaults to "0". If set to "1", the report will combine unit spaces with the same lease.}

\item{consolidate_by}{The method of consolidating the report. Defaults to "no_consolidation".
Can be one of "no_consolidation", "consolidate_all_properties", or "consolidate_by_property_groups".}

\item{arrange_by_property}{The method of arranging the report by property. Defaults to "0".
If set to "1", the report will be arranged by property.}

\item{subtotals}{A list of subtotals to include in the report. Defaults to "summary" and "details".
Can be one or both of "summary" and "details".}

\item{yoy}{The method of showing year-over-year data. Defaults to "1". If set to "0", the report
will not show year-over-year data.}

\item{...}{Additional parameters for the API request passed on to the downstream
\code{entrata()} function.}
}
\value{
A list with the extracted, un-processed report data.
}
\description{
This function generates a pre-lease report using the \code{reports} and \code{queue}
Entrata endpoints with their corresponding methods and input filter parameters.

The response's report data will vary depending on the provided filter
parameters and should return a list with the extracted, un-processed report
data for the summary and details report "subtotals".
}
\details{
The function performs the following steps:
\enumerate{
\item Get the latest report version for the "pre_lease" report using the
\code{get_latest_report_version()} function.
\item Prepare the property IDs, leasing period start date, and period method parameters.
\item Validate the input parameters for \code{summarize_by}, \code{group_by}, \code{consider_pre_leased_on},
\code{charge_code_detail}, \code{space_options}, \code{additional_units_shown}, \code{combine_unit_spaces_with_same_lease},
\code{consolidate_by}, \code{arrange_by_property}, \code{yoy}, and \code{subtotals}.
\item Prepare the report request method parameters.
\item Perform a request to get the queue ID.
\item Extract the queue ID and display an alert message with the queue ID.
\item Prepare a request to get the report data.
\item Perform the request iteratively, throttling the retry until an actual response
with data is received.
\item Extract and parse the content from the response, separating "summary"
and "details" data as necessary.
\item Return a list with the extracted, un-processed report data for
further downstream processing or analysis.
}
}
\seealso{
\href{https://gmhcommunities.entrata.com/api/v1/documentation/getReportInfo}{Entrata API Documentation}

\code{\link[=get_latest_report_version]{get_latest_report_version()}}, \code{\link[=get_property_ids_filter_param]{get_property_ids_filter_param()}}, \code{\link[=get_pre_lease_period_start_date]{get_pre_lease_period_start_date()}}
}
