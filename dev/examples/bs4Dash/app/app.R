library(shiny)
library(bs4Dash)
library(shinyjs)
library(shinyWidgets)


app_header_ui <- function(id) {
  ns <- shiny::NS(id)

  bs4Dash::dashboardHeader(
    title = "Leasing Dashboard"
  )

}

app_sidebar_ui <- function(id) {
  ns <- shiny::NS(id)

  bs4Dash::dashboardSidebar(
    id = ns("sidebar"),
    bs4Dash::dashboardBrand(
      title = "Leasing Dashboard",
      image = "gmh-logo.svg",
      href = "https://gmhcommunities.com"
    ),
    bs4Dash::sidebarMenu(
      id = ns("sidebar_menu"),
      bs4Dash::menuItem(
        text = "Dashboard",
        tabName = "dashboard",
        icon = shiny::icon("tachometer-alt")
      ),
      bs4Dash::menuItem(
        text = "Reports",
        tabName = "reports",
        icon = shiny::icon("file-alt")
      ),
      bs4Dash::menuItem(
        text = "Properties",
        tabName = "properties",
        icon = shiny::icon("building")
      )
    )
  )

}

app_sidebar_header_ui <- function(
  id,
  title = "GMH Leasing Dashboard",
  version = "1.0.0",
  last_updated = format(Sys.Date(), "%Y-%m-%d"),
  ...
  ) {

  ns <- shiny::NS(id)

  htmltools::tagList(
    htmltools::tags$div(
      id = ns("sidebar_header"),
      style = "text-align: center; padding-top: 3px; padding-bottom: 3px;",
      htmltools::tags$p(
        title,
        style = "font-weight: bold; margin-bottom: 0px;"
      ),
      htmltools::tags$p(
        paste0("Version: ", version),
        style = "margin-top: 0px; margin-bottom: 0px;"
      ),
      htmltools::tags$p(
        paste0("Last Updated: ", last_updated),
        style = "margin-top: 0px; margin-bottom: 0px;"
      )
    ),
    htmltools::tags$hr()
  )
}


app_footer_ui <- function(id) {
  ns <- shiny::NS(id)

  bs4Dash::dashboardFooter(
    left = htmltools::tags$p(
      "Build for use by ",
      htmltools::tags$a(
        "GMH Communities",
        href = "https://gmhcommunities.com",
        target = "_blank"
      )
    ),
    right = htmltools::tags$p(
      "Developed by ",
      htmltools::tags$a(
        "No Clocks, LLC",
        href = "https://noclocks.dev",
        target = "_blank"
      ),
      " | ", htmltools::HTML("&copy;"), " Copyright ",
      format(Sys.Date(), "%Y")
    )
  )

}




shinyApp(
  ui = dashboardPage(
    title = "GMH Leasing Dashboard",
    fullscreen = TRUE,
    freshTheme = NULL,
    preloader = NULL,
    options = NULL,
    dark = FALSE,
    scrollToTop = TRUE,
    header = app_header_ui("header"),
    sidebar = app_sidebar_ui("sidebar"),
    controlbar = NULL,
    footer = NULL,
    body = dashboardBody(
      htmltools::tagList(
        htmltools::tags$head(
          htmltools::tags$link(
            rel = "shortcut icon",
            type = "image/x-icon",
            href = "favicon.ico"
          ),
          # app_meta(),
          shinyjs::useShinyjs()#,
          # shinyFeedback::useShinyFeedback(feedback = FALSE),
          # waiter::useWaiter()
        ),
        tabItems(
          tabItem(
            tabName = "item1",
            fluidRow(
              lapply(1:3, FUN = function(i) {
                sortable(
                  width = 4,
                  p(class = "text-center", paste("Column", i)),
                  lapply(1:2, FUN = function(j) {
                    box(
                      title = paste0("I am the ", j, "-th card of the ", i, "-th column"),
                      width = 12,
                      "Click on my header"
                    )
                  })
                )
              })
            )
          ),
          tabItem(
            tabName = "item2",
            box(
              title = "Card with messages",
              width = 9,
              userMessages(
                width = 12,
                status = "success",
                userMessage(
                  author = "Alexander Pierce",
                  date = "20 Jan 2:00 pm",
                  image = "https://adminlte.io/themes/AdminLTE/dist/img/user1-128x128.jpg",
                  type = "received",
                  "Is this template really for free? That's unbelievable!"
                ),
                userMessage(
                  author = "Dana Pierce",
                  date = "21 Jan 4:00 pm",
                  image = "https://adminlte.io/themes/AdminLTE/dist/img/user5-128x128.jpg",
                  type = "sent",
                  "Indeed, that's unbelievable!"
                )
              )
            )
          )
        )
      )
    )
  ),
  server = function(input, output, session) {

    observe({
      print(input$sidebar)
      print(input$sidebar_menu)

      if (input$sidebar == FALSE) {
        shinyjs::hide(id = "sidebar_title")
      } else {
        shinyjs::show(id = "sidebar_title")
      }

    })

  }
)


