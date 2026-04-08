package_csv <- function(..., encoding = NULL) {
  path <- system.file(..., package = "statsguider", mustWork = TRUE)
  args <- list(path, stringsAsFactors = FALSE)
  if (!is.null(encoding)) {
    args$encoding <- encoding
  }
  do.call(utils::read.csv, args)
}

statsguider_rules <- local({
  cache <- NULL

  function() {
    if (is.null(cache)) {
      cache <<- package_csv("rules", "decision_rules.csv")
    }
    cache
  }
})

statsguider_methods <- local({
  cache <- NULL

  function() {
    if (is.null(cache)) {
      cache <<- package_csv("rules", "method_registry.csv")
    }
    cache
  }
})

statsguider_messages <- local({
  cache <- NULL

  function() {
    if (is.null(cache)) {
      cache <<- package_csv("extdata", "messages.csv", encoding = "UTF-8")
    }
    cache
  }
})

normalize_language <- function(language) {
  match.arg(language, c("en", "ja"))
}

normalize_goal <- function(goal) {
  match.arg(goal, c("difference", "association", "adjusted_effect", "time_to_event", "agreement", "equivalence"))
}

normalize_yes_no <- function(x) {
  if (is.logical(x) && length(x) == 1L && !is.na(x)) {
    return(if (isTRUE(x)) "yes" else "no")
  }
  match.arg(x, c("no", "yes"))
}

normalize_outcome_type <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  match.arg(x, c("continuous", "binary", "nominal", "ordinal", "count"))
}

normalize_normality <- function(x) {
  match.arg(x, c("auto", "yes", "no", "unknown"))
}

normalize_run_mode <- function(x) {
  if (is.logical(x) && length(x) == 1L && !is.na(x)) {
    return(if (isTRUE(x)) "run" else "recommend")
  }
  match.arg(x, c("recommend", "run"))
}

normalize_analysis_args <- function(language = "en",
                                    goal = "difference",
                                    paired = "no",
                                    repeated = "no",
                                    adjust = "no",
                                    outcome_type = NULL,
                                    normality = NULL,
                                    run = NULL) {
  args <- list(
    language = normalize_language(language),
    goal = normalize_goal(goal),
    paired = normalize_yes_no(paired),
    repeated = normalize_yes_no(repeated),
    adjust = normalize_yes_no(adjust),
    outcome_type = normalize_outcome_type(outcome_type)
  )
  if (!is.null(normality)) {
    args$normality <- normalize_normality(normality)
  }
  if (!is.null(run)) {
    args$run <- normalize_run_mode(run)
  }
  args
}

sg_text <- function(language, key, ...) {
  language <- normalize_language(language)
  values <- list(...)
  messages <- statsguider_messages()
  hit <- messages[messages$language == language & messages$key == key, "text", drop = TRUE]
  if (!length(hit)) {
    stop(sprintf("Unknown translation key: %s (%s)", key, language), call. = FALSE)
  }
  template <- hit[[1]]
  if (length(values) == 0L) {
    template
  } else {
    do.call(sprintf, c(list(template), values))
  }
}

match_rule_value <- function(rule_value, actual_value) {
  if (identical(rule_value, "*")) {
    return(TRUE)
  }
  identical(tolower(rule_value), tolower(actual_value))
}

guess_outcome_type <- function(x) {
  if (is.numeric(x)) {
    uniq <- unique(stats::na.omit(x))
    if (length(uniq) <= 2) {
      return("binary")
    }
    if (all(abs(uniq - round(uniq)) < .Machine$double.eps^0.5) &&
        length(uniq) <= 10 &&
        min(uniq) >= 0) {
      return("count")
    }
    return("continuous")
  }

  if (is.logical(x)) {
    return("binary")
  }

  if (is.factor(x) && is.ordered(x)) {
    return("ordinal")
  }

  if (is.factor(x) || is.character(x)) {
    n_levels <- length(unique(stats::na.omit(x)))
    if (n_levels <= 2) {
      return("binary")
    }
    return("nominal")
  }

  "unknown"
}

