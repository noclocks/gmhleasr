$(document).on("shiny:connected", function (e) {
  var screenWidth = screen.width;
  var screenHeight = screen.height;
  Shiny.onInputChange("screen_width", screenWidth);
  Shiny.onInputChange("screen_height", screenHeight);
});
