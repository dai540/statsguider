#' Run a Recommended Statistical Test
#'
#' Executes a supported base R test after passing through the recommendation
#' engine. If the branch should be redirected or stopped, the function errors
#' with a short plain-language message instead of forcing an analysis.
#'
#' @inheritParams recommend_test
#'
#' @return An object of class `statsguider_result`.
#' @export
run_test <- function(data,
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

  decision <- recommend_test(
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

  if (!decision$action %in% c("recommend", "recommend_with_warning")) {
    stop(paste(decision$title, decision$reason, decision$next_step), call. = FALSE)
  }

  result <- switch(
    decision$method_id,
    welch_t = stats::t.test(stats::as.formula(paste(outcome, "~", group)), data = data, var.equal = FALSE),
    paired_t = {
      paired_data <- pair_wide(data, outcome, group, id)
      stats::t.test(paired_data$first, paired_data$second, paired = TRUE)
    },
    mann_whitney = stats::wilcox.test(stats::as.formula(paste(outcome, "~", group)), data = data, exact = FALSE),
    wilcoxon_signed_rank = {
      paired_data <- pair_wide(data, outcome, group, id)
      stats::wilcox.test(paired_data$first, paired_data$second, paired = TRUE, exact = FALSE)
    },
    welch_anova = stats::oneway.test(stats::as.formula(paste(outcome, "~", group)), data = data, var.equal = FALSE),
    anova = summary(stats::aov(stats::as.formula(paste(outcome, "~", group)), data = data)),
    kruskal_wallis = stats::kruskal.test(stats::as.formula(paste(outcome, "~", group)), data = data),
    repeated_anova = stats::aov(stats::as.formula(paste(outcome, "~", group, "+ Error(", id, "/", group, ")")), data = data),
    friedman = stats::friedman.test(stats::as.formula(paste(outcome, "~", group, "|", id)), data = data),
    chisq_test = stats::chisq.test(table(data[[group]], data[[outcome]], useNA = "no")),
    fisher_exact = stats::fisher.test(table(data[[group]], data[[outcome]], useNA = "no")),
    mcnemar = {
      paired_data <- pair_wide(data, outcome, group, id)
      stats::mcnemar.test(table(paired_data$first, paired_data$second, useNA = "no"))
    },
    stop(sprintf("Method `%s` is not executable in version 1.0.0.", decision$method_id), call. = FALSE)
  )

  summary_text <- sprintf(
    sg_text(language, "run_summary"),
    decision$method,
    decision$inputs$outcome_type,
    decision$inputs$group_count,
    decision$inputs$paired,
    decision$inputs$repeated
  )

  structure(
    list(
      decision = decision,
      result = result,
      summary_text = summary_text
    ),
    class = "statsguider_result"
  )
}
