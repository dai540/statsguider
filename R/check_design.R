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
  args <- normalize_analysis_args(
    language = language,
    goal = goal,
    paired = paired,
    repeated = repeated,
    adjust = adjust,
    outcome_type = outcome_type
  )

  if (!is.data.frame(data)) {
    stop(sg_text(args$language, "data_must_be_df"), call. = FALSE)
  }

  issues <- character()
  warnings <- character()

  if (!outcome %in% names(data)) {
    issues <- c(issues, sg_text(args$language, "missing_outcome", outcome))
  }
  if (!is.null(group) && !group %in% names(data)) {
    issues <- c(issues, sg_text(args$language, "missing_group", group))
  }
  if (!is.null(id) && !id %in% names(data)) {
    issues <- c(issues, sg_text(args$language, "missing_id", id))
  }

  if (length(issues)) {
    return(list(ok = FALSE, issues = issues, warnings = warnings, inputs = NULL))
  }

  inferred_type <- if (is.null(args$outcome_type)) guess_outcome_type(data[[outcome]]) else args$outcome_type
  group_count <- if (is.null(group)) 0L else length(unique(stats::na.omit(data[[group]])))

  if (group_count < 1L && args$goal == "difference") {
    issues <- c(issues, sg_text(args$language, "need_group"))
  }
  if (group_count < 1L && args$goal != "difference") {
    issues <- c(issues, sg_text(args$language, "no_groups"))
  }
  if (!is.null(group) && group_count < 2L && args$goal == "difference") {
    issues <- c(issues, sg_text(args$language, "need_two_groups"))
  }
  if (args$paired == "yes" && is.null(id)) {
    issues <- c(issues, sg_text(args$language, "paired_need_id"))
  }
  if (args$repeated == "yes" && is.null(id)) {
    issues <- c(issues, sg_text(args$language, "repeated_need_id"))
  }
  if (args$paired == "yes" && args$repeated == "yes") {
    warnings <- c(warnings, sg_text(args$language, "paired_repeated_warning"))
  }
  if (args$adjust == "yes") {
    warnings <- c(warnings, sg_text(args$language, "adjust_warning"))
  }
  if (args$goal != "difference") {
    warnings <- c(warnings, sg_text(args$language, "outside_scope_warning"))
  }
  if (inferred_type == "count") {
    warnings <- c(warnings, sg_text(args$language, "count_warning"))
  }
  if (args$paired == "yes" && !is.null(group) && group_count != 2L && args$repeated == "no") {
    warnings <- c(warnings, sg_text(args$language, "paired_group_warning"))
  }

  list(
    ok = length(issues) == 0L,
    issues = issues,
    warnings = warnings,
    inputs = list(
      goal = args$goal,
      outcome_type = inferred_type,
      group_count = if (group_count >= 3L) "3plus" else as.character(group_count),
      paired = if (args$repeated == "yes") "no" else args$paired,
      repeated = args$repeated,
      adjust = args$adjust
    )
  )
}
