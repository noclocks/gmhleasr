function checkCSSDeclarations(selector, cssProps) {
  var element = document.querySelector(selector);
  if (!element) {
    console.error("Element not found: " + selector);
    Shiny.setInputValue("css_check_result", false, { priority: "event" });
    return;
  }
  var style = window.getComputedStyle(element);
  var allMatched = true;
  for (var prop in cssProps) {
    var expectedValue = cssProps[prop];
    var actualValue = style.getPropertyValue(prop);
    if (actualValue !== expectedValue) {
      allMatched = false;
      console.warn(
        "CSS mismatch for " +
          prop +
          ": expected " +
          expectedValue +
          ", got " +
          actualValue
      );
    }
  }
  Shiny.setInputValue("css_check_result", allMatched, { priority: "event" });
}
