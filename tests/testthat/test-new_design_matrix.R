test_that("new_design_matrix works", {
  X <- matrix(c(4, 9, 2, 3, 5, 7, 8, 1, 6), ncol = 3, byrow = TRUE)
  X_ij  <- rbind(X[1,] - X[1,], # X_11
                 X[2,] - X[1,], # X_12
                 X[3,] - X[1,], # X_13
                 X[1,] - X[2,], # ...
                 X[2,] - X[2,],
                 X[3,] - X[2,],
                 X[1,] - X[3,],
                 X[2,] - X[3,],
                 X[3,] - X[3,])
  expect_equal(new_design_matrix(X), X_ij)
})
