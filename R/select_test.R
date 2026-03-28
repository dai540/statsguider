#' Select and Optionally Run a Statistical Test
#'
#' This is the simplest entry point in `statsguider`. You describe the data
#' properties, and the function either recommends a method or runs it.
#'
#' @inheritParams recommend_test
#' @param run One of `"recommend"` or `"run"`.
#'
#' @return A `statsguider_decision` object when `run = FALSE`, or a
#'   `statsguider_result` object when `run = "run"`.
#' @export
select_test <- function(data,
                        outcome,
                        group = NULL,
                        id = NULL,
                        goal = "difference",
                        paired = "no",
                        repeated = "no",
                        adjust = "no",
                        outcome_type = NULL,
                        normality = "auto",
                        run = "run",
                        language = "en") {
  language <- normalize_language(language)
  goal <- normalize_goal(goal)
  paired <- normalize_yes_no(paired, "paired")
  repeated <- normalize_yes_no(repeated, "repeated")
  adjust <- normalize_yes_no(adjust, "adjust")
  outcome_type <- normalize_outcome_type(outcome_type)
  normality <- normalize_normality(normality)
  run <- normalize_run_mode(run)

  if (run == "run") {
    return(run_test(
      data = data,
      outcome = outcome,
      group = group,
      id = id,
      goal = goal,
      paired = paired,
      repeated = repeated,
      adjust = adjust,
      outcome_type = outcome_type,
      normality = normality,
      language = language
    ))
  }

  recommend_test(
    data = data,
    outcome = outcome,
    group = group,
    id = id,
    goal = goal,
    paired = paired,
    repeated = repeated,
    adjust = adjust,
    outcome_type = outcome_type,
    normality = normality,
    language = language
  )
}
