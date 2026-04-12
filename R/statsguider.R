#' Validate a Simple Group-Comparison Design
#'
#' `check_design()` validates whether an analysis fits the narrow branching
#' workflow implemented by `statsguider`. The function checks the presence of
#' required columns, infers simple data properties, and reports issues and
#' warnings before recommendation or execution.
#'
#' @param data A `data.frame`.
#' @param outcome Name of the outcome column.
#' @param group Optional name of the group column.
#' @param id Optional name of the subject identifier column.
#' @param goal One of `"difference"`, `"association"`, `"adjusted_effect"`,
#'   `"time_to_event"`, `"agreement"`, or `"equivalence"`.
#' @param outcome_type One of `"auto"`, `"continuous"`, `"binary"`,
#'   `"nominal"`, `"ordinal"`, or `"count"`.
#' @param paired `"yes"` or `"no"`.
#' @param repeated `"yes"` or `"no"`.
#' @param adjust `"yes"` or `"no"`.
#'
#' @return A named list with `ok`, `issues`, `warnings`, and `inputs`.
#' @export
check_design <- function(data,
                         outcome,
                         group = NULL,
                         id = NULL,
                         goal = c("difference", "association", "adjusted_effect", "time_to_event", "agreement", "equivalence"),
                         outcome_type = c("auto", "continuous", "binary", "nominal", "ordinal", "count"),
                         paired = c("no", "yes"),
                         repeated = c("no", "yes"),
                         adjust = c("no", "yes")) {
  goal <- match.arg(goal)
  outcome_type <- match.arg(outcome_type)
  paired <- normalize_yes_no(paired)
  repeated <- normalize_yes_no(repeated)
  adjust <- normalize_yes_no(adjust)

  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  issues <- character()
  warnings <- character()

  if (!is.character(outcome) || length(outcome) != 1L || !nzchar(outcome)) {
    issues <- c(issues, "`outcome` must be a single column name.")
  } else if (!outcome %in% names(data)) {
    issues <- c(issues, sprintf("Outcome column `%s` was not found.", outcome))
  }

  if (!is.null(group) && !group %in% names(data)) {
    issues <- c(issues, sprintf("Group column `%s` was not found.", group))
  }

  if (!is.null(id) && !id %in% names(data)) {
    issues <- c(issues, sprintf("ID column `%s` was not found.", id))
  }

  if (length(issues)) {
    return(list(ok = FALSE, issues = issues, warnings = warnings, inputs = NULL))
  }

  inferred_type <- if (identical(outcome_type, "auto")) guess_outcome_type(data[[outcome]]) else outcome_type
  group_count <- if (is.null(group)) 0L else length(unique(stats::na.omit(data[[group]])))

  if (identical(goal, "difference") && is.null(group)) {
    issues <- c(issues, "A group column is required for group comparisons.")
  }

  if (identical(goal, "difference") && !is.null(group) && group_count < 2L) {
    issues <- c(issues, "At least two non-missing group levels are required.")
  }

  if (identical(paired, "yes") && is.null(id)) {
    issues <- c(issues, "Paired analyses require an `id` column.")
  }

  if (identical(repeated, "yes") && is.null(id)) {
    issues <- c(issues, "Repeated-measures analyses require an `id` column.")
  }

  if (identical(goal, "association")) {
    warnings <- c(warnings, "Association questions are redirected to correlation or regression workflows.")
  }

  if (identical(goal, "adjusted_effect") || identical(adjust, "yes")) {
    warnings <- c(warnings, "Adjusted analyses should move to regression or mixed-effects models.")
  }

  if (identical(goal, "time_to_event")) {
    warnings <- c(warnings, "Time-to-event outcomes should move to Kaplan-Meier or Cox workflows.")
  }

  if (identical(goal, "agreement")) {
    warnings <- c(warnings, "Agreement questions should move to ICC, Bland-Altman, or kappa workflows.")
  }

  if (identical(goal, "equivalence")) {
    warnings <- c(warnings, "Equivalence and non-inferiority questions need dedicated margins and methods.")
  }

  if (identical(inferred_type, "count")) {
    warnings <- c(warnings, "Count outcomes should usually move to Poisson or negative binomial regression.")
  }

  if (identical(paired, "yes") && !is.null(group) && group_count != 2L && identical(repeated, "no")) {
    warnings <- c(warnings, "Paired execution is limited to exactly two conditions.")
  }

  list(
    ok = length(issues) == 0L,
    issues = issues,
    warnings = unique(warnings),
    inputs = list(
      goal = goal,
      outcome_type = inferred_type,
      group_count = collapse_group_count(group_count),
      paired = if (identical(repeated, "yes")) "no" else paired,
      repeated = repeated,
      adjust = adjust
    )
  )
}

