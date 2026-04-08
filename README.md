# statsguider <img src="man/figures/logo.svg" align="right" height="88" alt="statsguider logo" />

[![pkgdown](https://img.shields.io/badge/docs-pkgdown-315c86)](https://dai540.github.io/statsguider/)
[![R-CMD-check](https://github.com/dai540/statsguider/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dai540/statsguider/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

`statsguider` is an R package for guided statistical test selection from a
`data.frame`. It focuses on five jobs:

- classify a simple group-comparison design
- validate whether a simple test is appropriate
- recommend a test from a small set of design choices
- run supported base-R tests
- redirect to model-based workflows when a simple test is the wrong branch

<https://dai540.github.io/statsguider/>

The input contract is intentionally simple:

- `data`: the analysis table
- `outcome`: the outcome column
- `group`: the group or condition column when needed
- `id`: the subject identifier for paired or repeated designs
- choice-style arguments: `goal`, `outcome_type`, `paired`, `repeated`,
  `adjust`, `normality`, `run`, and `language`

Version 1.0.0 is intentionally narrow. The package is centered on simple
single-outcome group comparison and explicitly redirects users when the data
belong in regression, survival analysis, agreement analysis, equivalence, or
count-model workflows.

## Installation

Install from GitHub with `pak`:

```r
install.packages("pak")
pak::pak("dai540/statsguider")
```

or `remotes`:

```r
install.packages("remotes")
remotes::install_github("dai540/statsguider")
```

Then load the package:

```r
library(statsguider)
```

## Minimal Example

`select_test()` is the main wrapper:

```r
dat <- subset(statsguider::wet_example, visit == "week4")

result <- statsguider::select_test(
  data = dat,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  run = "recommend",
  language = "en"
)

result
```

To run the supported test immediately:

```r
statsguider::select_test(
  data = dat,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  run = "run",
  language = "en"
)
```

## Main Functions

- `select_test()`
- `guided_test()`
- `recommend_test()`
- `run_test()`
- `check_design()`

`select_test()` and `guided_test()` return either a `statsguider_decision`
object or a `statsguider_result` object, depending on whether the user asks
for recommendation only or full execution.

## Supported Simple Testing Branches

### Continuous outcomes

- independent 2 groups: Welch t-test or Mann-Whitney U test
- paired 2 groups: paired t-test or Wilcoxon signed-rank test
- independent 3+ groups: Welch ANOVA or Kruskal-Wallis test
- repeated 3+ groups: repeated-measures ANOVA or Friedman test

### Categorical and ordinal outcomes

- independent categorical comparison: chi-squared test or Fisher exact test
- paired binary comparison: McNemar test
- ordinal comparison: Mann-Whitney U, Wilcoxon signed-rank, Kruskal-Wallis, or Friedman test

### Redirected branches

- adjusted analyses
- association questions
- time-to-event outcomes
- agreement and reproducibility
- equivalence and non-inferiority
- count outcomes

## Built-in Example Data

- `wet_example`

`wet_example` is a small wet-lab style dataset with continuous, binary, and
ordinal outcomes across treatment groups and visits.

## Tutorials

The website is organized around:

- core introductions: start page, main functions, branching guide
- English scenario tutorials
- Japanese tutorials

## Documentation

- Website: <https://dai540.github.io/statsguider/>
- GitHub repository: <https://github.com/dai540/statsguider>

## Citation

If you use `statsguider`, cite the package as:

> Dai (2026). *statsguider: Guided Statistical Test Selection from a Data Frame*.
> R package. <https://dai540.github.io/statsguider/>

You can also retrieve the citation from R:

```r
citation("statsguider")
```
