testthat::set_state_inspector(function() {
  list(
    attached = search(),
    num_conns = nrow(showConnections()),
    conns = getAllConnections(),
    handlers = if (getRversion() >= "4.0.0") {
      globalCallingHandlers()
    } else {
      Sys.getenv("error")
    },
    cwd = getwd(),
    envvars = Sys.getenv(),
    libpaths = .libPaths(),
    locale = Sys.getlocale(),
    tz = Sys.timezone(),
    par = par(),
    sink = sink.number(),
    options = .Options,
    packages = .packages(all.available = TRUE),
    tempfiles = list.files(tempdir(), full.names = TRUE),
    NULL
  )
})
