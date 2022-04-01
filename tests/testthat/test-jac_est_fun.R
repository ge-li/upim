test_that("d_res_fun works", {
  # Place holder, true tests are under.
  expect_equal(2 * 2, 4)
})

# bar <- function(y, x, link) {
#   ddnorm <- function(x) {
#     # derivative of dnorm(x)
#     -exp(-x ^ 2 / 2) * x / sqrt(2 * pi)
#   }
#   if (link == "logit") {
#     # I've worked out the math
#     res <- -dlogis(x)
#   } else if (link == "probit") {
#     f <- pnorm(x)
#     df <- dnorm(x)
#     ddf <- ddnorm(x)
#     tmp <- pnorm(-abs(x)) * (1 - pnorm(-abs(x)))
#     res <- ((2 * y * f - y - f^2) * df^2 + tmp * ddf * (y - f)) / (tmp^2)
#   }
#   res
# }
#
#
# x <- seq(-20, 20, by = 0.001)
# plot(x, bar(1, x, "probit"), type = "l")
# lines(x, bar(0, x, "probit"), type = "l")
# lines(x, bar(0.5, x, "probit"), type = "l")
#
# plot(x, bar(1, x, "logit"), type = "l")
# plot(x, bar(0, x, "logit"), type = "l")
# plot(x, bar(0.5, x, "logit"), type = "l")
# plot(x, -dlogis(x), type = "l")