#' Recommend a Statistical Test
#'
#' `recommend_test()` applies the package's simple branching logic and returns a
#' structured decision object.
#'
#' @inheritParams check_design
#' @param normality One of `"auto"`, `"yes"`, `"no"`, or `"unknown"`.
#'
#' @return An object of class `statsguider_decision`.
#' @export
recommend_test <- function(data,
                           outcome,
                           group = NULL,
                           id = NULL,
                           goal = c("difference", "association", "adjusted_effect", "time_to_event", "agreement", "equivalence"),
                           outcome_type = c("auto", "continuous", "binary", "nominal", "ordinal", "count"),
                           paired = c("no", "yes"),
                           repeated = c("no", "yes"),
                           adjust = c("no", "yes"),
                           normality = c("auto", "yes", "no", "unknown")) {
  goal <- match.arg(goal)
  outcome_type <- match.arg(outcome_type)
  paired <- normalize_yes_no(paired)
  repeated <- normalize_yes_no(repeated)
  adjust <- normalize_yes_no(adjust)
  normality <- match.arg(normality)

  design <- check_design(
    data = data,
    outcome = outcome,
    group = group,
    id = id,
    goal = goal,
    outcome_type = outcome_type,
    paired = paired,
    repeated = repeated,
    adjust = adjust
  )

  if (!design$ok) {
    return(make_decision(
      action = "stop",
      method = NA_character_,
      alternative = NA_character_,
      reason = paste(design$issues, collapse = " "),
      next_step = "Fix the design inputs and run the check again.",
      notes = design$warnings,
      inputs = NULL
    ))
  }

  inputs <- design$inputs
  notes <- design$warnings

  if (!identical(inputs$goal, "difference")) {
    return(make_redirect_decision(inputs$goal, notes, inputs))
  }

  if (identical(inputs$adjust, "yes")) {
    return(make_decision(
      action = "redirect",
      method = NA_character_,
      alternative = NA_character_,
      reason = "The design requests covariate adjustment, so a simple unadjusted test is not the right main analysis.",
      next_step = "Move to regression or mixed-effects models.",
      notes = notes,
      inputs = inputs
    ))
  }

  if (identical(inputs$outcome_type, "count")) {
    return(make_decision(
      action = "redirect",
      method = NA_character_,
      alternative = NA_character_,
      reason = "Count outcomes are outside the simple test branch used by this package.",
      next_step = "Move to Poisson or negative binomial regression.",
      notes = notes,
      inputs = inputs
    ))
  }

  actual_normality <- normality
  if (identical(inputs$outcome_type, "continuous") && identical(normality, "auto")) {
    actual_normality <- infer_normality(data[[outcome]], if (!is.null(group)) data[[group]] else NULL)
    notes <- c(notes, sprintf("Normality was checked automatically and classified as `%s`.", actual_normality))
  }
  if (identical(actual_normality, "auto")) {
    actual_normality <- "unknown"
  }

  if (identical(inputs$repeated, "yes")) {
    return(decide_repeated_branch(data, outcome, group, inputs, actual_normality, notes))
  }

  if (identical(inputs$paired, "yes")) {
    return(decide_paired_branch(data, outcome, group, inputs, actual_normality, notes))
  }

  decide_independent_branch(data, outcome, group, inputs, actual_normality, notes)
}

