
elements <- mod_header_elements_ui(
  id = ns("elements"),
  include_elements = list(
    help = TRUE,
    about = TRUE,
    refresh = TRUE,
    contact = TRUE,
    user = TRUE
  ),
  contacts = .app_contacts()
)

bs4Dash::bs4DashNavbar(
  title = shiny::div(
    class = "header-title",
    shiny::tags$a(
      href = "https://gmhcommunities.com",
      shiny::tags$img(
        src = "www/images/logos/gmh-logo.svg",
        alt = "GMH Communities",
        style = "width: 250px; height: auto;"
      )
    ),
    htmltools::tags$br(),
    htmltools::tags$hr(),
  ),
  skin = "light",
  border = TRUE,
  rightUi = elements[[4]],
  bs4Dash::bs4DashBrand(
    title = "Leasing Dashboard",
    image = "www/images/logos/gmh-communities-logo.svg",
  )
)
}

app_header_ui <- function()


  header = bs4DashNavbar(
    title = "Pre-Lease Report"
  ),
sidebar = bs4DashSidebar(
  bs4SidebarMenu(
    bs4SidebarMenuItem("Executive Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    bs4SidebarMenuItem("Manage Users", tabName = "users", icon = icon("users")),
    bs4SidebarMenuItem("Leases", tabName = "leases", icon = icon("file-contract")),
    bs4SidebarMenuItem("Properties", tabName = "properties", icon = icon("building"))
  )
),
body = bs4DashBody(
  bs4TabItems(
    bs4TabItem(
      tabName = "dashboard",
      mod_executive_dashboard_ui("executive_dashboard_1")
    ),
    bs4TabItem(
      tabName = "users",
      mod_manage_users_ui("manage_users_1")
    ),
    bs4TabItem(
      tabName = "leases",
      mod_leases_ui("leases_1")
    ),
    bs4TabItem(
      tabName = "properties",
      mod_properties_ui("properties_1")
    )
  )
)
)
}


