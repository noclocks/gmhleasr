
#  ------------------------------------------------------------------------
#
# Title : Time Tracking Script
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

library(togglr)
require(config)
source("tools/R/utils_toggl.R")

toggl_config <- config::get("toggl")
togglr::set_toggl_api_token(toggl_config$api_token)

# get arguments passed to Rscript
args <- commandArgs(trailingOnly = TRUE)

