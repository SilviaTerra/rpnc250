% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{table3}
\alias{table3}
\title{table3}
\format{
dataframe:
\describe{
\item{species_group}{species group label from paper}
\item{n}{number of trees in fitting data}
\item{b0}{intercept term in volume model equation}
\item{b1}{volume model coefficient for DBH term}
\item{std_err}{standard error (board feet) of model estimates for each
species}
\item{br2}{\eqn{R^2}: coefficient of determination for the species-level
model}
\item{growing_stock_cull_pct}{expected percent of gross volume that is cull
for growing stock trees}
\item{short_log_cull_pct}{expected percent of gross volume that is cull for
short log trees}
}
}
\source{
data-raw/tables.R
}
\usage{
table3
}
\description{
A dataframe containing volume model coefficients for board foot volume from
Table 3 in the original publication.
}
\keyword{datasets}