#' Run the Recommended Statistical Test
#'
#' `run_test()` runs the base-R method selected by `recommend_test()`. If the
#' branch is redirected or stopped, the function terminates with the reason
#' reported by the decision object.
#'
#' @inheritParams recommend_test
#'
#' @return An object of class `statsguider_result`.
#' @export
run_test <- function(data,
                     outcome,
                     group = NULL,
                     id = NULL,
                     goal = c("difference", "association", "adjusted_effect", "time_to_event", "agreement", "equivalence"),
                     outcome_type = c("auto", "continuous", "binary", "nominal", "ordinal", "count"),
                     paired = c("no", "yes"),
                     repeated = c("no", "yes"),
                     adjust = c("no", "yes"),
                     normality = c("auto", "yes", "no", "unknown")) {
  decision <- recommend_test(
    data = data,
    outcome = outcome,
    group = group,
    id = id,
    goal = goal,
    outcome_type = outcome_type,
    paired = paired,
    repeated = repeated,
    adjust = adjust,
    normality = normality
  )

  if (!decision$action %in% c("recommend", "recommend_with_warning")) {
    stop(paste(decision$reason, decision$next_step), call. = FALSE)
  }

  result <- switch(
    decision$method_id,
    welch_t = stats::t.test(stats::as.formula(paste(outcome, "~", group)), data = data, var.equal = FALSE),
    paired_t = {
      paired_data <- make_paired_vectors(data, outcome, group, id)
      stats::t.test(paired_data$x, paired_data$y, paired = TRUE)
    },
    mann_whitney = stats::wilcox.test(stats::as.formula(paste(outcome, "~", group)), data = data, exact = FALSE),
    wilcoxon_signed_rank = {
      paired_data <- make_paired_vectors(data, outcome, group, id)
      stats::wilcox.test(paired_data$x, paired_data$y, paired = TRUE, exact = FALSE)
    },
    welch_anova = stats::oneway.test(stats::as.formula(paste(outcome, "~", group)), data = data, var.equal = FALSE),
    kruskal_wallis = stats::kruskal.test(stats::as.formula(paste(outcome, "~", group)), data = data),
    repeated_anova = stats::aov(stats::as.formula(paste(outcome, "~", group, "+ Error(", id, "/", group, ")")), data = data),
    friedman = stats::friedman.test(stats::as.formula(paste(outcome, "~", group, "|", id)), data = data),
    chisq_test = stats::chisq.test(table(data[[group]], data[[outcome]], useNA = "no")),
    fisher_exact = stats::fisher.test(table(data[[group]], data[[outcome]], useNA = "no")),
    mcnemar = {
      paired_data <- make_paired_vectors(data, outcome, group, id)
      stats::mcnemar.test(table(paired_data$x, paired_data$y, useNA = "no"))
    },
    stop(sprintf("Method `%s` is not executable in this version.", decision$method_id), call. = FALSE)
  )

  structure(
    list(
      decision = decision,
      result = result,
      summary = sprintf(
        "%s was selected for a %s outcome with %s groups.",
        decision$method,
        decision$inputs$outcome_type,
        decision$inputs$group_count
      )
    ),
    class = "statsguider_result"
  )
}

#' Select and Optionally Run a Test
#'
#' `select_test()` is the shortest wrapper in the package. It accepts the same
#' arguments as `recommend_test()`, plus a `run` choice that decides whether the
#' function only recommends a method or executes it immediately.
#'
#' @inheritParams recommend_test
#' @param run Either `"recommend"` or `"run"`.
#'
#' @return A `statsguider_decision` object or a `statsguider_result` object.
#' @export
select_test <- function(data,
                        outcome,
                        group = NULL,
                        id = NULL,
                        goal = c("difference", "association", "adjusted_effect", "time_to_event", "agreement", "equivalence"),
                        outcome_type = c("auto", "continuous", "binary", "nominal", "ordinal", "count"),
                        paired = c("no", "yes"),
                        repeated = c("no", "yes"),
                        adjust = c("no", "yes"),
                        normality = c("auto", "yes", "no", "unknown"),
                        run = c("recommend", "run")) {
  run <- match.arg(run)

  if (identical(run, "run")) {
    return(run_test(
      data = data,
      outcome = outcome,
      group = group,
      id = id,
      goal = goal,
      outcome_type = outcome_type,
      paired = paired,
      repeated = repeated,
      adjust = adjust,
      normality = normality
    ))
  }

  recommend_test(
    data = data,
    outcome = outcome,
    group = group,
    id = id,
    goal = goal,
    outcome_type = outcome_type,
    paired = paired,
    repeated = repeated,
    adjust = adjust,
    normality = normality
  )
}

