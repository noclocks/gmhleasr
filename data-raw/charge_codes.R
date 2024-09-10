
ar_codes <- entrata(
  "arcodes",
  "getArCodes",
  perform = TRUE
) |>
  httr2::resp_body_json() |>
  purrr::pluck("response", "result", "arcodes", "arcode") |>
  dplyr::bind_rows() |>
  janitor::clean_names()

charge_codes <- tibble::tribble(
                  ~charge_code_id,                                               ~charge_code, ~charge_code_type,
                          148909L,                         "Additional Rent - Mitigated Risk",                NA,
                          148111L,                                              "Amenity Fee",                NA,
                          148253L,                                          "Balcony Premium",                NA,
                          148919L,                                     "Balcony Unit Premium",                NA,
                          147881L,                                                "Base Rent",                NA,
                          147893L,                                          "Covered Parking",                NA,
                          148851L,                              "Deferred Rent - August 2022",                NA,
                          148929L,                             "Deferred Rent - January 2023",                NA,
                          149015L,                                "Deferred Rent - July 2024",                NA,
                          149017L,                                "Deferred Rent - June 2024",                NA,
                          148906L,                                  "Deferred Rent July 2023",                NA,
                          148784L,                                  "Deferred Rent June 2022",                NA,
                          148905L,                                  "Deferred Rent June 2023",                NA,
                          148656L,                                                  "Deposit",                NA,
                          148090L,                                        "Employee Discount",                NA,
                          148230L,                                       "Floor Plan Premium",                NA,
                          148134L,                                           "Garage Parking",                NA,
                          148902L,                                  "GMH Communities Covered",                NA,
                          149009L,                                "Group New Lease Gift Card",                NA,
                          149010L,                     "Group New Lease Gift Card Adjustment",                NA,
                          149011L,                                  "Group Renewal Gift Card",                NA,
                          149012L,                       "Group Renewal Gift Card Adjustment",                NA,
                          148650L,                       "Landlord Liability Protection Plan",                NA,
                          148834L,            "Landlord Liability Protection Plan - Base Use",                NA,
                          148651L,            "Landlord Personal Property Protection Program",                NA,
                          148833L, "Landlord Personal Property Protection Program - Base Use",                NA,
                          148820L,                                    "Leasing Special - New",      "Concession",
                          148814L,                               "Leasing Special - Renewals",      "Concession",
                          148511L,                                        "Location Discount",                NA,
                          148097L,                                              "Lot Parking",                NA,
                          148135L,                                           "Model / Office",                NA,
                          148993L,                                      "New Lease Gift Card",                NA,
                          148994L,                           "New Lease Gift Card Adjustment",                NA,
                          148603L,                                              "Pet Deposit",                NA,
                          148109L,                                                 "Pet Fees",                NA,
                          148453L,                                                 "Pet Rent",                NA,
                          148258L,                                        "Pool View Premium",                NA,
                          148910L,                                             "Premium View",                NA,
                          148914L,                                    "Premium View - Add On",                NA,
                          148915L,                                   "Premium View - Amenity",                NA,
                          148649L,                                        "Property Transfer",                NA,
                          148995L,                                        "Renewal Gift Card",      "Concession",
                          148996L,                             "Renewal Gift Card Adjustment",                NA,
                          148101L,                                      "Resident - Electric",                NA,
                          147884L,                                         "Security Deposit",                NA,
                          148928L,                  "Short Term Premium - 10-11 Month Leases",                NA,
                          148887L,                    "Short Term Premium - 6-9 Month Leases",                NA,
                          148118L,                                             "Storage Fees",                NA,
                          148908L,                                              "Telecom Fee",                NA,
                          148468L,                                          "Terrace Premium",                NA,
                          148254L,                                        "Top Floor Premium",                NA,
                          148916L,                               "Top Floor Premium - Add On",                NA,
                          147897L,                                            "Transfer Fees",                NA,
                          148096L,                                 "Uncovered Garage Parking",                NA,
                          148911L,                                             "Unit Premium",                NA,
                          148554L,                                            "View Discount",                NA
                  )


ar_codes_in_charge_codes <- ar_codes |>
  dplyr::filter(
    id %in% charge_codes$charge_code_id
  )

missing_ar_codes <- ar_codes |>
  dplyr::filter(
    !id %in% charge_codes$charge_code_id
  )




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
