# シナリオ別チュートリアル

このチュートリアルでは、小さなデータ表をいくつか自分で作り、それぞれに
`statsguider` を適用します。

## シナリオ1: 独立2群の連続値

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
  language = "ja"
)
#> statsguider の案内
#> - 動作: 推奨
#> - 推奨手法: Welchのt検定
#> - 代替手法: Mann-Whitney U検定
#> - 理由: 独立2群の連続アウトカムで正規性も大きくは外れていないと判断しました。
#> - 次の一歩: Welchのt検定に進みます。必要なら順位ベースの代替も検討してください。
#> - 補足:
#>   * 正規性を自動判定し、`yes` と分類しました。
```

``` r
run_test(
  data = tbl_continuous,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  language = "ja"
)
#> statsguider の結果
#> - 手法: Welchのt検定
#> - 理由: 独立2群の連続アウトカムで正規性も大きくは外れていないと判断しました。
#> - 要約: Welchのt検定 が選ばれた理由は、データが continuous 型、群数 2、paired = no、repeated = no と判定されたためです。
```

## シナリオ2: 対応ありの前後比較

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
  language = "ja"
)
#> statsguider の案内
#> - 動作: 推奨
#> - 推奨手法: 対応のあるt検定
#> - 代替手法: Wilcoxon符号順位検定
#> - 理由: 対応のある2時点の連続アウトカムで正規性も大きくは外れていないと判断しました。
#> - 次の一歩: 対応のあるt検定に進みます。
#> - 補足:
#>   * 正規性を自動判定し、`yes` と分類しました。
```

## シナリオ3: 独立3群の連続値

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
  language = "ja"
)
#> statsguider の案内
#> - 動作: 推奨
#> - 推奨手法: Welch ANOVA
#> - 代替手法: Kruskal-Wallis検定
#> - 理由: 3群以上の独立した連続アウトカムで正規性も大きくは外れていないと判断しました。
#> - 次の一歩: Welch ANOVAに進みます。
#> - 補足:
#>   * 正規性を自動判定し、`yes` と分類しました。
```

## シナリオ4: 小標本のカテゴリデータ

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
  language = "ja"
)
#> statsguider の案内
#> - 動作: 推奨
#> - 推奨手法: Fisher正確確率検定
#> - 代替手法: χ²検定
#> - 理由: 独立2群のカテゴリデータで期待度数が小さいセルがあります。
#> - 次の一歩: Fisher正確確率検定に進みます。
```

## シナリオ5: 対応ありの二値データ

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
  language = "ja"
)
#> statsguider の案内
#> - 動作: 推奨
#> - 推奨手法: McNemar検定
#> - 理由: 対応のある二値データと判断しました。
#> - 次の一歩: McNemar検定に進みます。
```

## シナリオ6: 反復測定の順序データ

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
  language = "ja"
)
#> statsguider の案内
#> - 動作: 推奨
#> - 推奨手法: Friedman検定
#> - 代替手法: 反復測定ANOVA
#> - 理由: 反復測定の順序データと判断しました。
#> - 次の一歩: Friedman検定に進みます。
```

## シナリオ7: 共変量調整が必要で別枝に進むケース

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
  language = "ja"
)
#> statsguider の案内
#> - 動作: 別枝へ案内
#> - 理由: 調整が必要なので単純な非調整検定は適切な主枝ではありません。
#> - 次の一歩: 回帰または混合モデルの枝に進んでください。
#> - 補足:
#>   * 共変量調整が必要なので、単純な検定よりモデル解析の方が適切です。
#>   * 正規性を自動判定し、`yes` と分類しました。
```

## シナリオ8: カウントデータなので別枝に進むケース

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
  language = "ja"
)
#> statsguider の案内
#> - 動作: 別枝へ案内
#> - 理由: カウントアウトカムは単純比較検定に無理に入れるべきではありません。
#> - 次の一歩: Poisson回帰または負の二項回帰に進んでください。
#> - 補足:
#>   * カウントアウトカムは通常、Poisson 回帰または負の二項回帰に進むべきです。
```

このように、`statsguider`
は「使うべき手法を出す」だけでなく、「単純検定では進まない方がよい」ケースも案内します。
