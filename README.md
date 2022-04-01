
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
#>   0.067   0.010   0.075
obj$coef
#>         x1         x2 
#>  0.9365634 -1.9749170
obj$vcov
#>              x1           x2
#> x1  0.008789027 -0.007021569
#> x2 -0.007021569  0.015946303
```

Here is another example of “logit” PIM, and comparing with the {pim}
package. The `vcov` estimation is slightly different because {upim} uses
U-statistics-based asymptotic sandwich estimator, whereas the {pim}
package uses the “sparse correlation” theory based sandwich estimator.
They are, however, asymptotically equivalent.

``` r
# install.packages(c("pim", "evd"))
library(pim)
#> Loading pim version 2.0.2.
#>   If you want to try out the code from the original publications
#>   on probabilistic index models, please install the package 'pimold'
#>   from R-Forge. You can use following command:
#>   install.packages('pimold', repos = 'http://R-Forge.R-project.org')
library(evd)
set.seed(42)
n <- 200
a <- 1
b <- -2
x1 <- rnorm(n)
x2 <- rnorm(n)
# Gumbel error corresponds to a logit PIM. 
y <- a * x1 + b * x2 + rgumbel(n)
# Apply some arbitrary monotonic transformation to y.
mono_trans_y = pnorm(plogis(pnorm(y)))^2 + 1 
# upim 
system.time(upim.obj <- upim::pim_fit(y = mono_trans_y, X = cbind(x1, x2), link = "logit"))
#>    user  system elapsed 
#>   0.014   0.003   0.014
upim.obj$coef
#>         x1         x2 
#>  0.8868541 -1.8004009
upim.obj$vcov
#>              x1           x2
#> x1  0.008924131 -0.001844716
#> x2 -0.001844716  0.018828231
# pim 
system.time(pim.obj <- pim(y ~ x1 + x2, link = "logit"))
#>    user  system elapsed 
#>   0.014   0.001   0.016
pim.obj@coef
#>         x1         x2 
#>  0.8868582 -1.8004090
pim.obj@vcov
#>              x1          x2
#> x1  0.008531774 -0.00165584
#> x2 -0.001655840  0.01799113
```
