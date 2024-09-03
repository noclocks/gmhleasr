require(sass)

input_scss <- "inst/app/www/styles/scss/index.scss"
output_css <- "inst/app/www/styles/styles.min.css"

sass::sass(
  input = sass::sass_file(input_scss),
  output = output_css,
  options = sass::sass_options(
    output_style = "compressed"
  )
)
