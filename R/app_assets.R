#  ------------------------------------------------------------------------
#
# Title : App Assets
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------

# assets ------------------------------------------------------------------

#' App Assets
#'
#' @description Update the app's `resourcePath` and add bundled, static assets,
#'   making them available to the app's interface for downstream use.
#'
#' @details This function is used to add the app's favicon, bundle the app's
#'   assets, add various `<meta>` tags, and include necessary external libraries
#'   and shiny related packages to the app.
#'
#'   By default it will perform the following actions:
#'
#' - Update the app's `resourcePath` to include this package's `assets/`
#'   directory via [shiny::addResourcePath()].
#' - Add the favicon to the app's `<head>` via [app_favicon()].
#' - Bundle and include app static assets as an [htmltools::htmlDependency()]
#'   via [bundle_app_assets()].
#'
#'   plus, it will include the following packages:
#'
#' - Include `shinyjs` via [shinyjs::useShinyjs()].
#' - Include `shinyFeedback` via [shinyFeedback::useShinyFeedback()].
#' - Include `waiter` via [waiter::useWaiter()].
#'
#'
#' @param ... Additional arguments (currently unused)
#'
#' @return `<head>` with app assets configured
#'
#' @export
#'
#' @seealso [app_favicon()], [bundle_app_assets()], [shiny::addResourcePath()],
#'   [shinyjs::useShinyjs()], [shinyFeedback::useShinyFeedback()],
#'   [waiter::useWaiter()]
#'
#' @importFrom shiny addResourcePath
#' @importFrom htmltools tags
#' @importFrom shinyjs useShinyjs
#' @importFrom shinyFeedback useShinyFeedback
#' @importFrom waiter useWaiter
app_assets <- function(...) {
  htmltools::tags$head(
    app_meta(),
    app_favicon(),
    bundle_app_assets(),
    shinyjs::useShinyjs(),
    shinyFeedback::useShinyFeedback(feedback = FALSE)
    # rintrojs::useRintrojs()
  )
}

# <meta> ------------------------------------------------------------------

#' App `<meta>`
#'
#' @description
#' Creates a series of `<meta>` tags for the app's `<head>`.
#'
#' @param package Name of the package
#' @param app_name Name of the app
#' @param app_version Version of the app
#' @param description Description of the app
#' @param url URL of the app
#' @param theme_color Theme color of the app
#' @param robots Robots.txt policy
#' @param generator Generator of the app
#' @param subject Subject of the app
#' @param rating Rating of the app
#' @param referrer Referrer policy
#' @param csp Content Security Policy
#' @param image Image URL
#' @param image_alt Image alt text
#' @param twitter_creator Twitter creator
#' @param twitter_card_type Twitter card type
#' @param twitter_site Twitter site
#' @param ... Additional arguments (currently unused)
#'
#' @seealso [metathis::meta()]
#'
#' @return Raw `<meta>` tags via [metathis::meta()] (to be passed into the
#'   app's `<head>`)
#'
#' @export
#'
#' @importFrom metathis meta meta_viewport meta_general meta_tag meta_name meta_social
app_meta <- function(
    package = "gmhleasr",
    app_name = "GMH Leasing Dashboard",
    app_version = utils::packageVersion("gmhleasr"),
    description = desc::desc_get("Description")[[1]],
    url = "https://noclocks.dev",
    theme_color = "#0073AA",
    robots = "index,follow",
    generator = "RShiny",
    subject = "GMH Leasing Dashboard",
    rating = "General",
    referrer = "origin",
    csp = "default-src 'self'",
    image = "https://cdn.brandfetch.io/noclocks.dev/symbol",
    image_alt = "No Clocks, LLC Logo",
    twitter_creator = "@noclocksdev",
    twitter_card_type = "summary_large_image",
    twitter_site = "@noclocksdev",
    ...) {
  metathis::meta() |>
    metathis::meta_viewport(maximum_scale = 1) |>
    metathis::meta_general(
      application_name = app_name,
      theme_color = theme_color,
      description = description,
      robots = robots,
      generator = generator,
      subject = subject,
      rating = rating,
      referrer = referrer
    ) |>
    metathis::meta_tag(
      "http-equiv" = "Content-Security-Policy",
      "content" = csp
    ) |>
    metathis::meta_name(
      "package" = package,
      "version" = app_version
    ) |>
    metathis::meta_social(
      title = app_name,
      description = description,
      url = url,
      image = image,
      image_alt = image_alt,
      twitter_creator = twitter_creator,
      twitter_card_type = twitter_card_type,
      twitter_site = twitter_site
    )
}


# favicon -----------------------------------------------------------------

#' App Favicon
#'
#' @description
#' Add the app favicon to the app by inserting HTML tags into the app's `<head>`.
#'
#' @details
#' The path to the favicon file should utilize the pre-configured *resourcePath*,
#' i.e. `"www/*"`, to ensure the favicon is accessible to the app.
#'
#' The `www` prefixed path is instantiated in the [app_assets()] function which
#' gets called in the `<head>` of the main [app_ui()] function.
#'
#' @param path The path to the favicon file. See details for more information
#'   on how to set this path. Default is `www/images/favicons/favicon.ico`,
#'   which is specific to this package.
#'
#' @return `<head>` with necessary favicon declaration
#'
#' @export
#'
#' @importFrom htmltools tags
#' @importFrom cli cli_abort
app_favicon <- function(
    path = app_sys("favicon.ico")) {
  if (!file.exists(path)) {
    cli::cli_abort(
      "Failed to find favicon at provided path: {.path {path}}"
    )
  }

  htmltools::tags$head(
    htmltools::tags$link(
      rel = "shortcut icon",
      type = "image/x-icon",
      href = path
    )
  )
}

# logo --------------------------------------------------------------------

#' App Logo
#'
#' @param path Path to the logo file
#' @param alt Alt text for the logo
#' @param style CSS style for the logo
#'
#' @return HTML image tag with the provided logo
#' @export
#'
#' @importFrom htmltools tags
#' @importFrom cli cli_abort
app_logo <- function(
    path = "public/images/logos/gmh-logo.svg",
    alt = "GMH Communities",
    style = "width: 250px; height: auto;") {
  if (!file.exists(path)) {
    cli::cli_abort(
      "Failed to find logo at provided path: {.path {path}}"
    )
  }

  htmltools::tags$img(
    src = path,
    alt = alt,
    style = style
  )
}
