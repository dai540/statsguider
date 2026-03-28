choose_value <- function(prompt, choices, answers = NULL, key = NULL, language = "en") {
  if (!is.null(answers) && !is.null(key) && !is.null(answers[[key]])) {
    return(answers[[key]])
  }
  if (!interactive()) {
    stop(sprintf(sg_text(language, "noninteractive_answer"), key), call. = FALSE)
  }
  selection <- utils::menu(choices, title = prompt)
  if (selection < 1L) {
    stop(sg_text(language, "guided_cancel"), call. = FALSE)
  }
  choices[[selection]]
}

choose_column <- function(prompt, data, answers = NULL, key = NULL, allow_null = FALSE, language = "en") {
  if (!is.null(answers) && !is.null(key) && !is.null(answers[[key]])) {
    return(answers[[key]])
  }
  if (!interactive()) {
    stop(sprintf(sg_text(language, "noninteractive_answer"), key), call. = FALSE)
  }
  choices <- names(data)
  if (allow_null) {
    choices <- c(sg_text(language, "none"), choices)
  }
  selection <- utils::menu(choices, title = prompt)
  if (selection < 1L) {
    stop(sg_text(language, "guided_cancel"), call. = FALSE)
  }
  value <- choices[[selection]]
  if (allow_null && identical(value, sg_text(language, "none"))) NULL else value
}

#' Guide a User Through Simple Test Selection
#'
#' Starts a simple branching workflow. In interactive sessions the function asks
#' a small number of questions. In scripts, the same answers can be supplied as
#' a named list.
#'
#' @param data A data frame.
#' @param answers Optional named list of answers for non-interactive use.
#' @param run One of `"recommend"` or `"run"`.
#' @param language `"en"` or `"ja"`.
#'
#' @return A `statsguider_decision` object, or a `statsguider_result` object when
#'   `run = "run"`.
#' @export
guided_test <- function(data, answers = NULL, run = "recommend", language = "en") {
  language <- normalize_language(language)
  run <- normalize_run_mode(run)

  if (!is.data.frame(data)) {
    stop(sg_text(language, "data_must_be_df"), call. = FALSE)
  }

  goal <- choose_value(
    sg_text(language, "prompt_goal"),
    c("difference", "association", "adjusted_effect", "time_to_event", "agreement", "equivalence"),
    answers = answers,
    key = "goal",
    language = language
  )
  outcome <- choose_column(sg_text(language, "prompt_outcome"), data, answers, "outcome", language = language)
  group <- choose_column(sg_text(language, "prompt_group"), data, answers, "group", allow_null = TRUE, language = language)
  paired <- choose_value(sg_text(language, "prompt_paired"), c("no", "yes"), answers, "paired", language = language)
  repeated <- choose_value(sg_text(language, "prompt_repeated"), c("no", "yes"), answers, "repeated", language = language)
  adjust <- choose_value(sg_text(language, "prompt_adjust"), c("no", "yes"), answers, "adjust", language = language)

  id <- NULL
  if (paired == "yes" || repeated == "yes") {
    id <- choose_column(sg_text(language, "prompt_id"), data, answers, "id", language = language)
  }

  outcome_type_default <- guess_outcome_type(data[[outcome]])
  outcome_type <- choose_value(
    sprintf(sg_text(language, "prompt_outcome_type"), outcome_type_default),
    c(outcome_type_default, "continuous", "binary", "nominal", "ordinal", "count"),
    answers = answers,
    key = "outcome_type",
    language = language
  )

  normality <- "auto"
  if (outcome_type == "continuous") {
    normality <- choose_value(
      sg_text(language, "prompt_normality"),
      c("auto", "yes", "no", "unknown"),
      answers = answers,
      key = "normality",
      language = language
    )
  }

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