#' Guide a User Through Branching Questions
#'
#' `guided_test()` provides the same workflow as `select_test()` but collects the
#' branch settings step by step. In non-interactive use, pass a named list to
#' `answers`.
#'
#' @param data A `data.frame`.
#' @param answers Optional named list of answers for non-interactive use.
#' @param run Either `"recommend"` or `"run"`.
#'
#' @return A `statsguider_decision` object or a `statsguider_result` object.
#' @export
guided_test <- function(data, answers = NULL, run = c("recommend", "run")) {
  run <- match.arg(run)

  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  goal <- choose_value(
    prompt = "Select the analysis goal:",
    choices = c("difference", "association", "adjusted_effect", "time_to_event", "agreement", "equivalence"),
    answers = answers,
    key = "goal"
  )

  outcome <- choose_column(
    prompt = "Select the outcome column:",
    data = data,
    answers = answers,
    key = "outcome",
    allow_null = FALSE
  )

  group <- choose_column(
    prompt = "Select the group column:",
    data = data,
    answers = answers,
    key = "group",
    allow_null = TRUE
  )

  paired <- choose_value(
    prompt = "Is the design paired?",
    choices = c("no", "yes"),
    answers = answers,
    key = "paired"
  )

  repeated <- choose_value(
    prompt = "Is the design repeated-measures?",
    choices = c("no", "yes"),
    answers = answers,
    key = "repeated"
  )

  adjust <- choose_value(
    prompt = "Do you need covariate adjustment?",
    choices = c("no", "yes"),
    answers = answers,
    key = "adjust"
  )

  id <- NULL
  if (identical(paired, "yes") || identical(repeated, "yes")) {
    id <- choose_column(
      prompt = "Select the subject ID column:",
      data = data,
      answers = answers,
      key = "id",
      allow_null = FALSE
    )
  }

  inferred_type <- guess_outcome_type(data[[outcome]])
  outcome_type <- choose_value(
    prompt = sprintf("Select the outcome type (detected: %s):", inferred_type),
    choices = unique(c("auto", inferred_type, "continuous", "binary", "nominal", "ordinal", "count")),
    answers = answers,
    key = "outcome_type"
  )

  normality <- "auto"
  if (identical(outcome_type, "auto") || identical(outcome_type, "continuous")) {
    normality <- choose_value(
      prompt = "Select the normality handling:",
      choices = c("auto", "yes", "no", "unknown"),
      answers = answers,
      key = "normality"
    )
  }

  select_test(
    data = data,
    outcome = outcome,
    group = group,
    id = id,
    goal = goal,
    outcome_type = outcome_type,
    paired = paired,
    repeated = repeated,
    adjust = adjust,
    normality = normality,
    run = run
  )
}

#' @export
print.statsguider_decision <- function(x, ...) {
  cat("statsguider decision\n")
  cat("- action: ", x$action, "\n", sep = "")
  if (!is.na(x$method)) {
    cat("- method: ", x$method, "\n", sep = "")
  }
  if (!is.na(x$alternative)) {
    cat("- alternative: ", x$alternative, "\n", sep = "")
  }
  cat("- reason: ", x$reason, "\n", sep = "")
  cat("- next step: ", x$next_step, "\n", sep = "")
  if (length(x$notes)) {
    cat("- notes:\n", sep = "")
    for (note in x$notes) {
      cat("  * ", note, "\n", sep = "")
    }
  }
  invisible(x)
}

#' @export
print.statsguider_result <- function(x, ...) {
  cat("statsguider result\n")
  cat("- method: ", x$decision$method, "\n", sep = "")
  cat("- reason: ", x$decision$reason, "\n", sep = "")
  cat("- summary: ", x$summary, "\n\n", sep = "")
  print(x$result)
  invisible(x)
}

normalize_yes_no <- function(x) {
  if (is.logical(x) && length(x) == 1L && !is.na(x)) {
    return(if (isTRUE(x)) "yes" else "no")
  }
  match.arg(x, c("no", "yes"))
}

collapse_group_count <- function(n) {
  if (n >= 3L) {
    return("3plus")
  }
  as.character(n)
}

guess_outcome_type <- function(x) {
  if (is.ordered(x)) {
    return("ordinal")
  }

  if (is.logical(x)) {
    return("binary")
  }

  if (is.factor(x) || is.character(x)) {
    levels_n <- length(unique(stats::na.omit(x)))
    if (levels_n <= 2L) {
      return("binary")
    }
    return("nominal")
  }

  if (is.numeric(x)) {
    values <- unique(stats::na.omit(x))
    if (length(values) <= 2L) {
      return("binary")
    }
    if (all(abs(values - round(values)) < .Machine$double.eps^0.5) && min(values) >= 0) {
      return("count")
    }
    return("continuous")
  }

  "nominal"
}

