% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/entrata_reports.R
\name{get_entrata_reports_list}
\alias{get_entrata_reports_list}
\title{Get Entrata Reports List}
\usage{
get_entrata_reports_list(latest_only = TRUE)
}
\arguments{
\item{latest_only}{Logical, if TRUE (default), returns only the latest version
of each report.}
}
\value{
A tibble containing report information including report name, ID,
system name, and version.
}
\description{
This function retrieves a list of reports available in the
Entrata system, optionally filtering to only the latest version of each report.
}
