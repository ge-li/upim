test_that("preceq works", {
  expect_equal(object = preceq(x = c(0, 0, 0), y = c(-1, 0, 1)),
               expected = c(0, 0.5, 1))
})
