
#  ------------------------------------------------------------------------
#
# Title : Excel Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-29
#
#  ------------------------------------------------------------------------



# styling -----------------------------------------------------------------

#' Apply Styles to Cells in an Excel Sheet
#'
#' @description
#' This internal function applies styles to a specific range of cells
#' in an Excel workbook using the `openxlsx` package.
#'
#' @param wb A workbook object from `openxlsx`.
#' @param sheet_number Numeric or character identifier for the sheet.
#' @param rows The row range to apply the style to.
#' @param cols The column number to apply the style to.
#' @param font_name Font name.
#' @param font_size Font size.
#' @param font_color Font color.
#' @param number_format Number format.
#' @param border Border style.
#' @param border_color Border color.
#' @param border_style Border style.
#' @param bg_fill Background fill color.
#' @param fg_fill Foreground fill color.
#' @param halign Horizontal alignment.
#' @param valign Vertical alignment.
#' @param text_decoration Text decoration.
#' @param wrap_text Wrap text.
#' @param text_rotation Text rotation angle.
#' @param indent Indentation level.
#' @param locked Lock cells.
#' @param hidden Hide cells.
#' @param ... Additional arguments.
#'
#' @return NULL. The function modifies the workbook object in place.
#'
#' @keywords internal
#'
#' @importFrom openxlsx createStyle addStyle
apply_xl_styles <- function(
  wb,
  sheet_number,
  range,
  rows,
  cols,
  font_name,
  font_size,
  font_color,
  number_format,
  border,
  border_color,
  border_style,
  bg_fill,
  fg_fill,
  halign,
  valign,
  text_decoration,
  wrap_text,
  text_rotation,
  indent,
  locked,
  hidden,
  ...
) {

  cell_style <- openxlsx::createStyle(
    fontName = font_name,
    fontSize = font_size,
    fontColour = font_color,
    numFmt = number_format,
    border = border,
    borderColor = border_color,
    borderStyle = border_style,
    fill = bg_fill,
    fgFill = fg_fill,
    halign = halign,
    valign = valign,
    textDecoration = text_decoration,
    wrapText = wrap_text,
    rotation = text_rotation,
    indent = indent,
    locked = locked,
    hidden = hidden
  )

  openxlsx::addStyle(
    wb,
    sheet = sheet_number,
    style = cell_style,
    rows = rows,
    cols = cols,
    stack = TRUE
  )

}



