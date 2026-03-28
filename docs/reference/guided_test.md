# Guide a User Through Simple Test Selection

Starts a simple branching workflow. In interactive sessions the function
asks a small number of questions. In scripts, the same answers can be
supplied as a named list.

## Usage

``` r
guided_test(data, answers = NULL, run = "recommend", language = "en")
```

## Arguments

- data:

  A data frame.

- answers:

  Optional named list of answers for non-interactive use.

- run:

  One of `"recommend"` or `"run"`.

- language:

  `"en"` or `"ja"`.

## Value

A `statsguider_decision` object, or a `statsguider_result` object when
`run = "run"`.
