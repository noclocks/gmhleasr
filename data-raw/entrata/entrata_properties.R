#  ------------------------------------------------------------------------
#
# Title : Entrata Properties Data Preparation
#    By : Jimmy Briggs
#  Date : 2024-08-17
#
#  ------------------------------------------------------------------------

entrata_properties <- entrata_properties() |>
  dplyr::mutate(
    property_website = ifelse(
      property_name == "Venue at North Campus",
      "https://www.venueatnorthcampus.com/",
      property_website
    ),
    property_email_mailto = paste0(
      "mailto:",
      property_email
    ),
    is_disabled = as.logical(is_disabled),
    is_featured = as.logical(is_featured),
    year_built = as.integer(year_built),
    address_full = paste0(
      address_street,
      ", ",
      address_city,
      ", ",
      address_state,
      " ",
      address_zip,
      ", ",
      address_country
    )
  )

qs::qsave(entrata_properties, "data-raw/cache/entrata_properties.qs")

property_embed_iframe <- function(
    property_name,
    gmaps_url,
    width = 800,
    height = 600,
    ...
) {

  htmltools::tags$div(
    class = "property-embed-iframe",
    htmltools::tags$h3(property_name),
    htmltools::tags$iframe(
      src = gmaps_url,
      width = width,
      height = height,
      style = "border:0;",
      allowfullscreen = "",
      loading = "lazy",
      referrerpolicy = "no-referrer-when-downgrade",
      ...
    )
  )

}

property_embed_iframe_str <- function(gmaps_api_key, address_full) {

  iframe <- glue::glue(
    "<iframe src='https://www.google.com/maps/embed/v1/place?key=",
    gmaps_api_key,
    "&q=",
    URLencode(address_full),
    "' width='800' height='600' style='border:0;' allowfullscreen='' loading='lazy' referrerpolicy='no-referrer-when-downgrade'></iframe>"
  )

  htmltools::HTML(
    iframe
  )

}

get_geocode_data <- function(address) {
  googleway::google_geocode(address = address, simplify = TRUE) |>
    purrr::pluck("results")
}

entrata_properties_map_data <- entrata_properties |>
  dplyr::mutate(
    map_url = paste0(
      "https://www.google.com/maps/embed/v1/place?key=",
      config::get("google_maps")$embed_api_key,
      "&q=",
      URLencode(address_full)
    ),
    map_iframe = purrr::map_chr(.data$address_full, function(x) {
      property_embed_iframe_str(
        .env$gmaps_api_key,
        x
      )
    }),
    map_geocode_data = purrr::map(address_full, get_geocode_data),
    map_place_id = purrr::map_chr(map_geocode_data, purrr::pluck, "place_id"),
    map_lat = purrr::map_dbl(map_geocode_data, purrr::pluck, "geometry", "location", "lat"),
    map_lon = purrr::map_dbl(map_geocode_data, purrr::pluck, "geometry", "location", "lng"),
    map_formatted_address = purrr::map_chr(map_geocode_data, purrr::pluck, "formatted_address"),
    map_info_title = property_name,
    map_info_html = glue::glue(
      "<div id='content'>",
      "<iframe width='450px' height='250px' frameborder='0' style='border:0'",
      "src={map_url}></iframe></div>"
    ),
    map_color = ifelse(is_featured, "red", "blue"),
    map_id = property_id,
    map_title = property_name,
    map_label = property_name,
    map_info_window = map_info_html
  )

library(googleway)
gmaps_api_key <- config::get("google_maps")$embed_api_key
googleway::set_key(gmaps_api_key)

style <- '[{"featureType":"all","elementType":"all","stylers":[{"invert_lightness":true},
{"saturation":10},{"lightness":30},{"gamma":0.5},{"hue":"#435158"}]},
{"featureType":"road.arterial","elementType":"all","stylers":[{"visibility":"simplified"}]},
{"featureType":"transit.station","elementType":"labels.text","stylers":[{"visibility":"off"}]}]'

googleway::google_map(
  data = entrata_properties_map_data,
  location = c(entrata_properties_map_data$map_lat, entrata_properties_map_data$map_lon),
  zoom = 12,
  min_zoom = 3,
  max_zoom = 18,
  map_bounds = c(-180, -90, 180, 90),
  width = "100%",
  height = "800px",
  padding = 0,
  # styles = style,
  search_box = TRUE,
  update_map_view = TRUE,
  zoom_control = TRUE,
  map_type = "roadmap",
  map_type_control = TRUE,
  scale_control = TRUE,
  street_view_control = TRUE,
  rotate_control = TRUE,
  fullscreen_control = TRUE,
  libraries = NULL,
  split_view = NULL,
  split_view_options = NULL,
  geolocation = TRUE,
  event_return_type = c("list", "json")
) |>
  add_markers(
    id = "property_id",
    # colour = "map_color",
    lat = "map_lat",
    lon = "map_lon",
    title = "map_title",
    label = "map_label",
    info_window = "map_info_window",
    mouse_over = "map_label",
    # marker_icon = "https://maps.google.com/mapfiles/ms/icons/blue-dot.png",
    layer_id = "properties",
    update_map_view = TRUE,
    focus_layer = TRUE,
    close_info_window = TRUE
  )




