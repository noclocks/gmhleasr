#  ------------------------------------------------------------------------
#
# Title : Entrata Leases Setup
#    By : Jimmy Briggs
#  Date : 2024-08-28
#
#  ------------------------------------------------------------------------

cfg <- config::get("entrata", file = here::here("config.yml"))

test_prop_ids <- c(
  "739084",
  "641240",
  "676055",
  "952515",
  "518041",
  "518042",
  "833617",
  "1197887",
  "1143679",
  "1311849"
)

# # Mock data for testing
# mock_response <- function() {
#   list(
#     response = list(
#       result = list(
#         leases = list(
#           lease = list(
#             list(
#               id = "12345",
#               move_in_date = "01/01/2023",
#               is_month_to_month = "f",
#               lease_intervals = list(
#                 list(
#                   lease_interval_id = "67890",
#                   lease_interval_type_name = "New Lease",
#                   lease_interval_status_type_name = "Active",
#                   interval_start_date = "01/01/2023",
#                   interval_end_date = "12/31/2023"
#                 )
#               ),
#               customers = list(
#                 list(
#                   customer_id = "11111",
#                   name_full = "John Doe",
#                   email_address = "john.doe@example.com"
#                 )
#               ),
#               scheduled_charges = list(
#                 list(
#                   id = "22222",
#                   amount = "1000.00",
#                   start_date = "01/01/2023",
#                   end_date = "12/31/2023"
#                 )
#               ),
#               unit_spaces = list(
#                 list(
#                   unit_space_id = "33333",
#                   unit_space = "Apartment 101"
#                 )
#               )
#             )
#           )
#         )
#       )
#     )
#   )
# }
