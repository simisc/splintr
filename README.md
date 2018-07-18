
<!-- README.md is generated from README.Rmd. Please edit that file -->
splintr
=======

Natural cubic splines with interpretable intercepts: 'centres' a basis generated using `splines::ns()` on a specified x-value. When used in a model formula, this allows the model intercept to be interpreted with respect to that central x-value, rather than with respect to the x-value of the first `splines::ns()` knot.

Installation
------------

You can install splintr from github with:

``` r
# install.packages("devtools")
devtools::install_github("simisc/splintr")
```

Example
-------

Using `splines::ns()` in a model formula as below, the model intercept represents the estimated value of `weight` at the first boundary knot, i.e. when `height` takes its minimum value of 58. Centring the predictor does not change the model intercept.

``` r
library(splines)
library(broom)
tidy(fm1 <- lm(weight ~ ns(height, df = 5), data = women))
#>                  term  estimate std.error statistic      p.value
#> 1         (Intercept) 114.74466 0.2337541 490.87766 3.076416e-21
#> 2 ns(height, df = 5)1  15.94736 0.3698567  43.11767 9.691543e-12
#> 3 ns(height, df = 5)2  25.16949 0.4322604  58.22761 6.546364e-13
#> 4 ns(height, df = 5)3  33.25822 0.3540711  93.93089 8.908069e-15
#> 5 ns(height, df = 5)4  50.78938 0.6061996  83.78327 2.489882e-14
#> 6 ns(height, df = 5)5  45.03633 0.2784267 161.75289 6.707973e-17
attr(ns(women$height, df = 5), "Boundary.knots")
#> [1] 58 72
predict(fm1, newdata = data.frame(height = 58))
#>        1 
#> 114.7447
women$height_centred <- women$height - mean(women$height)
tidy(fm2 <- lm(weight ~ ns(height_centred, df = 5), data = women))
#>                          term  estimate std.error statistic      p.value
#> 1                 (Intercept) 114.74466 0.2337541 490.87766 3.076416e-21
#> 2 ns(height_centred, df = 5)1  15.94736 0.3698567  43.11767 9.691543e-12
#> 3 ns(height_centred, df = 5)2  25.16949 0.4322604  58.22761 6.546364e-13
#> 4 ns(height_centred, df = 5)3  33.25822 0.3540711  93.93089 8.908069e-15
#> 5 ns(height_centred, df = 5)4  50.78938 0.6061996  83.78327 2.489882e-14
#> 6 ns(height_centred, df = 5)5  45.03633 0.2784267 161.75289 6.707973e-17
attr(ns(women$height_centred, df = 5), "Boundary.knots")
#> [1] -7  7
predict(fm2, newdata = data.frame(height_centred = -7))
#>        1 
#> 114.7447
```

Using `splintr()` instead, the intercept representes the estimated value of `weight` when the predictor `height_centred` takes a value of zero. Alternatively, a new centre can be specified directly in the `splintr()` call.

``` r
library(splintr)
tidy(fm3 <- lm(weight ~ splintr(height_centred, df = 5), data = women))
#>                               term  estimate std.error statistic
#> 1                      (Intercept) 135.33595 0.1402826 964.73789
#> 2 splintr(height_centred, df = 5)1  15.94736 0.3698567  43.11767
#> 3 splintr(height_centred, df = 5)2  25.16949 0.4322604  58.22761
#> 4 splintr(height_centred, df = 5)3  33.25822 0.3540711  93.93089
#> 5 splintr(height_centred, df = 5)4  50.78938 0.6061996  83.78327
#> 6 splintr(height_centred, df = 5)5  45.03633 0.2784267 161.75289
#>        p.value
#> 1 7.033470e-24
#> 2 9.691543e-12
#> 3 6.546364e-13
#> 4 8.908069e-15
#> 5 2.489882e-14
#> 6 6.707973e-17
attr(splintr(women$height_centred, df = 5), "Boundary.knots")
#> [1] -7  7
predict(fm3, newdata = data.frame(height_centred = 0))
#>       1 
#> 135.336
tidy(fm4 <- lm(weight ~ splintr(height, df = 5, centre = 63.4), data = women))
#>                                      term  estimate std.error statistic
#> 1                             (Intercept) 130.16388 0.1704543 763.62922
#> 2 splintr(height, df = 5, centre = 63.4)1  15.94736 0.3698567  43.11767
#> 3 splintr(height, df = 5, centre = 63.4)2  25.16949 0.4322604  58.22761
#> 4 splintr(height, df = 5, centre = 63.4)3  33.25822 0.3540711  93.93089
#> 5 splintr(height, df = 5, centre = 63.4)4  50.78938 0.6061996  83.78327
#> 6 splintr(height, df = 5, centre = 63.4)5  45.03633 0.2784267 161.75289
#>        p.value
#> 1 5.766345e-23
#> 2 9.691543e-12
#> 3 6.546364e-13
#> 4 8.908069e-15
#> 5 2.489882e-14
#> 6 6.707973e-17
attr(splintr(women$height, df = 5, centre = 63.4), "Boundary.knots")
#> [1] 58 72
predict(fm4, newdata = data.frame(height = 63.4))
#>        1 
#> 130.1639
```
