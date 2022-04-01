test_that("pim_fit works", {
  # Place holder, actual tests are below.
  expect_equal(2 * 2, 4)
})

# # # ----- Test logit link ----
# set.seed(42)
# pim_test_runs = pbapply::pbreplicate(1000, {
#   df <- dgp_rct(n = 200, p_c = 1, error_dist = "gumbel")
#   obj <- pim_fit(df$y, df[c("a", "x1", "x2")], link = "logit")
#   c(obj$coef, sqrt(diag(obj$vcov)))
# }, simplify = F)
# # |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=19s
# df <- data.frame(do.call(rbind, pim_test_runs))
# names(df) <- c("a", "x1", "x2", "a_se", "x1_se", "x2_se")
# boxplot(df[, 1:3])
# abline(h = c(1, 0.5, -0.7), lty = 2)
# see <- apply(df[, 4:6], 2, function(x){sqrt(mean(x^2))})
# se <- apply(df[, 1:3], 2, sd)
# rel_error <- (see - se) / se * 100
# results <- data.frame(see, se, rel_error)
# row.names(results) <- c("a", "x1", "x2")
# results
# # > results
# #           see        se  rel_error
# # a  0.18952854 0.1914813 -1.0198141
# # x1 0.09663308 0.1006619 -4.0023027
# # x2 0.10304584 0.1037120 -0.6423007

# # # ----- Test probit link -----
# set.seed(42)
# pim_test_runs = pbapply::pbreplicate(1000, {
#   df <- dgp_rct(n = 200, p_c = 1, error_dist = "normal")
#   obj <- pim_fit(df$y, df[c("a", "x1", "x2")], link = "probit")
#   c(obj$coef, sqrt(diag(obj$vcov)))
# }, simplify = F)
# # |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=01m 05s
# df <- data.frame(do.call(rbind, pim_test_runs))
# names(df) <- c("a", "x1", "x2", "a_se", "x1_se", "x2_se")
# boxplot(df[, 1:3])
# abline(h = c(1, 0.5, -0.7), lty = 2)
# see <- apply(df[, 4:6], 2, function(x){sqrt(mean(x^2))})
# se <- apply(df[, 1:3], 2, sd)
# rel_error <- (see - se) / se * 100
# results <- data.frame(see, se, rel_error)
# row.names(results) <- c("a", "x1", "x2")
# results
# # > results
# #           see         se  rel_error
# # a  0.11747174 0.11628470  1.0208052
# # x1 0.05965732 0.06221224 -4.1067885
# # x2 0.06552190 0.06599793 -0.7212743
