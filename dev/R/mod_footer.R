# app_ui_footer <- function() {
#
#   left_content <- htmltools::tags$div(
#     class = "container",
#     htmltools::tags$div(
#       class = "row",
#       htmltools::tags$div(
#         class = "col-md-8 col-sm-6 col-xs-12",
#         htmltools::tags$p(
#           class = "left-footer-content",
#           "Developed and Maintained by ",
#           htmltools::tags$a(
#             href = "https://website.noclocks.dev",
#             target = "_blank",
#             "No Clocks, LLC"
#           ),
#           "&nbsp;|&nbsp;&copy; 2024."
#         )
#       )
#     )
#   )
#
#   right_content <- htmltools::tags$div(
#     class="col-md-4 col-sm-6 col-xs-12",
#     htmltools::tags$ul(
#       class = "social-icons",
#       htmltools::tags$li(
#         htmltools::tags$a(
#           href = "https://github.com/noclocks",
#           target = "_blank",
#           htmltools::tags$i(
#             class = "fab fa-github"
#           )
#         )
#       ),
#       htmltools::tags$li(
#         htmltools::tags$a(
#           href = "https://twitter.com/noclocksdev",
#           target = "_blank",
#           htmltools::tags$i(
#             class = "fab fa-twitter"
#           )
#         )
#       ),
#       htmltools::tags$li(
#         htmltools::tags$a(
#           href = "https://www.linkedin.com/company/noclocks",
#           target = "_blank",
#           htmltools::tags$i(
#             class = "fab fa-linkedin"
#           )
#         )
#       )
#     )
#   )
#
#   htmltools::tags$footer(
#     class = "site-footer",
#     htmltools::tags$div(
#       class = "container",
#       htmltools::tags$hr(),
#       htmltools::tags$div(
#         class = "row",
#         left_content,
#         right_content
#       )
#     )
#   )
# }
#
# #   footer_left <- htmltools::tags$footer(
# #     id = "noclocks-footer",
# #     class = "main-footer",
# #     htmltools::tags$div(
# #       class = "float-right d-none d-sm-inline",
# #       htmltools::tags$strong("Version"),
# #       utils::packageVersion("gmhleasr")
# #     ),
# #     )
# #   )
# #
# #   bs4Dash::bs4DashFooter(
# #
# #   )
# #
# # }
