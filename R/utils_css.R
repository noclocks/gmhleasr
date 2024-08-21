#  ------------------------------------------------------------------------
#
# Title : CSS Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------


#' Verify CSS
#'
#' @description
#' Verify that the CSS properties of a given element match the expected values.
#'
#' @param selector The CSS selector for the element to verify
#' @param css A named list of CSS properties and their expected values
#'
#' @return A logical value indicating whether the CSS properties match the expected values
#' @export
#'
#' @examples
#' \dontrun{
#' verify_css("#my-element", list("color" = "red", "font-size" = "16px"))
#' }
#'
#' @importFrom shinyjs runjs
#' @importFrom jsonlite toJSON
#' @importFrom glue glue
#' @importFrom shiny isolate
verify_css <- function(selector, css) {
  css_props <- jsonlite::toJSON(css, auto_unbox = TRUE)

  js <- glue::glue("
    (function() {{
      var selector = {jsonlite::toJSON(selector)};
      var cssProps = {css_props};
      var element = document.querySelector(selector);
      if (!element) {{
        console.error('Element not found: ' + selector);
        return false;
      }}
      var style = window.getComputedStyle(element);
      for (var prop in cssProps) {{
        var expectedValue = cssProps[prop];
        var actualValue = style.getPropertyValue(prop);
        if (actualValue !== expectedValue) {{
          console.warn('CSS mismatch for ' + prop + ': expected ' + expectedValue + ', got ' + actualValue);
          return false;
        }}
      }}
      return true;
    }})();")

  result <- shiny::isolate(shinyjs::runjs(js))

  return(result)
}
