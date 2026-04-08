# Scenario tutorials

This tutorial creates several small data tables and applies
`statsguider` to each one.

## Scenario 1: two independent continuous groups

``` r
tbl_continuous <- data.frame(
  group = c(rep("control", 6), rep("treated", 6)),
  biomarker = c(10.2, 10.4, 10.1, 10.5, 10.3, 10.0, 11.1, 11.4, 11.0, 11.3, 11.5, 11.2)
)

tbl_continuous
#>      group biomarker
#> 1  control      10.2
#> 2  control      10.4
#> 3  control      10.1
#> 4  control      10.5
#> 5  control      10.3
#> 6  control      10.0
#> 7  treated      11.1
#> 8  treated      11.4
#> 9  treated      11.0
#> 10 treated      11.3
#> 11 treated      11.5
#> 12 treated      11.2
```

``` r
select_test(
  data = tbl_continuous,
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

``` r
run_test(
  data = tbl_continuous,
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
#> - Summary: Welch t-test was selected because the data looked like continuous outcome, 2 groups, paired = "no", repeated = "no".
```

## Scenario 2: paired before-after measurements

``` r
tbl_paired <- data.frame(
  id = rep(paste0("S", 1:6), each = 2),
  visit = rep(c("before", "after"), times = 6),
  value = c(8.2, 9.0, 7.9, 8.8, 8.5, 9.1, 8.1, 8.9, 8.3, 9.0, 8.0, 8.7)
)

tbl_paired
#>    id  visit value
#> 1  S1 before   8.2
#> 2  S1  after   9.0
#> 3  S2 before   7.9
#> 4  S2  after   8.8
#> 5  S3 before   8.5
#> 6  S3  after   9.1
#> 7  S4 before   8.1
#> 8  S4  after   8.9
#> 9  S5 before   8.3
#> 10 S5  after   9.0
#> 11 S6 before   8.0
#> 12 S6  after   8.7
```

``` r
select_test(
  data = tbl_paired,
  outcome = "value",
  group = "visit",
  id = "id",
  outcome_type = "continuous",
  paired = "yes",
  repeated = "no",
  run = "recommend",
  language = "en"
)
#> statsguider decision
#> - Action: recommend
#> - Recommended method: Paired t-test
#> - Alternative: Wilcoxon signed-rank test
#> - Reason: The data look like two paired measurements with acceptable normality.
#> - Next step: Run paired t-test.
#> - Notes:
#>   * Normality was checked automatically and classified as `yes`.
```

## Scenario 3: three independent continuous groups

``` r
tbl_three_groups <- data.frame(
  group = rep(c("control", "drugA", "drugB"), each = 5),
  biomarker = c(
    9.8, 10.1, 10.0, 9.9, 10.2,
    10.8, 10.9, 11.1, 10.7, 11.0,
    11.4, 11.2, 11.5, 11.3, 11.6
  )
)

tbl_three_groups
#>      group biomarker
#> 1  control       9.8
#> 2  control      10.1
#> 3  control      10.0
#> 4  control       9.9
#> 5  control      10.2
#> 6    drugA      10.8
#> 7    drugA      10.9
#> 8    drugA      11.1
#> 9    drugA      10.7
#> 10   drugA      11.0
#> 11   drugB      11.4
#> 12   drugB      11.2
#> 13   drugB      11.5
#> 14   drugB      11.3
#> 15   drugB      11.6
```

``` r
select_test(
  data = tbl_three_groups,
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
#> - Recommended method: Welch ANOVA
#> - Alternative: Kruskal-Wallis test
#> - Reason: The data look like three or more independent groups with a continuous outcome and acceptable normality.
#> - Next step: Run Welch ANOVA.
#> - Notes:
#>   * Normality was checked automatically and classified as `yes`.
```

## Scenario 4: small categorical table

``` r
tbl_small_cat <- data.frame(
  group = c(rep("control", 6), rep("treated", 6)),
  response = c("yes", "no", "no", "no", "no", "no", "yes", "yes", "no", "no", "no", "no")
)

tbl_small_cat
#>      group response
#> 1  control      yes
#> 2  control       no
#> 3  control       no
#> 4  control       no
#> 5  control       no
#> 6  control       no
#> 7  treated      yes
#> 8  treated      yes
#> 9  treated       no
#> 10 treated       no
#> 11 treated       no
#> 12 treated       no
```

``` r
select_test(
  data = tbl_small_cat,
  outcome = "response",
  group = "group",
  outcome_type = "binary",
  paired = "no",
  repeated = "no",
  run = "recommend",
  language = "en"
)
#> statsguider decision
#> - Action: recommend
#> - Recommended method: Fisher's exact test
#> - Alternative: Chi-squared test
#> - Reason: The data look like two independent groups with small expected cell counts.
#> - Next step: Run Fisher's exact test.
```

## Scenario 5: paired binary response

``` r
tbl_paired_binary <- data.frame(
  id = rep(paste0("P", 1:8), each = 2),
  visit = rep(c("before", "after"), times = 8),
  response = c("no", "yes", "no", "no", "yes", "yes", "no", "yes",
               "yes", "yes", "no", "yes", "no", "no", "yes", "yes")
)

tbl_paired_binary
#>    id  visit response
#> 1  P1 before       no
#> 2  P1  after      yes
#> 3  P2 before       no
#> 4  P2  after       no
#> 5  P3 before      yes
#> 6  P3  after      yes
#> 7  P4 before       no
#> 8  P4  after      yes
#> 9  P5 before      yes
#> 10 P5  after      yes
#> 11 P6 before       no
#> 12 P6  after      yes
#> 13 P7 before       no
#> 14 P7  after       no
#> 15 P8 before      yes
#> 16 P8  after      yes
```

``` r
select_test(
  data = tbl_paired_binary,
  outcome = "response",
  group = "visit",
  id = "id",
  outcome_type = "binary",
  paired = "yes",
  repeated = "no",
  run = "recommend",
  language = "en"
)
#> statsguider decision
#> - Action: recommend
#> - Recommended method: McNemar test
#> - Reason: The data look like paired binary measurements.
#> - Next step: Run McNemar test.
```

## Scenario 6: repeated ordinal data

``` r
tbl_repeated_ordinal <- data.frame(
  id = rep(paste0("S", 1:5), each = 3),
  visit = rep(c("baseline", "week2", "week4"), times = 5),
  score = ordered(
    c(
      "high", "medium", "low",
      "medium", "medium", "low",
      "high", "medium", "medium",
      "medium", "low", "low",
      "high", "medium", "low"
    ),
    levels = c("low", "medium", "high")
  )
)

tbl_repeated_ordinal
#>    id    visit  score
#> 1  S1 baseline   high
#> 2  S1    week2 medium
#> 3  S1    week4    low
#> 4  S2 baseline medium
#> 5  S2    week2 medium
#> 6  S2    week4    low
#> 7  S3 baseline   high
#> 8  S3    week2 medium
#> 9  S3    week4 medium
#> 10 S4 baseline medium
#> 11 S4    week2    low
#> 12 S4    week4    low
#> 13 S5 baseline   high
#> 14 S5    week2 medium
#> 15 S5    week4    low
```

``` r
select_test(
  data = tbl_repeated_ordinal,
  outcome = "score",
  group = "visit",
  id = "id",
  outcome_type = "ordinal",
  paired = "no",
  repeated = "yes",
  run = "recommend",
  language = "en"
)
#> statsguider decision
#> - Action: recommend
#> - Recommended method: Friedman test
#> - Alternative: Repeated-measures ANOVA
#> - Reason: The data look like repeated ordinal measurements.
#> - Next step: Run Friedman test.
```

## Scenario 7: stop and redirect because adjustment is needed

``` r
tbl_adjust <- data.frame(
  group = c(rep("control", 6), rep("treated", 6)),
  age = c(41, 45, 39, 48, 42, 44, 37, 40, 38, 43, 39, 41),
  biomarker = c(10.2, 10.4, 10.1, 10.5, 10.3, 10.0, 11.1, 11.4, 11.0, 11.3, 11.5, 11.2)
)

tbl_adjust
#>      group age biomarker
#> 1  control  41      10.2
#> 2  control  45      10.4
#> 3  control  39      10.1
#> 4  control  48      10.5
#> 5  control  42      10.3
#> 6  control  44      10.0
#> 7  treated  37      11.1
#> 8  treated  40      11.4
#> 9  treated  38      11.0
#> 10 treated  43      11.3
#> 11 treated  39      11.5
#> 12 treated  41      11.2
```

``` r
select_test(
  data = tbl_adjust,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  adjust = "yes",
  run = "recommend",
  language = "en"
)
#> statsguider decision
#> - Action: redirect
#> - Reason: Adjustment was requested so a simple unadjusted test is not the right main branch.
#> - Next step: Move to regression or mixed models.
#> - Notes:
#>   * Adjustment was requested, so a model-based analysis is more appropriate than a simple test.
#>   * Normality was checked automatically and classified as `yes`.
```

## Scenario 8: stop and redirect because the outcome is a count

``` r
tbl_count <- data.frame(
  group = c(rep("control", 6), rep("treated", 6)),
  colonies = c(12, 10, 11, 14, 9, 13, 18, 17, 20, 16, 19, 18)
)

tbl_count
#>      group colonies
#> 1  control       12
#> 2  control       10
#> 3  control       11
#> 4  control       14
#> 5  control        9
#> 6  control       13
#> 7  treated       18
#> 8  treated       17
#> 9  treated       20
#> 10 treated       16
#> 11 treated       19
#> 12 treated       18
```

``` r
select_test(
  data = tbl_count,
  outcome = "colonies",
  group = "group",
  outcome_type = "count",
  paired = "no",
  repeated = "no",
  run = "recommend",
  language = "en"
)
#> statsguider decision
#> - Action: redirect
#> - Reason: Count outcomes should not be forced into a simple comparison test.
#> - Next step: Move to Poisson or negative binomial regression.
#> - Notes:
#>   * Count outcomes should usually move to Poisson or negative binomial regression.
```
