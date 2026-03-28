#' Recommend a Statistical Test from Simple Data Properties
#'
#' Uses a rule-table driven engine to recommend a statistical test, request more
#' information, or stop an inappropriate branch.
#'
#' @param data A data frame.
#' @param outcome Name of the outcome column.
#' @param group Optional name of the group column.
#' @param id Optional subject identifier column.
#' @param goal Analysis goal. One of `"difference"`, `"association"`,
#'   `"adjusted_effect"`, `"time_to_event"`, `"agreement"`, or
#'   `"equivalence"`.
#' @param paired `"yes"` or `"no"`.
#' @param repeated `"yes"` or `"no"`.
#' @param adjust `"yes"` or `"no"`.
#' @param outcome_type Optional manual outcome type. One of `"continuous"`,
#'   `"binary"`, `"nominal"`, `"ordinal"`, or `"count"`. When `NULL`, it is
#'   guessed.
#' @param normality One of `"auto"`, `"yes"`, `"no"`, or `"unknown"`.
#' @param language `"en"` or `"ja"`.
#'
#' @return An object of class `statsguider_decision`.
#' @export
recommend_test <- function(data,
                           outcome,
                           group = NULL,
                           id = NULL,
                           goal = "difference",
                           paired = "no",
                           repeated = "no",
                           adjust = "no",
                           outcome_type = NULL,
                           normality = "auto",
                           language = "en") {
  language <- normalize_language(language)
  goal <- normalize_goal(goal)
  paired <- normalize_yes_no(paired, "paired")
  repeated <- normalize_yes_no(repeated, "repeated")
  adjust <- normalize_yes_no(adjust, "adjust")
  outcome_type <- normalize_outcome_type(outcome_type)
  normality <- normalize_normality(normality)

  design <- check_design(
    data = data,
    outcome = outcome,
    group = group,
    id = id,
    goal = goal,
    paired = paired,
    repeated = repeated,
    adjust = adjust,
    outcome_type = outcome_type,
    language = language
  )

  if (!design$ok) {
    stop(paste(design$issues, collapse = " "), call. = FALSE)
  }

  inferred_type <- design$inputs$outcome_type
  notes <- design$warnings
  actual_normality <- normality

  if (identical(normality, "auto") && inferred_type == "continuous") {
    actual_normality <- normality_flag(data[[outcome]], if (!is.null(group)) data[[group]] else NULL)
    notes <- c(notes, sg_text(language, "normality_note", actual_normality))
  }
  if (identical(actual_normality, "auto")) {
    actual_normality <- "unknown"
  }

  expected_small <- if (!is.null(group) && inferred_type %in% c("binary", "nominal")) {
    expected_count_small_flag(data[[outcome]], data[[group]])
  } else {
    "unknown"
  }

  inputs <- c(
    design$inputs,
    list(
      normality = actual_normality,
      expected_count_small = expected_small
    )
  )

  rules <- statsguider_rules()
  methods <- statsguider_methods()
  matched <- apply(rules, 1, function(row) {
    match_rule_value(row[["goal"]], inputs$goal) &&
      match_rule_value(row[["outcome_type"]], inputs$outcome_type) &&
      match_rule_value(row[["group_count"]], inputs$group_count) &&
      match_rule_value(row[["paired"]], inputs$paired) &&
      match_rule_value(row[["repeated"]], inputs$repeated) &&
      match_rule_value(row[["adjust"]], inputs$adjust) &&
      match_rule_value(row[["normality"]], inputs$normality) &&
      match_rule_value(row[["expected_count_small"]], inputs$expected_count_small)
  })

  if (!any(matched)) {
    return(structure(
      list(
        inputs = inputs,
        action = "need_more_info",
        method_id = NA_character_,
        method = NA_character_,
        alternative_method_id = NA_character_,
        alternative_method = NA_character_,
        title = sg_text(language, "no_rule_title"),
        reason = sg_text(language, "no_rule_reason"),
        next_step = sg_text(language, "no_rule_next"),
        notes = notes,
        language = language
      ),
      class = "statsguider_decision"
    ))
  }

  rule <- rules[which(matched)[1], , drop = FALSE]
  make_decision(inputs, rule[1, ], methods, notes, language = language)
}
