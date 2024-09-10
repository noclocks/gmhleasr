
#  ------------------------------------------------------------------------
#
# Title : NOCLOCKS_ENCRYPTION_KEY
#    By : Jimmy Briggs
#  Date : 2024-06-25
#
#  ------------------------------------------------------------------------

# This script generates the global NOCLOCKS_ENCRYPTION_KEY.
# This secret key is used as the primary encryption key for all No Clocks
# secret/config data. It should be stored as an environment variable or in
# the operating system's keyring and kept secure and not shared with anyone.

key_name <- "NOCLOCKS_ENCRYPTION_KEY"
key <- httr2::secret_make_key()
key

# Save the key to an environment variable
Sys.setenv("NOCLOCKS_ENCRYPTION_KEY" = key)

# Verify
Sys.getenv(key_name) == key

# Add to .Renviron
r_environ_path <- fs::path_expand(Sys.getenv("R_ENVIRON_USER"))
cat(sprintf("\n%s=%s\n", key_name, key), file = r_environ_path, append = TRUE)

# Verify
lines <- readLines(r_environ_path)
lines[[length(lines)]] == paste0(key_name, "=", key)

# Add to keyring
if (keyring::has_keyring_support()) {
  if (!("noclocks" %in% keyring::keyring_list()$keyring)) {
    keyring::keyring_create("noclocks")
  }
  noclocks_keyring_keys <- keyring::key_list(keyring = "noclocks")$service
  if (!("encryption_key" %in% noclocks_keyring_keys)) {
    keyring::key_set_with_value(
      service = "encryption_key",
      password = key,
      keyring = "noclocks"
    )
  } else {
    keyring_key <- keyring::key_get(
      "encryption_key",
      keyring = "noclocks"
    )
    if (keyring_key != key) {
      keyring::key_delete("encryption_key", keyring = "noclocks")
      keyring::key_set_with_value(
        service = "encryption_key",
        password = key,
        keyring = "noclocks"
      )
    }
  }
}

# Verify
if (keyring::has_keyring_support()) {
  keyring::key_get("encryption_key", keyring = "noclocks") == key
}

# save to noclocks.key
key_file <- "noclocks.key"
cfg_dir <- fs::path_package(
  package = pkgload::pkg_name(),
  "config"
)
key_file_path <- fs::path(cfg_dir, key_file)
cat(key, file = key_file_path, append = FALSE)

# Restart R session to load the new environment variable
if (rstudioapi::isAvailable(version_needed = "1.2.1261")) {
  invisible(rstudioapi::executeCommand("restartR", quiet = TRUE))
}

if (rstudioapi::isAvailable(version_needed = "1.2.1261")) {
  invisible(rstudioapi::executeCommand("reloadUi", quiet = TRUE))
}

# Verify both environment variable and keyring are set

# get key from keyfile
key <- readLines(
  fs::path_package(
    package = pkgload::pkg_name(),
    "config",
    "noclocks.key"
  )
)[[1]]

Sys.getenv("NOCLOCKS_ENCRYPTION_KEY") == key

if (keyring::has_keyring_support()) {
  keyring::key_get("encryption_key", keyring = "noclocks") == key
}