library(leaflet)
library(googleway)



lat <- 36.2844874
lon <- -106.8216307
zoom <- 3

m <- leaflet(data = entrata_properties) %>%
  setView(lng = lon, lat = lat, zoom = zoom) %>%
  addTiles() |>
  addMarkers()

m

googleway::google_map_url(center = c(lat, lon), zoom = zoom)





entrata_property_gmaps_urls <- function() {

  entrata_properties() |>
    dplyr::mutate(

    ) |>
    dplyr::pull(gmaps_url)

}






library(shiny)
library(googleway)
library(dplyr)

config <- config::get()
key <- config$gcp$gmaps_api_key
set_key(key = key)

vendor_locations <- readr::read_csv("shiny_app/data/vendor_locations.csv")



get_place_id <- function(address, ...) {
  res <- googleway::google_geocode(address = address, simplify = TRUE)
  res |>
    purrr::pluck("results", "place_id")
}

entrata_properties_enhanced <- entrata_properties |>
  dplyr::mutate(
    property_website = ifelse(
      property_name == "Venue at North Campus",
      "https://www.venueatnorthcampus.com/",
      property_website
    ),
    property_email_mailto = paste0(
      "mailto:",
      property_email
    ),
    is_disabled = as.logical(is_disabled),
    is_featured = as.logical(is_featured),
    year_built = as.integer(year_built),
    address_full = paste0(
      address_street,
      ", ",
      address_city,
      ", ",
      address_state,
      " ",
      address_zip,
      ", ",
      address_country
    ),
    gmaps_url = paste0(
      "https://www.google.com/maps/embed/v1/place?key=",
      gmaps_api_key,
      "&q=",
      URLencode(address_full)
    ),
    gmaps_iframe = purrr::map_chr(.data$address_full, function(x) {
      property_embed_iframe_str(
        .env$gmaps_api_key,
        x
      )
    }),
    geocode_data = purrr::map(address_full, get_geocode_data),
    place_id = purrr::map_chr(geocode_data, purrr::pluck, "place_id"),
    lat = purrr::map_dbl(geocode_data, purrr::pluck, "geometry", "location", "lat"),
    lon = purrr::map_dbl(geocode_data, purrr::pluck, "geometry", "location", "lng"),
    formatted_address = purrr::map_chr(geocode_data, purrr::pluck, "formatted_address"),
    map_info_title = property_name,
    map_info_html = glue::glue(
      "<div id='content'>",
      "<iframe width='450px' height='250px' frameborder='0' style='border:0'",
      "src={gmaps_url}></iframe></div>"
    )
  )

a <- googleway::google_geocode(address = entrata_properties$address_full[1], simplify = TRUE)
a$results$place_id

kml <- fs::path("~/Downloads/Properties.kml")
google_map() |> add_kml(kml_url = "https://www.google.com/maps/d/kml?forcekml=1&mid=19tP5Bf66khGcrNnqTBsk879W2fS-u7U&lid=Bi3XyG8fKdo")

# kml <- fs::path("data_prep/geodata/gadm36_KEN_3/gadm36_KEN_3.kml")

  # add_markers(
  #   lat = "lat",
  #   lon = "lon",
  #   title = "map_info_title",
  #   label = "property_name",
  #   layer_id = "properties",
  #   info_window = "map_info_html",
  #   mouse_over = "formatted_address",
  #   draggable = TRUE,
  #   cluster = TRUE,
  #   cluster_options = list(
  #     minimumClusterSize = 3
  #   ),
  #   update_map_view = TRUE
  # )
  # add_markers(
  #   lat = "lat",
  #   lon = "lon",
  #   title = "title",
  #   label = "vendor_name",
  #   layer_id = "vendor_locations",
  #   info_window = "info",
  #   mouse_over = "address",
  #   draggable = TRUE,
  #   cluster = TRUE,
  #   cluster_options = list(
  #     minimumClusterSize = 3
  #   ),
  #   update_map_view = TRUE
  # ) %>%
