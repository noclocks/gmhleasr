#  ------------------------------------------------------------------------
#
# Title : Reactivity Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

#' Make Reactive Trigger
#'
#' @description
#' Create a 'reactive trigger' object (not a proper R class) with two methods:
#' 1. `depend()` : must be written in a code chunk to execute on triggering
#' 2. `trigger()`: when executed, trigger the object (and all the "depending"
#'      code chunks)
#'
#' This function is freely re-used from Dean Attali's work:
#' See [here](https://github.com/daattali/advanced-shiny/tree/master/reactive-trigger).
#'
#' @param dev logical; if TRUE, will print messages to console
#' @param label character; label for the trigger
#'
#' @return list with two functions: `depend()` and `trigger()`
#'
#' @export
#'
#' @importFrom shiny reactiveValues isolate
#'
#' @examples
#'
#' # create a reactive trigger
#' trigger <- make_reactive_trigger(dev = TRUE, label = "my_trigger")
make_reactive_trigger <- function(dev = FALSE, label = "") {
  rv <- shiny::reactiveValues(a = 0)

  list(
    depend = function() {
      if (isTRUE(dev)) message("[dev] triggered: ", label)
      rv$a
      invisible()
    },
    trigger = function() {
      if (isTRUE(dev)) message("[dev] trigger: ", label)
      rv$a <- shiny::isolate(rv$a + 1)
    }
  )
}
