test_that("create_pseudo_obs works", {
  expect_equal(create_pseudo_obs(c(-1, 0, 1)),
               c(0.5, 1, 1, 0, 0.5, 1, 0, 0, 0.5))
})
