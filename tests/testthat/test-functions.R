context("Compare splintr with ns")

library(splines)
library(splintr)

m0 <- lm(weight ~ ns(height, df = 5), data = women)
m1 <- lm(weight ~ splintr(height, df = 5), data = women)
m2 <- lm(weight ~ splintr(height, df = 5, centre = 67.23), data = women)

test_that("models have the same deviance", {
  expect_equal(deviance(m0), deviance(m1))
  expect_equal(deviance(m0), deviance(m2))
})

test_that("models have the same residuals", {
  expect_equal(resid(m0), resid(m2))
  expect_equal(resid(m0), resid(m2))
})

test_that("models generate the same predictions", {
  expect_equal(predict(m0), predict(m1))
  expect_equal(predict(m0), predict(m2))
})
