% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Squaredloss.R
\name{squared_loss}
\alias{squared_loss}
\title{squared_loss}
\usage{
squared_loss(x, data, bandwidth, kernel_name = "gaussian")
}
\arguments{
\item{x}{the data to evaluate at (numeric/ vector)}

\item{data}{the data (numeric/ vector)}

\item{bandwidth}{A numerical value}

\item{kernel_name}{A string for the kernel used. Default is "gaussian"}
}
\value{
x a vector of x

bandwidth

squared_loss A vector of CRPS evaluate at x

average_loss: The mean of the CRPS
}
\description{
Compute the probabilistic squared loss
             for kernel pdf for a vector using a single bandwidth
}
\examples{
set.seed(1001)
data <- seq(0.1, 0.5, by = 0.1)
x <- c(0.1, 0.2, 0.3,  0.15)
bandwidth = 0.1
kernel_name = "gaussian"
squared_loss(x, data, bandwidth, kernel_name)
}
