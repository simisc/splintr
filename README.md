
<!-- README.md is generated from README.Rmd. Please edit that file -->

# splintr

<!-- badges: start -->

[![check-standard](https://github.com/simisc/splintr/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/simisc/splintr/actions/workflows/check-standard.yaml)
[![DOI](https://zenodo.org/badge/141533742.svg)](https://zenodo.org/badge/latestdoi/141533742)
[![Licence](https://img.shields.io/github/license/simisc/splintr)](https://github.com/simisc/splintr/blob/master/LICENSE)
[![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
[![codecov](https://codecov.io/gh/simisc/splintr/branch/master/graph/badge.svg?token=U41V9KQ40I)](https://codecov.io/gh/simisc/splintr)
<!-- badges: end -->

Natural cubic splines with interpretable intercepts: ‘centres’ a basis
generated using `splines::ns()` on a specified x-value. When used in a
model formula, this allows the model intercept to be interpreted with
respect to that central x-value, rather than with respect to the x-value
of the first `splines::ns()` knot.

## Installation

You can install splintr from github with:

``` r
# install.packages("devtools")
devtools::install_github("simisc/splintr")
```

## Example

``` r
library(tidyverse)
library(splines)
library(splintr)
library(broom)
library(knitr)
library(ggthemes)
library(ggrepel)
```

``` r
women <- women %>%
  mutate(height_centred = height - mean(height))
women %>%
  head() %>%
  kable()
```

| height | weight | height\_centred |
| -----: | -----: | --------------: |
|     58 |    115 |             \-7 |
|     59 |    117 |             \-6 |
|     60 |    120 |             \-5 |
|     61 |    123 |             \-4 |
|     62 |    126 |             \-3 |
|     63 |    129 |             \-2 |

Different parametrisations of the same model:

  - `fit0`: using `ns` with raw heights
  - `fit1`: using `ns` with centred heights
  - `fit2`: using `splintr` with centred heights
  - `fit3`: using `splintr` with raw heights and explicit (arbitrary)
    centre

<!-- end list -->

``` r
model_formulae <- list(
  fit0 = weight ~ ns(height, df = 3),
  fit1 = weight ~ ns(height_centred, df = 3),
  fit2 = weight ~ splintr(height_centred, df = 3),
  fit3 = weight ~ splintr(height, df = 3, centre = explicit_centre)
)

explicit_centre = 68.45
model_fits <- map(model_formulae, lm, data = women)
```

The models are identical:

``` r
model_fits %>%
  map_dfr(glance, .id = "model") %>%
  select(model, sigma, logLik, deviance) %>%
  kable()
```

| model |    sigma |     logLik | deviance |
| :---- | -------: | ---------: | -------: |
| fit0  | 0.321018 | \-1.914046 | 1.133578 |
| fit1  | 0.321018 | \-1.914046 | 1.133578 |
| fit2  | 0.321018 | \-1.914046 | 1.133578 |
| fit3  | 0.321018 | \-1.914046 | 1.133578 |

But they have different intercepts:

``` r
model_fits %>%
  map_dfr(~tidy(.x, quick = TRUE), .id = "model") %>%
  filter(term == "(Intercept)") %>%
  select(model, estimate, std.error, statistic) %>%
  kable()
```

| model | estimate | std.error | statistic |
| :---- | -------: | --------: | --------: |
| fit0  | 114.5595 | 0.2455372 |  466.5666 |
| fit1  | 114.5595 | 0.2455372 |  466.5666 |
| fit2  | 135.1067 | 0.1288238 | 1048.7711 |
| fit3  | 147.8057 | 0.1513002 |  976.9034 |

Using `splines::ns()`, the model intercept represents the estimated
value of `weight` at the first boundary knot, i.e. when `height` takes
its minimum value of 58. This is unchanged by centring the predictor, so
`fit0` and `fit1` have identical intercepts.

Using `splintr()` instead, the intercept representes the estimated value
of `weight` when the predictor `height_centred` takes a value of zero.
An arbitrary “centre” can be specified directly in the `splintr()` call.

``` r
int_pts <- tibble(
  model = paste0("fit", 0:3),
  x = c(
    min(women$height),
    min(women$height),
    mean(women$height),
    explicit_centre
  ),
  y = map_dbl(model_fits, ~coef(.x)[1])
)

augment(model_fits[[1]], data = women) %>%
  ggplot(aes(x = height)) +
  geom_point(aes(y = weight)) +
  geom_line(aes(y = .fitted), col = "blue") +
  geom_point(data = int_pts, aes(x = x, y = y), col = "red") +
  geom_label_repel(data = int_pts, aes(x = x, y = y, label = model),
                   col = "red", nudge_y = 7) +
  theme_few()
```

<img src="man/figures/README-plotting-1.png" width="100%" />
