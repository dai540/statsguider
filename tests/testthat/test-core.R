testthat::test_that("independent continuous branch recommends Welch t-test", {
  dat <- data.frame(
    group = c(rep("control", 8), rep("treated", 8)),
    value = c(5.0, 5.2, 4.8, 5.1, 5.3, 4.9, 5.0, 5.4,
              6.1, 6.0, 5.8, 6.2, 6.3, 5.9, 6.1, 6.0)
  )

  decision <- statsguider::recommend_test(
    data = dat,
    outcome = "value",
    group = "group",
    goal = "difference",
    outcome_type = "continuous",
    paired = "no",
    repeated = "no",
    adjust = "no",
    normality = "yes"
  )

  testthat::expect_s3_class(decision, "statsguider_decision")
  testthat::expect_equal(decision$method_id, "welch_t")
})

testthat::test_that("adjusted branch redirects instead of forcing a simple test", {
  dat <- data.frame(
    group = c(rep("control", 6), rep("treated", 6)),
    value = c(1.1, 1.2, 1.0, 1.3, 1.4, 1.2, 1.7, 1.8, 1.6, 1.9, 1.8, 1.7)
  )

  decision <- statsguider::recommend_test(
    data = dat,
    outcome = "value",
    group = "group",
    goal = "difference",
    outcome_type = "continuous",
    adjust = "yes"
  )

  testthat::expect_equal(decision$action, "redirect")
})

testthat::test_that("run_test executes a categorical method", {
  dat <- data.frame(
    group = c("A", "A", "A", "A", "B", "B", "B", "B"),
    response = c("yes", "yes", "no", "yes", "no", "no", "no", "yes")
  )

  result <- statsguider::run_test(
    data = dat,
    outcome = "response",
    group = "group",
    goal = "difference",
    outcome_type = "binary",
    paired = "no",
    repeated = "no",
    adjust = "no"
  )

  testthat::expect_s3_class(result, "statsguider_result")
  testthat::expect_true(inherits(result$result, "htest"))
})
