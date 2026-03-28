# Run a Recommended Statistical Test

Executes a supported base R test after passing through the
recommendation engine. If the branch should be redirected or stopped,
the function errors with a short plain-language message instead of
forcing an analysis.

## Usage

``` r
run_test(
  data,
  outcome,
  group = NULL,
  id = NULL,
  goal = "difference",
  paired = "no",
  repeated = "no",
  adjust = "no",
  outcome_type = NULL,
  normality = "auto",
  language = "en"
)
```

## Arguments

- data:

  A data frame.

- outcome:

  Name of the outcome column.

- group:

  Optional name of the group column.

- id:

  Optional subject identifier column.

- goal:

  Analysis goal. One of `"difference"`, `"association"`,
  `"adjusted_effect"`, `"time_to_event"`, `"agreement"`, or
  `"equivalence"`.

- paired:

  `"yes"` or `"no"`.

- repeated:

  `"yes"` or `"no"`.

- adjust:

  `"yes"` or `"no"`.

- outcome_type:

  Optional manual outcome type. One of `"continuous"`, `"binary"`,
  `"nominal"`, `"ordinal"`, or `"count"`. When `NULL`, it is guessed.

- normality:

  One of `"auto"`, `"yes"`, `"no"`, or `"unknown"`.

- language:

  `"en"` or `"ja"`.

## Value

An object of class `statsguider_result`.
