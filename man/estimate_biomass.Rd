% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eq.R
\name{estimate_biomass}
\alias{estimate_biomass}
\title{Estimate biomass}
\usage{
estimate_biomass(spcd, dbh, site_index, stand_basal_area)
}
\arguments{
\item{spcd}{vector of FIA species codes}

\item{dbh}{vector of DBH observations in inches}

\item{site_index}{vector of site index estimates (base age 50)}

\item{stand_basal_area}{vector of stand-level basal area estimates
corresponding to the stems}
}
\value{
estimates of biomass in tons
}
\description{
Estimate green tons of biomass to a given top diameter following the system
outlined in the original publication. Biomass of the bole (stem + stump),
bark, and top are summed to obtain an estimate of the total biomass.
}
\examples{
estimate_biomass(
  spcd = c(541, 371, 95, 73),
  dbh = c(10, 11, 12, 13),
  site_index = c(60, 65, 60, 70),
  stand_basal_area = 80
)

}
