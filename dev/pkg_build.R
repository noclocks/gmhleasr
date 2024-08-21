
#  ------------------------------------------------------------------------
#
# Title : Package Build
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

rebuild <- function(new_version = NA) {

  # check if new_version is provided
  if (is.na(new_version)) {
    stop("Please provide a new version number.")
  }

  # update DESCRIPTION file
  desc <- read.dcf("DESCRIPTION")
  desc["Version"] <- new_version
  write.dcf(desc, "DESCRIPTION")

  # update NAMESPACE file
  attachment::att_amend_desc()
  devtools::document()

  # cleanup any old archives
  unlink("*.tar.gz")

  # build package
  devtools::build(path = ".")

}


# check package
devtools::check()

# install package
devtools::install()

# update NEWS file
news <- readLines("NEWS.md")
news <- c(
  paste0("## [", new_version, "] - ", Sys.Date()),
  news
)
writeLines(news, "NEWS.md")

# update README file
readme <- readLines("README.md")
readme <- c(
  paste0("## [", new_version, "] - ", Sys.Date()),
  readme
)
writeLines(readme, "README.md")

# update pkgdown site
pkgdown::build_site()

# update git
system("git add .")
system("git commit -m 'Update package'")
system("git push")

return(invisible(TRUE))
