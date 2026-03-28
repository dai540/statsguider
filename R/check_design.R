#' Check Whether a Design Fits the Simple Branching Workflow
#'
#' Performs structural validation before recommending or running a statistical
#' test. The function is intentionally conservative and redirects designs that
#' should not be forced into a simple test.
#'
#' @param data A data frame.
#' @param outcome Name of the outcome column.
#' @param group Optional name of the group column.
#' @param id Optional subject identifier column for paired or repeated designs.
#' @param goal Analysis goal. One of `"difference"`, `"association"`,
#'   `"adjusted_effect"`, `"time_to_event"`, `"agreement"`, or
#'   `"equivalence"`.
#' @param paired `"yes"` or `"no"`.
#' @param repeated `"yes"` or `"no"`.
#' @param adjust `"yes"` or `"no"`.
#' @param outcome_type Optional outcome type. One of `"continuous"`,
#'   `"binary"`, `"nominal"`, `"ordinal"`, or `"count"`.
#' @param language `"en"` or `"ja"`.
#'
#' @return A list with `ok`, `issues`, `warnings`, and `inputs`.
#' @export
check_design <- function(data,
                         outcome,
                         group = NULL,
                         id = NULL,
                         goal = "difference",
                         paired = "no",
                         repeated = "no",
                         adjust = "no",
                         outcome_type = NULL,
                         language = "en") {
  language <- normalize_language(language)
  goal <- normalize_goal(goal)
  paired <- normalize_yes_no(paired, "paired")
  repeated <- normalize_yes_no(repeated, "repeated")
  adjust <- normalize_yes_no(adjust, "adjust")
  outcome_type <- normalize_outcome_type(outcome_type)

  if (!is.data.frame(data)) {
    stop(sg_text(language, "data_must_be_df"), call. = FALSE)
  }

  issues <- character()
  warnings <- character()

  if (!outcome %in% names(data)) {
    issues <- c(issues, sg_text(language, "missing_outcome", outcome))
  }
  if (!is.null(group) && !group %in% names(data)) {
    issues <- c(issues, sg_text(language, "missing_group", group))
  }
  if (!is.null(id) && !id %in% names(data)) {
    issues <- c(issues, sg_text(language, "missing_id", id))
  }

  if (length(issues)) {
    return(list(ok = FALSE, issues = issues, warnings = warnings, inputs = NULL))
  }

  inferred_type <- if (is.null(outcome_type)) guess_outcome_type(data[[outcome]]) else outcome_type
  group_count <- if (is.null(group)) 0L else length(unique(stats::na.omit(data[[group]])))

  if (group_count < 1L && goal == "difference") {
    issues <- c(issues, sg_text(language, "need_group"))
  }
  if (group_count < 1L && goal != "difference") {
    issues <- c(issues, sg_text(language, "no_groups"))
  }
  if (!is.null(group) && group_count < 2L && goal == "difference") {
    issues <- c(issues, sg_text(language, "need_two_groups"))
  }
  if (paired == "yes" && is.null(id)) {
    issues <- c(issues, sg_text(language, "paired_need_id"))
  }
  if (repeated == "yes" && is.null(id)) {
    issues <- c(issues, sg_text(language, "repeated_need_id"))
  }
  if (paired == "yes" && repeated == "yes") {
    warnings <- c(warnings, sg_text(language, "paired_repeated_warning"))
  }
  if (adjust == "yes") {
    warnings <- c(warnings, sg_text(language, "adjust_warning"))
  }
  if (goal != "difference") {
    warnings <- c(warnings, sg_text(language, "outside_scope_warning"))
  }
  if (inferred_type == "count") {
    warnings <- c(warnings, sg_text(language, "count_warning"))
  }
  if (paired == "yes" && !is.null(group) && group_count != 2L && repeated == "no") {
    warnings <- c(warnings, sg_text(language, "paired_group_warning"))
  }

  list(
    ok = length(issues) == 0L,
    issues = issues,
    warnings = warnings,
    inputs = list(
      goal = goal,
      outcome_type = inferred_type,
      group_count = if (group_count >= 3L) "3plus" else as.character(group_count),
      paired = if (repeated == "yes") "no" else paired,
      repeated = repeated,
      adjust = adjust
    )
  )
}
