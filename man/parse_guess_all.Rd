% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_data.R
\name{parse_guess_all}
\alias{parse_guess_all}
\title{Reparse a Data Frame}
\usage{
parse_guess_all(df)
}
\arguments{
\item{df}{data frame}
}
\value{
a data frame with re-parsed data types
}
\description{
\code{parse_guess_all()} is a function to reparse a data frame by guessing the
data types of each column.
}
\examples{
my_df <- tibble::tibble(a = "1", b = "a", c = 5)
str(my_df)
# tibble [1 × 3] (S3: tbl_df/tbl/data.frame)
# $ a: chr "1"
# $ b: chr "a"
# $ c: num 5

parsed_df <- parse_guess_all(my_df)
str(parsed_df)
# tibble [1 × 3] (S3: tbl_df/tbl/data.frame)
# $ a: num 1
# $ b: chr "a"
# $ c: num 5
}
