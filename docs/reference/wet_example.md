# Example Wet-Lab Style Dataset

A small example dataset containing continuous, binary, and ordinal
outcomes across treatment groups and repeated visits. It is intended for
examples and documentation, not for scientific use.

## Usage

``` r
wet_example
```

## Format

A data frame with 24 rows and 6 variables:

- id:

  Subject identifier.

- group:

  Treatment group (`control` or `drug`).

- visit:

  Visit label (`baseline` or `week4`).

- biomarker:

  Continuous biomarker value.

- response:

  Binary response outcome.

- score:

  Ordered severity score.

## Source

Simulated for documentation.
