library(shiny)
library(htmltools)

# Assuming contact_item and other helper functions are already defined
devtools::load_all()

# Sample contacts data
app_contacts <- function() {
  list(
    "jimmy" = contact_item(
      name = "Jimmy Briggs",
      role = "Developer",
      company = "No Clocks, LLC",
      phone = "6784914856",
      email = "jimmy.briggs@noclocks.dev",
      url = "https://github.com/jimbrig",
      image = "inst/assets/images/noclocks/team/jimmy-headshot.png"
    ),
    "patrick" = contact_item(
      name = "Patrick Howard",
      role = "Developer",
      company = "NoClocks",
      phone = "4044082500",
      email = "patrick.howard@noclocks.dev",
      url = "https://github.com/phoward38",
      image = "inst/assets/images/noclocks/team/patrick-headshot.png"
    )
  )
}

# Contact menu function
contact_menu <- function(...) {
  items <- c(list(...))
  tags$li(
    class = "dropdown",
    tags$a(
      href = "#",
      class = "dropdown-toggle",
      `data-toggle` = "dropdown",
      tags$i(class = "fa fa-address-book"),
      "Contact",
      tags$b(class = "caret")
    ),
    tags$ul(class = "dropdown-menu contact-dropdown", items)
  )
}

# UI
ui <- bs4Dash::dashboardPage(
  dark = NULL,
  header = bs4Dash::dashboardHeader(
    title = "My bs4Dash App",
    rightUi = contact_menu(app_contacts()),
    skin = "dark",
    border = TRUE
  ),
  sidebar = bs4Dash::dashboardSidebar(
    bs4Dash::sidebarMenu(
      bs4Dash::menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      bs4Dash::menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  body = bs4Dash::dashboardBody(
    tags$head(
      tags$style(HTML("
        .dropdown-menu {
          width: 300px !important;
          padding: 0;
          max-height: 400px;
          overflow-y: auto;
        }
        .dropdown-item:hover {
          background-color: #f8f9fa;
        }
        .dropdown-item {
          white-space: normal;
        }
      "))
    ),
    bs4Dash::tabItems(
      bs4Dash::tabItem(
        tabName = "dashboard",
        h1("Welcome to My bs4Dash App"),
        p("Click on the contact icon in the navbar to see the dropdown.")
      ),
      bs4Dash::tabItem(
        tabName = "about",
        h2("About This App"),
        p("This is a demo bs4Dash app showcasing a contact dropdown in the header.")
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  # No server-side logic needed for this demo
}

# Run the app
shinyApp(ui, server)
