# R Package Development Guide

>   [!NOTE]
>
>   *This document serves the purpose of providing R developers at ***No Clocks, LLC** thorough guidelines on R package development.*

## Contents

[TOC]

## Introduction



## Initialization

```mermaid
```



-   Create Package
-   Add `NAMESPACE`
-   Add `DESCRIPTION`
    -   Add Title & Description
    -   Add initial development version (`0.0.0.9999`)
    -   Add `Authors@R` (Jimmy, Patrick, No Clocks)
    -   Add License
    -   Add `roxygen2`
    -   Add `testthat` Configuration (`Config/testthat/edition: 3`)
-   Initialize `git`
-   Initialize `github`
-   Add `.Rbuildignore`
    -   Add `.gitignore` (build ignore)
    -   Add `.gitattributes` (build ignore)
    -   Add `.editorconfig` (build ignore)
-   License
-   README
-   `.github`
-   `.vscode`
-   `.git/hooks/*`
-   `inst/*`
-   Add vignettes
-   Add tests
-   Add functions
-   Add `examples`
-   