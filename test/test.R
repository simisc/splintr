library(splines)
library(splintr)

?splintr
x <- seq(-46, 38, by = 1.34)
x

a <- ns(x, 3)
b <- splintr(x, 3)

matplot(x, a)
matplot(x, b)

y <- 4 * x + x ^ 2 - (x + 50) ^ 1.5 + rnorm(x, 0, 140) + runif(x)
plot(x, y)

f <- lm(y ~ ns(x, 3))
g <- lm(y ~ splintr(x, 3))

anova(f, g)
summary(f)
summary(g)

lines(x[14:37], predict(f, newdata = data.frame(x = x[14:37])))
lines(x[14:37], 200 + predict(g, newdata = data.frame(x = x[14:37])), col = "red")

predict(g, newdata = data.frame(x = 0)) # same as intercept

splintr
predict(b) # no applicable method
predict(splintr(x, 3), 18:40)
predict(ns(x, 3), 18:40)

?splintr
