# statsguider

[![R-CMD-check](https://github.com/dai540/statsguider/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dai540/statsguider/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/dai540/statsguider/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/dai540/statsguider/actions/workflows/pkgdown.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

`statsguider` is a small R package for **guided statistical test selection**.
It is intentionally narrow: the package is designed for users who already have
a `data.frame`, want to describe the data structure through a small set of
choice-style arguments, and need either:

- a recommendation for a simple statistical test, or
- immediate execution of that test with base R.

The package does **not** try to cover all of statistics. It deliberately stops
or redirects the analysis when the question belongs to a different branch such
as adjusted modelling, survival analysis, agreement analysis, equivalence, or
count regression.

## Design Goals

The repository has been rebuilt around four constraints:

1. **Minimal package footprint**
   Only the package source, tests, documentation source, and GitHub workflows
   are tracked. Rebuildable outputs such as `.Rcheck`, tarballs, temporary
   folders, and generated `docs/` files are not kept in the repository.
2. **Minimal argument contract**
   The required identifiers are `data`, `outcome`, `group`, and `id` when
   needed. Everything else is a choice-style argument such as `paired = "yes"`
   or `goal = "difference"`.
3. **Minimal execution scope**
   The package only executes a small set of base-R tests that match a simple
   branching workflow.
4. **Detailed documentation without heavy assets**
   Tutorials build their own small data tables in code. No large bundled data
   and no downloaded external datasets are used.

## What the Package Covers

### Supported executable branches

- Independent two-group continuous comparison
  - Welch t-test
  - Mann-Whitney U test
- Paired two-group continuous comparison
  - Paired t-test
  - Wilcoxon signed-rank test
- Independent three-or-more-group continuous comparison
  - Welch ANOVA
  - Kruskal-Wallis test
- Repeated continuous comparison across three or more conditions
  - Repeated-measures ANOVA
  - Friedman test
- Independent categorical comparison
  - Chi-squared test
  - Fisher exact test
- Paired binary comparison
  - McNemar test
- Ordinal outcome comparisons
  - Mann-Whitney U test
  - Wilcoxon signed-rank test
  - Kruskal-Wallis test
  - Friedman test

### Redirected branches

- association questions
- adjusted effect estimation
- time-to-event outcomes
- agreement or reproducibility studies
- equivalence or non-inferiority studies
- count outcomes

## Installation

Install from GitHub with `pak`:

```r
install.packages("pak")
pak::pak("dai540/statsguider")
```

or with `remotes`:

```r
install.packages("remotes")
remotes::install_github("dai540/statsguider")
```

Then load the package:

```r
library(statsguider)
```

## Main Functions

### `select_test()`

This is the shortest entry point. You describe the data properties with
choice-style arguments and choose whether to only recommend or to run the test.

```r
dat <- data.frame(
  group = c(rep("control", 8), rep("treated", 8)),
  value = c(5.0, 5.2, 4.8, 5.1, 5.3, 4.9, 5.0, 5.4,
            6.1, 6.0, 5.8, 6.2, 6.3, 5.9, 6.1, 6.0)
)

select_test(
  data = dat,
  outcome = "value",
  group = "group",
  goal = "difference",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  adjust = "no",
  normality = "auto",
  run = "recommend"
)
```

### `guided_test()`

This function asks the same branching questions interactively. In non-interactive
contexts, you can pass a named `answers` list.

### `recommend_test()`

Returns a structured decision object. Use this when you want to inspect the
recommended branch before running anything.

### `run_test()`

Runs the recommended base-R test when the branch is supported.

### `check_design()`

Validates whether the design fits the simple workflow. It reports issues and
warnings before recommendation or execution.

## Minimal Workflow

The intended sequence is:

1. Put the analysis data in a `data.frame`.
2. Identify the outcome column.
3. Identify the group column when a group comparison is intended.
4. Mark design features with simple choices:
   - `goal`
   - `outcome_type`
   - `paired`
   - `repeated`
   - `adjust`
   - `normality`
5. Use `run = "recommend"` first.
6. Only switch to `run = "run"` after confirming the branch is correct.

## Argument Contract

The package intentionally uses a small set of arguments.

### Data-identifying arguments

- `data`
  - a `data.frame`
- `outcome`
  - the name of the outcome column
- `group`
  - the name of the grouping column when needed
- `id`
  - the name of the subject identifier column for paired or repeated designs

### Choice-style arguments

- `goal`
  - `"difference"`
  - `"association"`
  - `"adjusted_effect"`
  - `"time_to_event"`
  - `"agreement"`
  - `"equivalence"`
- `outcome_type`
  - `"auto"`
  - `"continuous"`
  - `"binary"`
  - `"nominal"`
  - `"ordinal"`
  - `"count"`
- `paired`
  - `"yes"` or `"no"`
- `repeated`
  - `"yes"` or `"no"`
- `adjust`
  - `"yes"` or `"no"`
- `normality`
  - `"auto"`
  - `"yes"`
  - `"no"`
  - `"unknown"`
- `run`
  - `"recommend"`
  - `"run"`

## Return Objects

### Recommendation object

`recommend_test()` and `select_test(..., run = "recommend")` return a
`statsguider_decision` object. It contains:

- the action
- the selected method
- an alternative method when relevant
- the reason for the branch
- the suggested next step
- warnings collected during design checking

### Execution object

`run_test()` and `select_test(..., run = "run")` return a
`statsguider_result` object. It contains:

- the decision object
- the base-R test result
- a short execution summary

## Documentation Site

The pkgdown site is organized into four sections:

- **Getting Started**
- **Guides**
- **Tutorials**
- **Reference**

The site is published at:

- <https://dai540.github.io/statsguider/>

The GitHub repository is:

- <https://github.com/dai540/statsguider>

## Repository Policy

This repository is intentionally kept small.

- No large built-in datasets
- No downloaded external example datasets
- No tracked `.Rcheck` outputs
- No tracked source tarballs
- No tracked temporary directories such as `tmp_*`
- No tracked generated `docs/` directory

## Citation

If you use `statsguider`, cite it as:

> Dai (2026). *statsguider: Guided Statistical Test Selection with a Minimal
> Branching Workflow*. R package. <https://github.com/dai540/statsguider>