infer_normality <- function(x, group = NULL) {
  if (!is.numeric(x)) {
    return("unknown")
  }

  if (is.null(group)) {
    values <- stats::na.omit(x)
    if (length(values) < 3L) {
      return("unknown")
    }
    return(if (stats::shapiro.test(values)$p.value > 0.05) "yes" else "no")
  }

  keep <- !is.na(x) & !is.na(group)
  if (sum(keep) < 3L) {
    return("unknown")
  }
  split_values <- split(x[keep], group[keep])
  flags <- vapply(split_values, function(values) {
    if (length(values) < 3L) {
      return(NA)
    }
    stats::shapiro.test(values)$p.value > 0.05
  }, logical(1), USE.NAMES = FALSE)

  if (any(is.na(flags))) {
    return("unknown")
  }
  if (all(flags)) "yes" else "no"
}

has_small_expected_counts <- function(outcome, group) {
  tab <- table(group, outcome, useNA = "no")
  expected <- suppressWarnings(stats::chisq.test(tab)$expected)
  any(expected < 5)
}

make_decision <- function(action, method, alternative, reason, next_step, notes, inputs, method_id = NA_character_) {
  structure(
    list(
      action = action,
      method_id = method_id,
      method = method,
      alternative = alternative,
      reason = reason,
      next_step = next_step,
      notes = unique(notes),
      inputs = inputs
    ),
    class = "statsguider_decision"
  )
}

make_redirect_decision <- function(goal, notes, inputs) {
  branch <- switch(
    goal,
    association = c(
      "This question is about association rather than a simple group comparison.",
      "Move to correlation or regression methods."
    ),
    adjusted_effect = c(
      "This question requires adjusted effect estimation rather than a simple unadjusted test.",
      "Move to regression or mixed-effects models."
    ),
    time_to_event = c(
      "Time-to-event outcomes need dedicated survival-analysis methods.",
      "Move to Kaplan-Meier or Cox workflows."
    ),
    agreement = c(
      "Agreement and reproducibility questions need dedicated agreement methods.",
      "Move to ICC, Bland-Altman, or kappa workflows."
    ),
    equivalence = c(
      "Equivalence and non-inferiority analyses need predefined margins and dedicated methods.",
      "Move to TOST or non-inferiority workflows."
    ),
    c(
      "This branch is outside the scope of the simple comparison workflow.",
      "Move to the appropriate modelling workflow."
    )
  )

  make_decision(
    action = "redirect",
    method = NA_character_,
    alternative = NA_character_,
    reason = branch[[1]],
    next_step = branch[[2]],
    notes = notes,
    inputs = inputs
  )
}

