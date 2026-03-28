# Check Whether a Design Fits the Simple Branching Workflow

Performs structural validation before recommending or running a
statistical test. The function is intentionally conservative and
redirects designs that should not be forced into a simple test.

## Usage

``` r
check_design(
  data,
  outcome,
  group = NULL,
  id = NULL,
  goal = "difference",
  paired = "no",
  repeated = "no",
  adjust = "no",
  outcome_type = NULL,
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

  Optional subject identifier column for paired or repeated designs.

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

  Optional outcome type. One of `"continuous"`, `"binary"`, `"nominal"`,
  `"ordinal"`, or `"count"`.

- language:

  `"en"` or `"ja"`.

## Value

A list with `ok`, `issues`, `warnings`, and `inputs`.
