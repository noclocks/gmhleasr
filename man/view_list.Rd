% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{view_list}
\alias{view_list}
\title{View List}
\usage{
view_list(listdata = NULL, ...)
}
\arguments{
\item{listdata}{List or string data to view - Although designed for lists,
\code{listdata} can be any data source that can be rendered into \code{JSON} through
\code{\link[jsonlite:fromJSON]{jsonlite::toJSON()}}. Alternately, \code{listdata} could be a character string
of valid \code{JSON}. This might be helpful when dealing with an \code{API} response.}

\item{...}{
  Arguments passed on to \code{\link[listviewer:jsonedit]{listviewer::jsonedit}}
  \describe{
    \item{\code{mode}}{\code{string} for the initial view from \code{modes}.  \code{'tree'} is the default.}
    \item{\code{modes}}{\code{string} \code{c('tree', 'text', 'table')} will be the default, since
these are all the modes currently supported by \code{jsoneditor}.}
    \item{\code{width}}{integer in pixels defining the width of the \code{div} container.}
    \item{\code{height}}{integer in pixels defining the height of the \code{div} container.}
    \item{\code{elementId}}{character to specify valid \code{CSS} id of the
htmlwidget for special situations in which you want a non-random
identifier.}
  }}
}
\value{
A JSON viewer of the list data.
}
\description{
View a list object in a JSON viewer via \code{\link[listviewer:jsonedit]{listviewer::jsonedit()}}.
}
\examples{
view_list(list(1, 2, 3))
}
