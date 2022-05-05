
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
#>   0.072   0.010   0.080
obj$coef
#>         x1         x2 
#>  0.9365686 -1.9749280
obj$vcov
#>              x1           x2
#> x1  0.008789200 -0.007021797
#> x2 -0.007021797  0.015946758
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
#>  0.8868582 -1.8004090
upim.obj$vcov
#>              x1           x2
#> x1  0.008924222 -0.001844803
#> x2 -0.001844803  0.018828545
# pim 
system.time(pim.obj <- pim(mono_trans_y ~ x1 + x2, link = "logit"))
#>    user  system elapsed 
#>   0.014   0.001   0.015
pim.obj@coef
#>         x1         x2 
#>  0.8868582 -1.8004090
pim.obj@vcov
#>              x1          x2
#> x1  0.008531774 -0.00165584
#> x2 -0.001655840  0.01799113
```

## Other Features

### Show Iteration Reports

``` r
upim::pim_fit(y = mono_trans_y, X = cbind(x1, x2), link = "logit", trace = TRUE)
#> **Showing nleqslv::nleqslv() iteration report**
#>   Columns:
#>   --------
#>   Jac - Jacobian type (reciprocal condition number); N: Newton Jacobian; B: Broyden updated matrix
#>   Lambda - Line search parameter
#>   Fnorm - Fnorm square of the euclidean norm of function values / 2
#>   Largest |f| - Infinity norm of f(x) at the current point
#> 
#>   Algorithm parameters
#>   --------------------
#>   Method: Newton  Global strategy: none
#>   Maximum stepsize = 1.79769e+308
#>   Scaling: fixed
#>   ftol = 1.49012e-08 xtol = 1.49012e-08 btol = 0.001 cndtol = 1.49012e-08
#> 
#>   Iteration report
#>   ----------------
#>   Iter         Jac   Lambda          Fnorm   Largest |f|
#>      0                        1.110197e-01  4.033866e-01
#>      1  N(8.0e-01)   1.0000   7.368250e-03  1.049548e-01
#>      2  N(5.4e-01)   1.0000   6.095238e-04  3.016787e-02
#>      3  N(3.3e-01)   1.0000   1.771673e-05  5.144305e-03
#>      4  N(2.5e-01)   1.0000   3.431860e-08  2.265142e-04
#>      5  N(2.4e-01)   1.0000   1.588323e-13  4.874870e-07
#>      6  N(2.4e-01)   1.0000   3.437348e-24  2.268370e-12
#> 
#>   Results:
#>   --------
#>   Convergence achieved: PIM estimating function value is within tolerance.
#> $coef
#>         x1         x2 
#>  0.8868582 -1.8004090 
#> 
#> $jac
#>            x1          x2
#> x1 -0.1910663 -0.05952050
#> x2 -0.0595205 -0.08956385
#> 
#> $vcov
#>              x1           x2
#> x1  0.008924222 -0.001844803
#> x2 -0.001844803  0.018828545
#> 
#> $link
#> [1] "logit"
```

### Test Global Strategies for Newton’s Method

``` r
test_res <- upim::pim_fit(y = mono_trans_y, X = cbind(x1, x2), link = "logit", test.nleqslv = TRUE)
#>   ----------------
#> Test different methods for solving with `nleqlsv::testnslv()`:
#> Message:
#> Fcrit - Convergence of function values has been achieved.
#> Xcrit - This means that the relative distance between two consecutive x-values is smaller than xtol.
#> Stalled - The algorithm cannot find an acceptable new point.
#> Maxiter - Iteration limit maxit exceeded.
#> Illcond - Jacobian is too ill-conditioned.
#> Singular - Jacobian is singular.
#> BadJac - Jacobian is unusable.
#>   Method Global termcd Fcnt Jcnt Iter Message        Fnorm  Largest |f|
#> 1 Newton   none      1    6    6    6   Fcrit 3.428553e-24 2.618608e-12
#> 2 Newton  cline      1    6    6    6   Fcrit 3.428553e-24 2.618608e-12
#> 3 Newton  qline      1    6    6    6   Fcrit 3.428553e-24 2.618608e-12
#> 4 Newton  gline      1    6    6    6   Fcrit 3.428553e-24 2.618608e-12
#> 5 Newton pwldog      1    6    6    6   Fcrit 3.428553e-24 2.618608e-12
#> 6 Newton dbldog      1    6    6    6   Fcrit 3.428553e-24 2.618608e-12
#> 7 Newton   hook      1    6    6    6   Fcrit 3.428553e-24 2.618608e-12
```
