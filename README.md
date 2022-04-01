
<!-- README.md is generated from README.Rmd. Please edit that file -->

# upim

<!-- badges: start -->
<!-- badges: end -->

This package is a U-statistics based implementation of the Probabilistic
Index Models (PIM) proposed by Thas et al. (2012). It supports weighted
PIM estimation, which is not implemented in the original authors’ {pim}
package. It’s also more efficient and light-weight.

## Installation

You can install the development version of upim from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ge-li/upim")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(upim)
set.seed(42)
n <- 200
a <- 1
b <- -2
x1 <- rnorm(n)
x2 <- rnorm(n)
# Normal error corresponds to a probit PIM. 
y <- a * x1 + b * x2 + rnorm(n, sd = 1 / sqrt(2))
# Apply some arbitrary monotonic transformation to y.
mono_trans_y = pnorm(plogis(pnorm(y)))^2 + 1 
system.time(obj <- pim_fit(y = mono_trans_y, X = cbind(x1, x2), link = "probit"))
#>    user  system elapsed 
#>   0.068   0.010   0.075
obj$coef
#>         x1         x2 
#>  0.9365634 -1.9749170
obj$vcov
#>              x1           x2
#> x1  0.008789027 -0.007021569
#> x2 -0.007021569  0.015946303
```
