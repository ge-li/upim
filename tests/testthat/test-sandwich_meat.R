test_that("sandwich_meat works", {
  n <- 3
  p <- 2
  U <- matrix(rnorm(n^2 * p), ncol = p)
  U_i <- sapply(split.data.frame(U, rep(seq(n), each = n)), colSums) / n # p * n
  for (k in 1:n) {
    expect_equal(U_i[, k], colMeans(U[(k-1)*n + (1:n), ]))
  }
})
