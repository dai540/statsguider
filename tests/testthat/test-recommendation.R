library(statsguider)

test_that("continuous independent data recommend Welch t-test", {
  dat <- subset(wet_example, visit == "week4")
  dec <- recommend_test(dat, outcome = "biomarker", group = "group")
  expect_s3_class(dec, "statsguider_decision")
  expect_identical(dec$method_id, "welch_t")
})

test_that("select_test is the simple main entry point", {
  dat <- subset(wet_example, visit == "week4")
  dec <- select_test(
    dat,
    outcome = "biomarker",
    group = "group",
    outcome_type = "continuous",
    run = "recommend"
  )
  expect_s3_class(dec, "statsguider_decision")
  expect_identical(dec$method_id, "welch_t")
})

test_that("adjustment request redirects away from simple test", {
  dat <- subset(wet_example, visit == "week4")
  dec <- recommend_test(dat, outcome = "biomarker", group = "group", adjust = "yes")
  expect_identical(dec$action, "redirect")
})

test_that("guided mode works with scripted answers", {
  dat <- subset(wet_example, visit == "week4")
  dec <- guided_test(
    dat,
    answers = list(
      goal = "difference",
      outcome = "biomarker",
      group = "group",
      paired = "no",
      repeated = "no",
      adjust = "no",
      outcome_type = "continuous",
      normality = "yes"
    )
  )
  expect_identical(dec$method_id, "welch_t")
})

test_that("japanese output keeps a japanese method label", {
  dat <- subset(wet_example, visit == "week4")
  dec <- recommend_test(
    dat,
    outcome = "biomarker",
    group = "group",
    language = "ja"
  )
  expect_identical(dec$method_id, "welch_t")
  expect_true(grepl("検定|ANOVA", dec$method))
})

test_that("run_test returns a structured result", {
  dat <- subset(wet_example, visit == "week4")
  out <- run_test(dat, outcome = "biomarker", group = "group")
  expect_s3_class(out, "statsguider_result")
  expect_true(inherits(out$result, "htest"))
})