# header = dashboardHeader(
#   title = htmltools::tagList(
#     htmltools::tags$a(
#       href = "https://gmhcommunities.com",
#       target = "_blank",
#       htmltools::tags$img(
#         src = "gmh-logo.svg",
#         style = "width: 100%; height: auto; margin-top: 5px; margin-bottom: 5px; align: center;",
#         alt = "GMH Communities"
#       )
#     )
#   ),
#   skin = "light",
#   status = "white",
#   border = TRUE,
#   sidebarIcon = icon("bars"),
#   controlbarIcon = icon("th"),
#   fixed = FALSE,
#   leftUi = tagList(
#     dropdownMenu(
#       badgeStatus = "info",
#       type = "notifications",
#       notificationItem(
#         inputId = "triggerAction2",
#         text = "Error!",
#         status = "danger"
#       )
#     ),
#     dropdownMenu(
#       badgeStatus = "info",
#       type = "tasks",
#       taskItem(
#         inputId = "triggerAction3",
#         text = "My progress",
#         color = "orange",
#         value = 10
#       )
#     )
#   ),
#   rightUi = dropdownMenu(
#     badgeStatus = "danger",
#     type = "messages",
#     messageItem(
#       inputId = "triggerAction1",
#       message = "message 1",
#       from = "Divad Nojnarg",
#       image = "https://adminlte.io/themes/v3/dist/img/user3-128x128.jpg",
#       time = "today",
#       color = "lime"
#     )
#   )
# ),

# sidebar = dashboardSidebar(
#   id = "sidebar",
#   inputId = "sidebar_state",
#   disable = FALSE,
#   width = "250px",
#   skin = "light",
#   elevation = 3,
#   collapsed = FALSE,
#   minified = TRUE,
#   expandOnHover = TRUE,
#   fixed = TRUE,
#   status = "primary",
#   customArea = NULL,
#
#   # App Title, Version, and Date Updated at top of Sidebar, formatted nicely
#   htmltools::tags$div(
#     id = "sidebar_title",
#     style = "text-align: center; padding-top: 3px; padding-bottom: 3px;",
#     htmltools::tags$p(
#       "GMH Leasing Dashboard",
#       style = "font-weight: bold; margin-bottom: 0px;"
#     ),
#     htmltools::tags$p(
#       "Version: 1.0.0",
#       style = "margin-top: 0px; margin-bottom: 0px;"
#     ),
#     htmltools::tags$p(
#       "Last Updated: 2024-08-30",
#       style = "margin-top: 0px; margin-bottom: 0px;"
#     )
#   ),
#   htmltools::tags$hr(),
#   sidebarMenu(
#     id = "sidebar_menu",
#     # flat = TRUE,
#     # compact = TRUE,
#     # childIndent = TRUE,
#     # legacy = FALSE,
#     menuItem(
#       "Dashboard",
#       tabName = "dashboard",
#       icon = icon("tachometer-alt")
#     ),
#     menuItem(
#       "Reports",
#       tabName = "reports",
#       icon = icon("file-alt"),
#       badgeLabel = "New!",
#       badgeColor = "success"
#     ),
#     menuItem(
#       "Properties",
#       tabName = "properties",
#       icon = icon("building"),
#       badgeLabel = "New!",
#       badgeColor = "success"
#     )
#   )
# ),

# controlbar = dashboardControlbar(
#   skin = "light",
#   pinned = TRUE,
#   collapsed = FALSE,
#   overlay = FALSE,
#   controlbarMenu(
#     id = "controlbarmenu",
#     controlbarItem(
#       title = "Item 1",
#       sliderInput(
#         inputId = "obs",
#         label = "Number of observations:",
#         min = 0,
#         max = 1000,
#         value = 500
#       ),
#       column(
#         width = 12,
#         align = "center",
#         radioButtons(
#           inputId = "dist",
#           label = "Distribution type:",
#           c(
#             "Normal" = "norm",
#             "Uniform" = "unif",
#             "Log-normal" = "lnorm",
#             "Exponential" = "exp"
#           )
#         )
#       )
#     ),
#     controlbarItem(
#       "Item 2",
#       "Simple text"
#     )
#   )
# ),
