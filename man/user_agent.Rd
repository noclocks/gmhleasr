% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/entrata_internal.R
\name{user_agent}
\alias{user_agent}
\title{Create User Agent}
\usage{
user_agent(
  package = "gmhleasr",
  version = utils::packageVersion("gmhleasr"),
  url = desc::desc_get("URL", system.file("DESCRIPTION", package = package))[[1]],
  overwrite = FALSE
)
}
\arguments{
\item{package}{Package name. Default is "gmhleasr".}

\item{version}{Package version. Default is the current version of "gmhleasr".}

\item{url}{Package URL. Default is the URL from the package's \code{DESCRIPTION} file.}
}
\value{
User agent string.
}
\description{
Function to create a user agent string for \code{HTTP} requests.
}
\examples{
user_agent("gmhleasr", "0.0.1")
}
