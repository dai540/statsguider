# Main functions

This tutorial explains every main function in `statsguider`.

## 1. `select_test()`

This is the main entry point.

Use it when:

- you already know the relevant columns
- you want to choose a method directly from data properties
- you may want to run the test immediately

Important arguments:

- `data`: the full table
- `outcome`: the outcome column
- `group`: the group or condition column
- `id`: the subject ID column for paired or repeated data
- `goal`: what kind of question you have
- `outcome_type`: continuous, binary, nominal, ordinal, or count
- `paired`: `"yes"` or `"no"`
- `repeated`: `"yes"` or `"no"`
- `adjust`: `"yes"` or `"no"`
- `normality`: `"auto"`, `"yes"`, `"no"`, or `"unknown"`
- `run`: `"recommend"` or `"run"`
- `language`: `"en"` or `"ja"`

``` r
tbl_select <- data.frame(
  group = c(rep("control", 6), rep("treated", 6)),
  biomarker = c(10.2, 10.4, 10.1, 10.5, 10.3, 10.0, 11.1, 11.4, 11.0, 11.3, 11.5, 11.2)
)

select_test(
  data = tbl_select,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  run = "recommend",
  language = "en"
)
#> statsguider decision
#> - Action: recommend
#> - Recommended method: Welch t-test
#> - Alternative: Mann-Whitney U test
#> - Reason: The data look like two independent groups with a continuous outcome and acceptable normality.
#> - Next step: Run Welch t-test. Use the rank-based alternative if needed.
#> - Notes:
#>   * Normality was checked automatically and classified as `yes`.
```

If you change `run = "run"`, the selected method is executed.

## 2. `guided_test()`

Use this when you want the same decision process, but step by step.

It asks for:

- what you want to do
- which column is the outcome
- which column is the group
- whether the data are paired
- whether the data are repeated
- whether adjustment is needed
- what the outcome type is
- whether normality should be checked automatically

``` r
guided_test(
  tbl_select,
  answers = list(
    goal = "difference",
    outcome = "biomarker",
    group = "group",
    paired = "no",
    repeated = "no",
    adjust = "no",
    outcome_type = "continuous",
    normality = "auto"
  ),
  run = "recommend",
  language = "en"
)
#> statsguider decision
#> - Action: recommend
#> - Recommended method: Welch t-test
#> - Alternative: Mann-Whitney U test
#> - Reason: The data look like two independent groups with a continuous outcome and acceptable normality.
#> - Next step: Run Welch t-test. Use the rank-based alternative if needed.
#> - Notes:
#>   * Normality was checked automatically and classified as `yes`.
```

Use
[`guided_test()`](https://dai540.github.io/statsguider/reference/guided_test.md)
if you want a question-and-answer interface. Use
[`select_test()`](https://dai540.github.io/statsguider/reference/select_test.md)
if you want to set everything directly.

## 3. `recommend_test()`

Use this when you want the recommendation only.

It does not run the test. It returns:

- the action
- the recommended method
- an alternative
- the reason
- the next step
- any notes or warnings

``` r
recommend_test(
  data = tbl_select,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  language = "en"
)
#> statsguider decision
#> - Action: recommend
#> - Recommended method: Welch t-test
#> - Alternative: Mann-Whitney U test
#> - Reason: The data look like two independent groups with a continuous outcome and acceptable normality.
#> - Next step: Run Welch t-test. Use the rank-based alternative if needed.
#> - Notes:
#>   * Normality was checked automatically and classified as `yes`.
```

This is useful if you want to inspect the choice before running
anything.

## 4. `run_test()`

Use this when you want to run the supported method directly.

It first calls the recommendation engine. If the branch is
inappropriate, it stops instead of forcing the analysis.

``` r
run_test(
  data = tbl_select,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  language = "en"
)
#> statsguider result
#> - Method: Welch t-test
#> - Reason: The data look like two independent groups with a continuous outcome and acceptable normality.
#> - Summary: Welch t-test was selected because the data looked like continuous outcome, 2 groups, paired = no, repeated = no.
```

This function is stricter than manually calling a test yourself, because
it can redirect.

## 5. `check_design()`

Use this before analysis if you want to inspect whether the design is
suitable for a simple test.

It checks things such as:

- whether the required columns exist
- whether there are enough groups
- whether `id` is provided for paired or repeated data
- whether the branch should be redirected because of adjustment

``` r
check_design(
  data = tbl_select,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  adjust = "no",
  language = "en"
)
#> $ok
#> [1] TRUE
#> 
#> $issues
#> character(0)
#> 
#> $warnings
#> character(0)
#> 
#> $inputs
#> $inputs$goal
#> [1] "difference"
#> 
#> $inputs$outcome_type
#> [1] "continuous"
#> 
#> $inputs$group_count
#> [1] "2"
#> 
#> $inputs$paired
#> [1] "no"
#> 
#> $inputs$repeated
#> [1] "no"
#> 
#> $inputs$adjust
#> [1] "no"
```

This is the best function when you want to validate the setup first.

## Practical summary

- [`select_test()`](https://dai540.github.io/statsguider/reference/select_test.md):
  best general entry point
- [`guided_test()`](https://dai540.github.io/statsguider/reference/guided_test.md):
  best for question-by-question use
- [`recommend_test()`](https://dai540.github.io/statsguider/reference/recommend_test.md):
  best for seeing the method only
- [`run_test()`](https://dai540.github.io/statsguider/reference/run_test.md):
  best for running the recommended method
- [`check_design()`](https://dai540.github.io/statsguider/reference/check_design.md):
  best for validating the setup
