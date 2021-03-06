% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{test_trees}
\alias{test_trees}
\title{test_trees}
\format{
dataframe:
\describe{
\item{cn}{tree cn}
\item{plt_cn}{plot cn}
\item{statuscd}{tree status code: 0 = dead, 1 = alive}
\item{spcd}{numeric FIA species code}
\item{common_name}{species common name}
\item{dbh}{diameter at breast height in inches}
\item{tpa_unadj}{trees per acre expansion factor for plot_cn}
\item{volcfgrs}{gross cubic foot volume as computed by FIA}
}
}
\source{
data-raw/test_trees.R
}
\usage{
test_trees
}
\description{
A dataframe containing a sample of measured trees from FIA plots in northern
Minnesota.
}
\keyword{datasets}
