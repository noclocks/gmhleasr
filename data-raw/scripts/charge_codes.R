# properties --------------------------------------------------------------

property_details <- readr::read_csv("data-raw/reference/Property_Details.csv") |>
  janitor::clean_names() |>
  tibble::as_tibble()

gmh_property_ids <- property_details |>
  dplyr::pull("property_id") |>
  unique()

gmh_property_names <- property_details |>
  dplyr::pull("marketing_name") |>
  unique()

gmh_property_id_lookup <- gmh_property_ids |>
  setNames(gmh_property_names)

gmh_property_types <- property_details |>
  dplyr::pull("type") |>
  unique()

# gmh_property_ids <- c("739084", "641240", "676055", "952515", "518041", "518042", "833617", "1197887", "1143679", "1311849")


# leases ------------------------------------------------------------------



# charge codes ------------------------------------------------------------

charge_codes <- c(
  "Base Rent",
  "Best Deal Guarantee Gift Card",
  "Best Deal Guarantee Gift Card Adjustment",
  "Covered Parking",
  "Garage Parking",
  "Group New Lease Gift Card",
  "Group New Lease Gift Card Adjustment",
  "Group Renewal Gift Card",
  "Group Renewal Gift Card Adjustment",
  "Lot Parking",
  "Model / Office",
  "New Item Giveaway",
  "New Lease Gift Card",
  "New Lease Gift Card Adjustment",
  "New Lease Monthly Concession",
  "New Lease One-Time Concession",
  "Pet Rent",
  "Renewal Gift Card",
  "Renewal Gift Card Adjustment",
  "Renewal Item Giveaway",
  "Renewal Item Giveaway Adjustment",
  "Renewal Monthly Concession",
  "Renewal One-Time Concession",
  "Uncovered Garage Parking"
)
