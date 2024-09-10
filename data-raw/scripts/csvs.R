csv_files <- fs::dir_ls("data-raw/working/GMH/CSV")

csv_data_lst <- purrr::map(
  csv_files,
  vroom::vroom,
  id = "file",
  show_col_types = TRUE
) |>
  rlang::set_names(basename(csv_files)) |>
  purrr::map(janitor::clean_names)

csv_data_lst |>
  list2env()
