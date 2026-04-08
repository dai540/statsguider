# Start here

`statsguider` is built around one simple idea:

1.  describe the data properties
2.  let the package choose the test
3.  run the recommended method

## Main arguments in `select_test()`

There are two kinds of arguments.

Columns in your table:

- `data`: the full `data.frame`
- `outcome`: the column you want to analyze
- `group`: the column that defines groups or conditions
- `id`: the subject ID column for paired or repeated data

Choice-style arguments:

- `goal`
  - `"difference"`: compare groups
  - `"association"`: measure association
  - `"adjusted_effect"`: estimate an adjusted effect
  - `"time_to_event"`: analyze time-to-event data
  - `"agreement"`: measure agreement or reproducibility
  - `"equivalence"`: test equivalence or non-inferiority
- `outcome_type`
  - `"continuous"`: numeric values
  - `"binary"`: yes/no outcomes
  - `"nominal"`: unordered categories
  - `"ordinal"`: ordered categories
  - `"count"`: event counts
- `paired`
  - `"yes"`: the same subject is measured twice
  - `"no"`: different subjects are compared
- `repeated`
  - `"yes"`: the same subject is measured three or more times
  - `"no"`: not repeated-measures data
- `adjust`
  - `"yes"`: covariate adjustment is needed
  - `"no"`: a simple unadjusted comparison is enough
- `normality`
  - `"auto"`: let `statsguider` check automatically
  - `"yes"`: use the normal-data branch
  - `"no"`: use the non-normal branch
  - `"unknown"`: you are not sure
- `run`
  - `"recommend"`: choose a method only
  - `"run"`: choose and run the method
- `language`
  - `"en"`: English output
  - `"ja"`: Japanese output

## How to set them in practice

- Use `goal = "difference"` for ordinary group comparison.
- Use `outcome_type = "continuous"` for numeric lab values.
- Use `paired = "yes"` when the same subject appears twice.
- Use `repeated = "yes"` when the same subject appears at three or more
  visits or conditions.
- Use `adjust = "yes"` when your main analysis needs covariates.
- Use `run = "recommend"` first if you only want the method.

## The simplest function

``` r
dat <- subset(statsguider::wet_example, visit == "week4")

select_test(
  data = dat,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  run = "recommend"
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

In this example:

- `data = dat`: use this table
- `outcome = "biomarker"`: analyze the biomarker column
- `group = "group"`: compare the groups in `group`
- `outcome_type = "continuous"`: the outcome is numeric
- `paired = "no"`: the groups are independent
- `repeated = "no"`: this is not repeated-measures data
- `run = "recommend"`: only show the recommended method

## Run the test immediately

``` r
select_test(
  data = dat,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  run = "run"
)
#> statsguider result
#> - Method: Welch t-test
#> - Reason: The data look like two independent groups with a continuous outcome and acceptable normality.
#> - Summary: Welch t-test was selected because the data looked like continuous outcome, 2 groups, paired = "no", repeated = "no".
```

The only important change here is `run = "run"`.

## `guided_test()` uses the same choices

``` r
guided_test(
  dat,
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

[`guided_test()`](https://dai540.github.io/statsguider/reference/guided_test.md)
uses the same logic as
[`select_test()`](https://dai540.github.io/statsguider/reference/select_test.md).
The difference is only the interface:

- [`select_test()`](https://dai540.github.io/statsguider/reference/select_test.md):
  set the arguments directly
- [`guided_test()`](https://dai540.github.io/statsguider/reference/guided_test.md):
  answer the questions one by one
