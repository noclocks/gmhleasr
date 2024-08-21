test_that("help_mark function generates correct HTML structure", {
  result <- help_mark("Test help text")

  # Check that the result is a tagList
  expect_s3_class(result, "shiny.tag.list")

  # Check the head tag and its contents
  head_tag <- result[[1]]
  expect_s3_class(head_tag, "shiny.tag")
  expect_equal(head_tag$name, "head")
  expect_s3_class(head_tag$children[[1]], "shiny.tag")

  expect_true(
    head_tag$children[[1]]$name %in% c("style", "link")
  )
  expect_true(grepl(".helper \\{", head_tag$children[[1]]$children[[1]]))

  # Check the div tag and its contents
  div_tag <- result[[2]]
  expect_s3_class(div_tag, "shiny.tag")
  expect_equal(div_tag$name, "div")
  expect_equal(div_tag$attribs$class, "helper")
  expect_equal(div_tag$attribs$`data-help`, "Test help text")

  # Check the icon
  icon <- div_tag$children[[1]]
  expect_s3_class(icon, "shiny.tag")
  expect_equal(icon$name, "i")
  expect_true(grepl("far fa-circle-question", icon$attribs$class))
})

test_that("help_mark function includes correct CSS", {
  result <- help_mark("Test help text")

  head_tag <- result[[1]]
  style_content <- head_tag$children[[1]]$children[[1]]

  expect_true(grepl("margin-left: 0.5em;", style_content))
  expect_true(grepl("margin-right: 0.5em;", style_content))
  expect_true(grepl("cursor: help;", style_content))
  expect_true(grepl("content: attr\\(data-help\\);", style_content))
  expect_true(grepl("position: absolute;", style_content))
})

test_that("help_mark function handles different input correctly", {
  result_empty <- help_mark("")
  expect_equal(result_empty[[2]]$attribs$`data-help`, "")

  result_long <- help_mark("This is a very long help text that goes on and on")
  expect_equal(result_long[[2]]$attribs$`data-help`, "This is a very long help text that goes on and on")

  result_special_chars <- help_mark("Help with <special> & 'characters'")
  expect_equal(result_special_chars[[2]]$attribs$`data-help`, "Help with <special> & 'characters'")
})
