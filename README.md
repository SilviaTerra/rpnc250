
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rpnc250

<!-- badges: start -->

[![R-CMD-check](https://github.com/SilviaTerra/rpnc250/workflows/R-CMD-check/badge.svg)](https://github.com/SilviaTerra/rpnc250/actions)
[![Codecov test
coverage](https://codecov.io/gh/SilviaTerra/rpnc250/branch/main/graph/badge.svg)](https://codecov.io/gh/SilviaTerra/rpnc250?branch=main)
<!-- badges: end -->

The goal of rpnc250 is to provide R functions that produce height,
volume, and biomass estimates using the equations and coefficients from
USFS Research Paper NC-250: Tree volume and biomass equations for the
Lake States.

Citation for publication: Hahn, Jerold T. 1984. Tree volume and biomass
equations for the Lake States. Research Paper NC-250. St. Paul, MN: U.S.
Dept. of Agriculture, Forest Service, North Central Forest Experiment
Station

The original publication can be accessed from the [U.S. Forest
Service](https://www.fs.usda.gov/treesearch/pubs/10037).

The equations and species-specific coefficients were copied out of the
PDF version of the publication by Henry Rodman in January 2021. The
tables are [stored in csv format](inst/csv/) in the R package and have
been [translated into package data objects](data-raw/tables.R) for use
in the internal functions.

The functions for estimating height, volume, and biomass have been
[tested](tests/testthat/test-eq.R) to align with the examples provided
in the original publication.

## Installation

You can install the latest version of rpnc250 from Github with:

``` r
remotes::install_github("SilviaTerra/rpnc250", ref = "main")
```

## Examples

Here are some examples to show a few ways to work with the functions:

First, load a few packages.

``` r
library(rpnc250)
library(magrittr)
```

The package has a set of test trees pulled from some FIA data in
northern Minnesota ([source code](data-raw/test_trees.R)).

``` r
head(test_trees)
#>               cn         plt_cn statuscd spcd  common_name dbh tpa_unadj ht
#> 1 65340991010661 65340894010661        1   95 black spruce 1.5  74.96528 NA
#> 2 65340995010661 65340894010661        1   95 black spruce 1.5  74.96528 NA
#> 3 65340999010661 65340894010661        1   95 black spruce 2.8  74.96528 NA
#> 4 65341003010661 65340894010661        1   95 black spruce 1.9  74.96528 NA
#> 5 65341007010661 65340894010661        1   95 black spruce 2.7  74.96528 NA
#> 6 65341011010661 65340894010661        1   95 black spruce 2.0  74.96528 NA
#>   volcfgrs
#> 1       NA
#> 2       NA
#> 3       NA
#> 4       NA
#> 5       NA
#> 6       NA
```

The height equation includes stand basal area as a covariate, so we can
summarize FIA plot-level (four subplots combined) basal area to use for
that purpose. For simplicity, we will assume that site index is constant
for all of the plot locations.

``` r
# summarize plot-level basal area
plot_ba <- test_trees %>%
  dplyr::filter(
    !is.na(dbh),
    !is.na(tpa_unadj),
    statuscd == 1
  ) %>%
  dplyr::group_by(
    plt_cn # FIA plot IDs
  ) %>%
  dplyr::summarize(
    bapa = sum(tpa_unadj * 0.005454 * dbh^2),
    .groups = "drop"
  )

# filter the trees and join to plot basal area table
trees_prepped <- test_trees %>%
  dplyr::filter(
    !is.na(dbh),
    statuscd == 1, # only live trees
    !is.na(tpa_unadj)
  ) %>%
  dplyr::left_join(
    plot_ba,
    by = "plt_cn"
  )
```

### Merchantable height

The height equation in the publication generates estimates of height to
a given top diameter (outside bark) provided species, DBH (inches), site
index, and stand basal area.

To estimate height to 4" top we can apply the function
`estimate_height`:

``` r
# clone prepped tree dataframe
ht_trees <- trees_prepped

ht_trees$height_4 <- estimate_height(
  spcd = ht_trees$spcd,
  dbh = ht_trees$dbh,
  site_index = 65,
  top_dob = 4,
  stand_basal_area = ht_trees$bapa
)
```

It is also possible to use the functions within `dplyr::mutate` calls
which facilitates clean data wrangling workflows.

``` r

ht_trees <- trees_prepped %>%
  dplyr::mutate(
    height_4 = estimate_height(
      spcd = spcd,
      dbh = dbh,
      site_index = 65,
      top_dob = 4,
      stand_basal_area = bapa
    )
  )
```

### Cubic feet

We can summarize total merchantable volume up to 4" top very easily.
First, join the plot-level basal area table to the tree table, then
estimate height to 4" top for each stem. Using those estimates as inputs
to the volume equations we can estimate stem-level volumes.

``` r
merch_cuft_4 <- trees_prepped %>%
  dplyr::mutate(
    height_4 = estimate_height(
      spcd = spcd,
      dbh = dbh,
      site_index = 65,
      top_dob = 4,
      stand_basal_area = bapa
    ),
    gross_cuft_vol = estimate_volume(
      spcd = spcd,
      dbh = dbh,
      height = height_4,
      vol_type = "cuft"
    )
  )

# plot relationship between diameter and gross volume
merch_cuft_4 %>%
  ggplot2::ggplot(
    ggplot2::aes(
      x = dbh,
      y = gross_cuft_vol,
      color = common_name
    )
  ) +
  ggplot2::geom_point() +
  ggplot2::labs(
    x = "DBH (inches)",
    y = "gross volume to 4\" top (cubic ft)",
    color = "species"
  )
#> Warning: Removed 106 rows containing missing values (geom_point).
```

<img src="man/figures/README-cuft-1.png" width="100%" />

### Board feet

To get merchantable volume in board feet (Int’l 1/4) we can set the
merchantable height to 9" for softwood trees, and 10" for hardwood
trees. You and I both know that the large aspen are probably not
destined for sawtimber products, but we can dream.

``` r
# make table of spcd and hardwood/softwood assignment
spp_groups <- tidyFIA::ref_tables[["species"]] %>%
  dplyr::transmute(
    spcd,
    class = dplyr::case_when(
      major_spgrpcd %in% c(1, 2) ~ "softwood",
      major_spgrpcd %in% c(3, 4) ~ "hardwood"
    )
  )

merch_bdft <- trees_prepped %>%
  dplyr::left_join(
    spp_groups,
    by = "spcd"
  ) %>%
  dplyr::mutate(
    top_dob = dplyr::case_when(
      class == "hardwood" ~ 10,
      class == "softwood" ~ 9
    )
  ) %>%
  dplyr::filter(
    dbh >= top_dob + 1 # make sure dbh is at least as big as top dob
  ) %>%
  dplyr::mutate(
    merch_height = estimate_height(
      spcd = spcd,
      dbh = dbh,
      site_index = 65,
      top_dob = top_dob,
      stand_basal_area = bapa
    ),
    gross_bdft_vol = estimate_volume(
      spcd = spcd,
      dbh = dbh,
      height = merch_height,
      vol_type = "bdft"
    )
  )

merch_bdft %>%
  ggplot2::ggplot(
    ggplot2::aes(
      x = dbh,
      y = gross_bdft_vol,
      color = common_name
    )
  ) +
  ggplot2::geom_point() +
  ggplot2::labs(
    x = "DBH (inches)",
    y = "gross volume (board ft)",
    color = "species"
  )
```

<img src="man/figures/README-bdft-1.png" width="100%" />

### Biomass

The publication outlines a process for obtaining estimates of green tons
of biomass. This method differs from the methods used by FIA so keep
that in mind if you are attempting to immitate the FIA methodology. The
[FIA methods](https://www.nrs.fs.fed.us/pubs/39555) use the gross cubic
foot volume equations and coefficients from this publication but use a
different process for converting the bole volume estimate into biomass.

``` r
trees_with_biomass <- trees_prepped %>%
  dplyr::mutate(
    biomass = estimate_biomass(
      spcd = spcd,
      dbh = dbh,
      site_index = 65,
      stand_basal_area = bapa
    )
  )

trees_with_biomass %>%
  ggplot2::ggplot(
    ggplot2::aes(
      x = dbh,
      y = biomass,
      color = common_name
    )
  ) +
  ggplot2::geom_point() +
  ggplot2::labs(
    x = "DBH (inches)",
    y = "biomass (green tons)",
    color = "species"
  )
```

<img src="man/figures/README-biomass-1.png" width="100%" />
