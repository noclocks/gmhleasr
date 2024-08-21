
#  ------------------------------------------------------------------------
#
# Title : Package Hex Logo
#    By : Jimmy Briggs
#  Date : 2024-08-18
#
#  ------------------------------------------------------------------------

# hexmake::run_app(with_mongo = FALSE)

library(magick)
library(hexSticker)

logo_url <- "https://cdn.brandfetch.io/gmhcommunities.com/logo"
icon_url <- "https://cdn.brandfetch.io/gmhcommunities.com/icon"

output_file_png <- "man/figures/hex_logo.png"
output_file_svg <- "man/figures/hex_logo.svg"

assets_dir <- "inst/assets/images"
fs::dir_create(assets_dir, recurse = TRUE)

gmh_color <- "#0e2b4c"

# png ---------------------------------------------------------------------

hexSticker::sticker(
  package = "gmhleasr",
  subplot = logo_url,
  url = "github.com/noclocks/gmhleasr",
  filename = output_file_png,
  p_x = 1,
  p_y = 1.4,
  p_family = "sans",
  p_color = gmh_color,
  p_size = 7,
  s_width = 0.6,
  s_height = 1,
  s_x = 1,
  s_y = 0.9,
  asp = 1,
  u_x = 1,
  u_y = 0.08,
  u_color = gmh_color,
  u_family = "mono",
  u_size = 1.3,
  u_angle = 30,
  h_fill = "white",
  h_color = gmh_color
)

fs::file_copy(output_file_png, assets_dir)


# svg ---------------------------------------------------------------------

hexSticker::sticker(
  package = "gmhleasr",
  subplot = logo_url,
  url = "github.com/noclocks/gmhleasr",
  filename = output_file_svg,
  p_x = 1,
  p_y = 1.4,
  p_family = "sans",
  p_color = gmh_color,
  p_size = 7,
  s_width = 0.6,
  s_height = 1,
  s_x = 1,
  s_y = 0.9,
  asp = 1,
  u_x = 1,
  u_y = 0.08,
  u_color = gmh_color,
  u_family = "mono",
  u_size = 1.3,
  u_angle = 30,
  h_fill = "white",
  h_color = gmh_color
)

fs::file_copy(output_file_svg, assets_dir)

browseURL(output_file_svg)