decide_independent_branch <- function(data, outcome, group, inputs, normality, notes) {
  type <- inputs$outcome_type
  groups <- inputs$group_count

  if (type %in% c("binary", "nominal")) {
    small <- has_small_expected_counts(data[[outcome]], data[[group]])
    if (small) {
      return(make_decision(
        action = "recommend",
        method = "Fisher exact test",
        alternative = "Chi-squared test",
        reason = "The categorical outcome has small expected cell counts.",
        next_step = "Run Fisher exact test.",
        notes = notes,
        inputs = inputs,
        method_id = "fisher_exact"
      ))
    }
    return(make_decision(
      action = "recommend",
      method = "Chi-squared test",
      alternative = "Fisher exact test",
      reason = "The design is an independent categorical comparison with adequate expected counts.",
      next_step = "Run the chi-squared test.",
      notes = notes,
      inputs = inputs,
      method_id = "chisq_test"
    ))
  }

  if (type == "ordinal") {
    if (groups == "2") {
      return(make_decision(
        action = "recommend",
        method = "Mann-Whitney U test",
        alternative = NA_character_,
        reason = "The design is an independent two-group comparison with an ordinal outcome.",
        next_step = "Run the Mann-Whitney U test.",
        notes = notes,
        inputs = inputs,
        method_id = "mann_whitney"
      ))
    }
    return(make_decision(
      action = "recommend",
      method = "Kruskal-Wallis test",
      alternative = NA_character_,
      reason = "The design is an independent multi-group comparison with an ordinal outcome.",
      next_step = "Run the Kruskal-Wallis test.",
      notes = notes,
      inputs = inputs,
      method_id = "kruskal_wallis"
    ))
  }

  if (type != "continuous") {
    return(make_decision(
      action = "stop",
      method = NA_character_,
      alternative = NA_character_,
      reason = "The outcome type does not match a supported independent branch.",
      next_step = "Check the outcome type or move to a different analysis workflow.",
      notes = notes,
      inputs = inputs
    ))
  }

  if (groups == "2") {
    if (identical(normality, "yes")) {
      return(make_decision(
        action = "recommend",
        method = "Welch t-test",
        alternative = "Mann-Whitney U test",
        reason = "The design is an independent two-group continuous comparison with acceptable normality.",
        next_step = "Run the Welch t-test.",
        notes = notes,
        inputs = inputs,
        method_id = "welch_t"
      ))
    }
    return(make_decision(
      action = "recommend_with_warning",
      method = "Mann-Whitney U test",
      alternative = "Welch t-test",
      reason = "The design is an independent two-group continuous comparison, but normality is not reliable.",
      next_step = "Run the Mann-Whitney U test, or confirm normality if you want the Welch t-test.",
      notes = notes,
      inputs = inputs,
      method_id = "mann_whitney"
    ))
  }

  if (groups == "3plus") {
    if (identical(normality, "yes")) {
      return(make_decision(
        action = "recommend",
        method = "Welch ANOVA",
        alternative = "Kruskal-Wallis test",
        reason = "The design is an independent multi-group continuous comparison with acceptable normality.",
        next_step = "Run Welch ANOVA.",
        notes = notes,
        inputs = inputs,
        method_id = "welch_anova"
      ))
    }
    return(make_decision(
      action = "recommend_with_warning",
      method = "Kruskal-Wallis test",
      alternative = "Welch ANOVA",
      reason = "The design is an independent multi-group continuous comparison, but normality is not reliable.",
      next_step = "Run the Kruskal-Wallis test, or confirm normality if you want Welch ANOVA.",
      notes = notes,
      inputs = inputs,
      method_id = "kruskal_wallis"
    ))
  }

  make_decision(
    action = "stop",
    method = NA_character_,
    alternative = NA_character_,
    reason = "A supported independent comparison branch was not found.",
    next_step = "Check the group structure and try again.",
    notes = notes,
    inputs = inputs
  )
}

decide_paired_branch <- function(data, outcome, group, inputs, normality, notes) {
  type <- inputs$outcome_type

  if (inputs$group_count != "2") {
    return(make_decision(
      action = "stop",
      method = NA_character_,
      alternative = NA_character_,
      reason = "Paired execution is only supported for exactly two conditions.",
      next_step = "Use repeated = \"yes\" for three or more repeated conditions.",
      notes = notes,
      inputs = inputs
    ))
  }

  if (type == "binary") {
    return(make_decision(
      action = "recommend",
      method = "McNemar test",
      alternative = NA_character_,
      reason = "The design is a paired binary comparison.",
      next_step = "Run the McNemar test.",
      notes = notes,
      inputs = inputs,
      method_id = "mcnemar"
    ))
  }

  if (type == "ordinal") {
    return(make_decision(
      action = "recommend",
      method = "Wilcoxon signed-rank test",
      alternative = "Paired t-test",
      reason = "The design is a paired comparison with an ordinal outcome.",
      next_step = "Run the Wilcoxon signed-rank test.",
      notes = notes,
      inputs = inputs,
      method_id = "wilcoxon_signed_rank"
    ))
  }

  if (type == "continuous") {
    if (identical(normality, "yes")) {
      return(make_decision(
        action = "recommend",
        method = "Paired t-test",
        alternative = "Wilcoxon signed-rank test",
        reason = "The design is a paired continuous comparison with acceptable normality.",
        next_step = "Run the paired t-test.",
        notes = notes,
        inputs = inputs,
        method_id = "paired_t"
      ))
    }
    return(make_decision(
      action = "recommend_with_warning",
      method = "Wilcoxon signed-rank test",
      alternative = "Paired t-test",
      reason = "The design is a paired continuous comparison, but normality is not reliable.",
      next_step = "Run the Wilcoxon signed-rank test, or confirm normality if you want the paired t-test.",
      notes = notes,
      inputs = inputs,
      method_id = "wilcoxon_signed_rank"
    ))
  }

  make_decision(
    action = "stop",
    method = NA_character_,
    alternative = NA_character_,
    reason = "A supported paired branch was not found for the current outcome type.",
    next_step = "Check the outcome type or move to another workflow.",
    notes = notes,
    inputs = inputs
  )
}

