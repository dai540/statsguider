#' Example Wet-Lab Style Dataset
#'
#' A small example dataset containing continuous, binary, and ordinal outcomes
#' across treatment groups and repeated visits. It is intended for examples and
#' documentation, not for scientific use.
#'
#' @format A data frame with 24 rows and 6 variables:
#' \describe{
#'   \item{id}{Subject identifier.}
#'   \item{group}{Treatment group (`control` or `drug`).}
#'   \item{visit}{Visit label (`baseline` or `week4`).}
#'   \item{biomarker}{Continuous biomarker value.}
#'   \item{response}{Binary response outcome.}
#'   \item{score}{Ordered severity score.}
#' }
#' @source Simulated for documentation.
#' @export
"wet_example" <- data.frame(
  id = rep(sprintf("S%02d", 1:12), each = 2),
  group = rep(rep(c("control", "drug"), each = 6), each = 2),
  visit = rep(c("baseline", "week4"), times = 12),
  biomarker = c(
    10.4, 10.8, 11.1, 10.9, 9.8, 9.7, 10.2, 10.4, 10.7, 10.5, 11.0, 10.8,
    10.3, 11.7, 10.1, 11.4, 9.9, 11.2, 10.0, 11.5, 10.2, 11.8, 10.5, 12.1
  ),
  response = c(
    "no", "no", "no", "yes", "no", "no", "yes", "yes", "no", "yes", "no", "yes",
    "no", "yes", "no", "yes", "no", "yes", "no", "yes", "no", "yes", "yes", "yes"
  ),
  score = ordered(
    c(
      "medium", "medium", "medium", "low", "high", "high", "medium", "low",
      "medium", "low", "high", "medium", "medium", "low", "medium", "low",
      "high", "low", "high", "low", "medium", "low", "medium", "low"
    ),
    levels = c("low", "medium", "high")
  ),
  stringsAsFactors = FALSE
)
