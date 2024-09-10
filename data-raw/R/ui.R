bs4Dash::dashboardPage(
  title = "GMH Leasing Dashboard",
  bs4Dash::dashboardHeader(
    title = "GMH Leasing Dashboard"
  ),
  bs4Dash::dashboardSidebar(
    bs4Dash::sidebarMenu(
      bs4Dash::menuItem(
        text = "Home",
        tabName = "home",
        icon = icon("house")
      ),
      bs4Dash::menuItem(
        text = "Summary",
        tabName = "summary",
        icon = icon("magnifying-glass")
      ),
      bs4Dash::menuItem(
        text = "Properties",
        tabName = "properties",
        icon = icon("building-circle-check")
      ),
      bs4Dash::menuItem(
        text = "Leases",
        tabName = "leases",
        icon = icon("file-signature")
      ),
      bs4Dash::menuItem(
        text = "Reports",
        tabName = "reports",
        icon = icon("file-contract")
      )
    )
  ),
  bs4Dash::dashboardBody(
    bs4Dash::tabItem(
      tabName = "home"
    ),
    bs4Dash::tabItem(
      tabName = "summary"
    ),
    bs4Dash::tabItem(
      tabName = "properties"
    ),
    bs4Dash::tabItem(
      tabName = "leases"
    ),
    bs4Dash::tabItem(
      tabName = "reports"
    )
  )
)