decide_repeated_branch <- function(data, outcome, group, inputs, normality, notes) {
  type <- inputs$outcome_type

  if (inputs$group_count != "3plus") {
    return(make_decision(
      action = "stop",
      method = NA_character_,
      alternative = NA_character_,
      reason = "Repeated-measures execution is only supported for three or more conditions.",
      next_step = "Use the paired branch for exactly two repeated conditions.",
      notes = notes,
      inputs = inputs
    ))
  }

  if (type == "ordinal") {
    return(make_decision(
      action = "recommend",
      method = "Friedman test",
      alternative = NA_character_,
      reason = "The design is a repeated comparison with an ordinal outcome.",
      next_step = "Run the Friedman test.",
      notes = notes,
      inputs = inputs,
      method_id = "friedman"
    ))
  }

  if (type == "continuous") {
    if (identical(normality, "yes")) {
      return(make_decision(
        action = "recommend",
        method = "Repeated-measures ANOVA",
        alternative = "Friedman test",
        reason = "The design is a repeated continuous comparison with acceptable normality.",
        next_step = "Run repeated-measures ANOVA.",
        notes = notes,
        inputs = inputs,
        method_id = "repeated_anova"
      ))
    }
    return(make_decision(
      action = "recommend_with_warning",
      method = "Friedman test",
      alternative = "Repeated-measures ANOVA",
      reason = "The design is a repeated continuous comparison, but normality is not reliable.",
      next_step = "Run the Friedman test, or confirm normality if you want repeated-measures ANOVA.",
      notes = notes,
      inputs = inputs,
      method_id = "friedman"
    ))
  }

  make_decision(
    action = "redirect",
    method = NA_character_,
    alternative = NA_character_,
    reason = "Repeated non-continuous, non-ordinal outcomes are not supported in the minimal execution branch.",
    next_step = "Move to a model-based repeated-measures workflow.",
    notes = notes,
    inputs = inputs
  )
}

make_paired_vectors <- function(data, outcome, group, id) {
  if (is.null(group) || is.null(id)) {
    stop("Paired execution requires both `group` and `id`.", call. = FALSE)
  }

  keep <- stats::complete.cases(data[, c(outcome, group, id), drop = FALSE])
  df <- data[keep, c(outcome, group, id), drop = FALSE]
  names(df) <- c("outcome", "group", "id")
  levels_group <- unique(as.character(df$group))

  if (length(levels_group) != 2L) {
    stop("Paired execution requires exactly two group levels.", call. = FALSE)
  }

  first <- df[df$group == levels_group[1], c("id", "outcome")]
  second <- df[df$group == levels_group[2], c("id", "outcome")]
  merged <- merge(first, second, by = "id", suffixes = c("_x", "_y"))
  list(x = merged$outcome_x, y = merged$outcome_y)
}

choose_value <- function(prompt, choices, answers = NULL, key = NULL) {
  if (!is.null(answers) && !is.null(key) && !is.null(answers[[key]])) {
    return(answers[[key]])
  }

  if (!interactive()) {
    stop(sprintf("`%s` must be supplied in `answers` for non-interactive guided mode.", key), call. = FALSE)
  }

  selection <- utils::menu(choices, title = prompt)
  if (selection < 1L) {
    stop("Guided session cancelled.", call. = FALSE)
  }
  choices[[selection]]
}

choose_column <- function(prompt, data, answers = NULL, key = NULL, allow_null = FALSE) {
  if (!is.null(answers) && !is.null(key) && !is.null(answers[[key]])) {
    return(answers[[key]])
  }

  if (!interactive()) {
    stop(sprintf("`%s` must be supplied in `answers` for non-interactive guided mode.", key), call. = FALSE)
  }

  choices <- names(data)
  if (allow_null) {
    choices <- c("<none>", choices)
  }

  selection <- utils::menu(choices, title = prompt)
  if (selection < 1L) {
    stop("Guided session cancelled.", call. = FALSE)
  }

  value <- choices[[selection]]
  if (allow_null && identical(value, "<none>")) NULL else value
}
