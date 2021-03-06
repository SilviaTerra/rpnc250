% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{table4}
\alias{table4}
\title{table4}
\format{
dataframe:
\describe{
\item{species_group}{species group label from paper}
\item{stump_coef}{stump volume model coefficient for DBH term}
\item{bark_b0}{intercept term in bark volume model equation}
\item{bark_b1}{bark weight model coefficient for DBH term}
\item{biomass_lbs_per_ft3}{expected density conversion factor
(\eqn{lbs/ft^3}) for each species}
}
}
\source{
data-raw/tables.R
}
\usage{
table4
}
\description{
A dataframe containing coefficients for stump volume, bark corrections, and
biomass from Table 4 in the original publication.
}
\keyword{datasets}
