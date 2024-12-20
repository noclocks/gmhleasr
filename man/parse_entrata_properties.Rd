% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/entrata_properties.R
\name{parse_entrata_properties}
\alias{parse_entrata_properties}
\title{Parse Entrata Properties}
\usage{
parse_entrata_properties(res)
}
\arguments{
\item{res}{The \code{\link[httr2:response]{httr2::response()}} object from the Entrata API.}
}
\value{
A data frame with the parsed property information.
}
\description{
Parses the response from the Entrata API's "getProperties" method.
}
