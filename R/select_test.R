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
  args <- normalize_analysis_args(
    language = language,
    goal = goal,
    paired = paired,
    repeated = repeated,
    adjust = adjust,
    outcome_type = outcome_type,
    normality = normality,
    run = run
  )

  if (args$run == "run") {
    return(run_test(
      data = data,
      outcome = outcome,
      group = group,
      id = id,
      goal = args$goal,
      paired = args$paired,
      repeated = args$repeated,
      adjust = args$adjust,
      outcome_type = args$outcome_type,
      normality = args$normality,
      language = args$language
    ))
  }

  recommend_test(
    data = data,
    outcome = outcome,
    group = group,
    id = id,
    goal = args$goal,
    paired = args$paired,
    repeated = args$repeated,
    adjust = args$adjust,
    outcome_type = args$outcome_type,
    normality = args$normality,
    language = args$language
  )
}
