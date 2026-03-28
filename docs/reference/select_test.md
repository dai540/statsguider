# Select and Optionally Run a Statistical Test

This is the simplest entry point in `statsguider`. You describe the data
properties, and the function either recommends a method or runs it.

## Usage

``` r
select_test(
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
  run = "run",
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

- run:

  One of `"recommend"` or `"run"`.

- language:

  `"en"` or `"ja"`.

## Value

A `statsguider_decision` object when `run = FALSE`, or a
`statsguider_result` object when `run = "run"`.