normality_flag <- function(x, group = NULL) {
  if (!is.numeric(x)) {
    return("unknown")
  }

  if (is.null(group)) {
    x <- stats::na.omit(x)
    if (length(x) < 3) {
      return("unknown")
    }
    if (length(x) > 5000) {
      return("yes")
    }
    return(if (stats::shapiro.test(x)$p.value > 0.05) "yes" else "no")
  }

  keep <- !is.na(group) & !is.na(x)
  if (sum(keep) < 3) {
    return("unknown")
  }
  split_x <- split(x[keep], group[keep])
  per_group <- vapply(split_x, function(values) {
    if (length(values) < 3) {
      return(FALSE)
    }
    if (length(values) > 5000) {
      return(TRUE)
    }
    stats::shapiro.test(values)$p.value > 0.05
  }, logical(1))
  if (all(per_group)) "yes" else "no"
}

expected_count_small_flag <- function(outcome, group) {
  tab <- table(group, outcome, useNA = "no")
  if (any(dim(tab) == 0)) {
    return("unknown")
  }
  expected <- suppressWarnings(stats::chisq.test(tab)$expected)
  if (any(expected < 5)) "yes" else "no"
}

pair_wide <- function(data, outcome, group, id) {
  cols <- c(id, group, outcome)
  df <- data[stats::complete.cases(data[, cols, drop = FALSE]), cols, drop = FALSE]
  names(df) <- c("id", "group", "outcome")
  levels_group <- unique(as.character(df$group))
  if (length(levels_group) != 2) {
    stop("Paired execution currently requires exactly two group levels.", call. = FALSE)
  }
  x <- df[df$group == levels_group[1], c("id", "outcome")]
  y <- df[df$group == levels_group[2], c("id", "outcome")]
  merged <- merge(x, y, by = "id", suffixes = c("_1", "_2"))
  list(
    first = merged$outcome_1,
    second = merged$outcome_2,
    levels = levels_group,
    wide = merged
  )
}

make_decision <- function(inputs, rule, methods, notes = character(), language = "en") {
  language <- normalize_language(language)
  method_row <- methods[methods$method_id == rule$method_id, , drop = FALSE]
  alt_row <- methods[methods$method_id == rule$alternative_method_id, , drop = FALSE]
  structure(
    list(
      inputs = inputs,
      action = rule$action,
      method_id = rule$method_id,
      method = if (nrow(method_row)) method_row[[paste0("display_name_", language)]][1] else NA_character_,
      alternative_method_id = rule$alternative_method_id,
      alternative_method = if (nrow(alt_row)) alt_row[[paste0("display_name_", language)]][1] else NA_character_,
      title = rule[[paste0("title_", language)]],
      reason = rule[[paste0("reason_", language)]],
      next_step = rule[[paste0("next_step_", language)]],
      notes = notes,
      language = language
    ),
    class = "statsguider_decision"
  )
}

action_label <- function(action, language) {
  key <- paste0("action_", action)
  text <- tryCatch(sg_text(language, key), error = function(e) action)
  if (is.null(text) || !nzchar(text)) action else text
}

#' @export
print.statsguider_decision <- function(x, ...) {
  language <- x$language %||% "en"
  cat(sg_text(language, "decision_header"), "\n", sep = "")
  cat("- ", sg_text(language, "action"), ": ", action_label(x$action, language), "\n", sep = "")
  if (!is.na(x$method) && nzchar(x$method)) {
    cat("- ", sg_text(language, "recommended"), ": ", x$method, "\n", sep = "")
  }
  if (!is.na(x$alternative_method) && nzchar(x$alternative_method)) {
    cat("- ", sg_text(language, "alternative"), ": ", x$alternative_method, "\n", sep = "")
  }
  cat("- ", sg_text(language, "reason"), ": ", x$reason, "\n", sep = "")
  if (!is.null(x$next_step) && nzchar(x$next_step)) {
    cat("- ", sg_text(language, "next_step"), ": ", x$next_step, "\n", sep = "")
  }
  if (length(x$notes)) {
    cat("- ", sg_text(language, "notes"), ":\n", sep = "")
    for (note in x$notes) {
      cat("  * ", note, "\n", sep = "")
    }
  }
  invisible(x)
}

#' @export
print.statsguider_result <- function(x, ...) {
  language <- x$decision$language %||% "en"
  cat(sg_text(language, "result_header"), "\n", sep = "")
  cat("- ", sg_text(language, "method"), ": ", x$decision$method, "\n", sep = "")
  cat("- ", sg_text(language, "reason"), ": ", x$decision$reason, "\n", sep = "")
  if (!is.null(x$summary_text)) {
    cat("- ", sg_text(language, "summary"), ": ", x$summary_text, "\n", sep = "")
  }
  invisible(x)
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
