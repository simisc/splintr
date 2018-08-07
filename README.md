
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

``` r
library(broom)   # tidy(), augment()
library(knitr)   # kable()
library(ggplot2) # ggplot()
library(splines) # ns()
library(splintr) # splintr()
```

Using `splines::ns()` in a model formula as below, the model intercept represents the estimated value of `weight` at the first boundary knot, i.e. when `height` takes its minimum value of 58.

``` r
kable(tidy(fm0 <- lm(weight ~ ns(height, df = 3), data = women), quick = TRUE))
```

| term                |   estimate|
|:--------------------|----------:|
| (Intercept)         |  114.55946|
| ns(height, df = 3)1 |   23.87318|
| ns(height, df = 3)2 |   53.04162|
| ns(height, df = 3)3 |   41.66370|

``` r
attr(ns(women$height, df = 3), "Boundary.knots")
#> [1] 58 72
predict(fm0, newdata = data.frame(height = 0))
#>         1 
#> -49.06522
predict(fm0, newdata = data.frame(height = 58))
#>        1 
#> 114.5595
ggplot(augment(fm0, data = women), aes(x = height)) +
  geom_point(aes(y = weight)) +
  geom_line(aes(y = .fitted), col = "blue") +
  geom_point(data = NULL, aes(x = 58, y = coef(fm0)[1]), col = "red")
```

![](README-unnamed-chunk-3-1.png)

Centring the predictor does not change the model intercept.

``` r
women$height_centred <- women$height - mean(women$height)
kable(tidy(fm1 <- lm(weight ~ ns(height_centred, df = 3), data = women), quick = TRUE))
```

| term                         |   estimate|
|:-----------------------------|----------:|
| (Intercept)                  |  114.55946|
| ns(height\_centred, df = 3)1 |   23.87318|
| ns(height\_centred, df = 3)2 |   53.04162|
| ns(height\_centred, df = 3)3 |   41.66370|

``` r
attr(ns(women$height_centred, df = 3), "Boundary.knots")
#> [1] -7  7
predict(fm1, newdata = data.frame(height_centred = 0))
#>        1 
#> 135.1067
predict(fm1, newdata = data.frame(height_centred = -7))
#>        1 
#> 114.5595
ggplot(augment(fm1, data = women), aes(x = height_centred)) +
  geom_point(aes(y = weight)) +
  geom_line(aes(y = .fitted), col = "blue") +
  geom_point(data = NULL, aes(x = -7, y = coef(fm1)[1]), col = "red")
```

![](README-unnamed-chunk-4-1.png)

Using `splintr()` instead, the intercept representes the estimated value of `weight` when the predictor `height_centred` takes a value of zero.

``` r
kable(tidy(fm2 <- lm(weight ~ splintr(height_centred, df = 3), data = women), quick = TRUE))
```

| term                              |   estimate|
|:----------------------------------|----------:|
| (Intercept)                       |  135.10672|
| splintr(height\_centred, df = 3)1 |   23.87318|
| splintr(height\_centred, df = 3)2 |   53.04162|
| splintr(height\_centred, df = 3)3 |   41.66370|

``` r
attr(splintr(women$height_centred, df = 3), "Boundary.knots")
#> [1] -7  7
predict(fm2, newdata = data.frame(height_centred = 0))
#>        1 
#> 135.1067
predict(fm2, newdata = data.frame(height_centred = -7))
#>        1 
#> 114.5595
ggplot(augment(fm2, data = women), aes(x = height_centred)) +
  geom_point(aes(y = weight)) +
  geom_line(aes(y = .fitted), col = "blue") +
  geom_point(data = NULL, aes(x = 0, y = coef(fm2)[1]), col = "red")
```

![](README-unnamed-chunk-5-1.png)

Alternatively, a new centre can be specified directly in the `splintr()` call.

``` r
x_centre = 68.45
kable(tidy(fm3 <- lm(weight ~ splintr(height, df = 3, centre = x_centre), data = women), quick = TRUE))
```

| term                                         |   estimate|
|:---------------------------------------------|----------:|
| (Intercept)                                  |  147.80566|
| splintr(height, df = 3, centre = x\_centre)1 |   23.87318|
| splintr(height, df = 3, centre = x\_centre)2 |   53.04162|
| splintr(height, df = 3, centre = x\_centre)3 |   41.66370|

``` r
attr(splintr(women$height, df = 3, centre = x_centre), "Boundary.knots")
#> [1] 58 72
predict(fm3, newdata = data.frame(height = x_centre))
#>        1 
#> 147.8057
ggplot(augment(fm2, data = women), aes(x = height)) +
  geom_point(aes(y = weight)) +
  geom_line(aes(y = .fitted), col = "blue") +
  geom_point(data = NULL, aes(x = x_centre, y = coef(fm3)[1]), col = "red")
```

![](README-unnamed-chunk-6-1.png)

The three models fit identically:

``` r
t(rbind(
  fm0 = glance(fm0),
  fm1 = glance(fm1),
  fm2 = glance(fm2),
  fm3 = glance(fm3)
))
#>                         fm0           fm1           fm2           fm3
#> r.squared      9.996629e-01  9.996629e-01  9.996629e-01  9.996629e-01
#> adj.r.squared  9.995710e-01  9.995710e-01  9.995710e-01  9.995710e-01
#> sigma          3.210180e-01  3.210180e-01  3.210180e-01  3.210180e-01
#> statistic      1.087406e+04  1.087406e+04  1.087406e+04  1.087406e+04
#> p.value        2.254442e-19  2.254442e-19  2.254442e-19  2.254442e-19
#> df             4.000000e+00  4.000000e+00  4.000000e+00  4.000000e+00
#> logLik        -1.914046e+00 -1.914046e+00 -1.914046e+00 -1.914046e+00
#> AIC            1.382809e+01  1.382809e+01  1.382809e+01  1.382809e+01
#> BIC            1.736834e+01  1.736834e+01  1.736834e+01  1.736834e+01
#> deviance       1.133578e+00  1.133578e+00  1.133578e+00  1.133578e+00
#> df.residual    1.100000e+01  1.100000e+01  1.100000e+01  1.100000e+01
```
