<h1 align="center">GMH Leasing Package - <code>gmhleasr</code></h1>

<p align="center"><a href="CHANGELOG.md">Changelog</a>  &middot;  <a href="https://docs.noclocks.dev/gmhleasr/">Documentation</a>  &middot;  <a href="https://docs.noclocks.dev/gmhleasr/develop/">Development Documentation</a></p>

<p align="center">
  <img src="man/figures/logo.png" width="200px" height="auto" alt="hexlogo"/>
</p>

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&pause=1000&center=true&vCenter=true&multiline=true&width=450&height=80&lines=GMH+Leasing+Dashboard;Built+by+No+Clocks%2C+LLC"/>
</p>

***

> [!NOTE]
> This is an R package built by [No Clocks, LLC](https://noclocks.dev) for [GMH Communities](https://gmhcommunities.com) for managing and maintaining a Shiny application to visualize and report on Leasing Data, as well as interact with the Entrata API.

***

## Contents

- [Contents](#contents)
- [Badges](#badges)
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)

## Badges

<!-- badges: start -->
[![Automate Changelog](https://github.com/noclocks/gmhleasr/actions/workflows/changelog.yml/badge.svg)](https://github.com/noclocks/gmhleasr/actions/workflows/changelog.yml)
[![Code Style](https://github.com/noclocks/gmhleasr/actions/workflows/style.yml/badge.svg)](https://github.com/noclocks/gmhleasr/actions/workflows/style.yml)
[![Lint](https://github.com/noclocks/gmhleasr/actions/workflows/lint.yml/badge.svg)](https://github.com/noclocks/gmhleasr/actions/workflows/lint.yml)
[![Document (Roxygen)](https://github.com/noclocks/gmhleasr/actions/workflows/roxygen.yml/badge.svg)](https://github.com/noclocks/gmhleasr/actions/workflows/roxygen.yml)
[![pkgdown](https://github.com/noclocks/gmhleasr/actions/workflows/pkgdown.yml/badge.svg)](https://github.com/noclocks/gmhleasr/actions/workflows/pkgdown.yml)
[![Pkgdown Multi](https://github.com/noclocks/gmhleasr/actions/workflows/pkgdown-multi.yml/badge.svg)](https://github.com/noclocks/gmhleasr/actions/workflows/pkgdown-multi.yml)
[![Dependabot Updates](https://github.com/noclocks/gmhleasr/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/noclocks/gmhleasr/actions/workflows/dependabot/dependabot-updates)
[![R CMD Check](https://github.com/noclocks/gmhleasr/actions/workflows/check.yml/badge.svg?branch=main)](https://github.com/noclocks/gmhleasr/actions/workflows/check.yml)
[![Test Coverage](https://github.com/noclocks/gmhleasr/actions/workflows/coverage.yml/badge.svg)](https://github.com/noclocks/gmhleasr/actions/workflows/coverage.yml)
<!-- badges: end -->

## Overview

The `gmhleasr` package (version 0.1.0) provides a set of tools for GMH Communities Leasing, including a Shiny dashboard for data visualization and reporting, as well as a robust API client for interacting with the Entrata API. This package simplifies the process of retrieving, analyzing, and visualizing leasing data for GMH Communities.

## Features

- **Entrata API Integration**: Easy-to-use functions for authenticating and interacting with the Entrata API.
- **Data Retrieval**: Specialized functions for fetching property, lease, and report data from Entrata.
- **Shiny Dashboard**: A customizable dashboard for visualizing leasing data and generating reports.
- **Caching**: Efficient caching mechanisms to improve performance and reduce API calls.
- **Error Handling**: Robust error handling and logging for API interactions.

## Installation

You can install the development version of `gmhleasr` from GitHub:

```R
# Install using remotes
remotes::install_github("noclocks/gmhleasr")

# Or using devtools
devtools::install_github("noclocks/gmhleasr")

# Or using pak
pak::pkg_install("noclocks/gmhleasr")
```

After installation, you'll need to set up your Entrata API configuration. Create a `config.yml` file in your project directory with the following structure:

```yaml
default:
  entrata:
    username: "your_username"
    password: "your_password"
    base_url: "https://your-subdomain.entrata.com"
```

## Usage

Here are some basic examples of how to use the main functions in `gmhleasr`:

```R
library(gmhleasr)

# Create an Entrata API configuration
config <- create_entrata_config()

# Get a list of properties
properties <- entrata_properties(config = config)

# Get lease information for a specific property
leases <- entrata_leases(property_id = "12345", config = config)

# Get a list of available reports
reports <- get_entrata_reports_list(config = config)

# Run the Shiny dashboard
run_app()
```

For more detailed usage instructions and examples, please refer to the package documentation and vignettes.

## Documentation

- View the [CHANGELOG](CHANGELOG.md) for the latest updates.
- Visit the [Package Documentation Website](https://docs.noclocks.dev/gmhleasr/) for full documentation of all functions and features.
- Visit the [Development Package Documentation Website](https://docs.noclocks.dev/gmhleasr/develop/) for the latest development version documentation.

***

© 2024 [No Clocks, LLC](https://noclocks.dev)
