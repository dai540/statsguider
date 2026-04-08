# 主な関数

このチュートリアルでは、`statsguider` の主な 5 つの関数を説明します。

- [`select_test()`](https://dai540.github.io/statsguider/reference/select_test.md)
- [`guided_test()`](https://dai540.github.io/statsguider/reference/guided_test.md)
- [`recommend_test()`](https://dai540.github.io/statsguider/reference/recommend_test.md)
- [`run_test()`](https://dai540.github.io/statsguider/reference/run_test.md)
- [`check_design()`](https://dai540.github.io/statsguider/reference/check_design.md)

``` r
tbl_select <- data.frame(
  group = c(rep("control", 6), rep("treated", 6)),
  biomarker = c(10.2, 10.4, 10.1, 10.5, 10.3, 10.0, 11.1, 11.4, 11.0, 11.3, 11.5, 11.2)
)
```

## 1. `select_test()`

いちばん基本の入口です。列名とデータの性質を指定すると、推奨または実行を返します。

重要な引数:

- `data`, `outcome`, `group`, `id`
- `goal`, `outcome_type`, `paired`, `repeated`, `adjust`, `normality`
- `run`, `language`

``` r
select_test(
  data = tbl_select,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  run = "recommend",
  language = "ja"
)
#> statsguider の推奨
#> - 判定: 推奨
#> - 推奨手法: Welchのt検定
#> - 代替手法: Mann-Whitney U検定
#> - 理由: 連続値をもつ独立2群で、正規性も大きくは崩れていないと判断しました。
#> - 次の一歩: Welchのt検定を使ってください。必要なら順位ベースの代替手法を使います。
#> - 補足:
#>   * 正規性を自動判定し、`yes` と分類しました。
```

## 2. `guided_test()`

質問に沿って進めたいときに使います。非対話環境では `answers = list(...)`
で指定します。

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
  language = "ja"
)
#> statsguider の推奨
#> - 判定: 推奨
#> - 推奨手法: Welchのt検定
#> - 代替手法: Mann-Whitney U検定
#> - 理由: 連続値をもつ独立2群で、正規性も大きくは崩れていないと判断しました。
#> - 次の一歩: Welchのt検定を使ってください。必要なら順位ベースの代替手法を使います。
#> - 補足:
#>   * 正規性を自動判定し、`yes` と分類しました。
```

## 3. `recommend_test()`

推奨だけを見たいときに使います。実行はしません。

``` r
recommend_test(
  data = tbl_select,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  language = "ja"
)
#> statsguider の推奨
#> - 判定: 推奨
#> - 推奨手法: Welchのt検定
#> - 代替手法: Mann-Whitney U検定
#> - 理由: 連続値をもつ独立2群で、正規性も大きくは崩れていないと判断しました。
#> - 次の一歩: Welchのt検定を使ってください。必要なら順位ベースの代替手法を使います。
#> - 補足:
#>   * 正規性を自動判定し、`yes` と分類しました。
```

## 4. `run_test()`

推奨された手法をそのまま実行します。不適切な枝なら止まります。

``` r
run_test(
  data = tbl_select,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  language = "ja"
)
#> statsguider の結果
#> - 手法: Welchのt検定
#> - 理由: 連続値をもつ独立2群で、正規性も大きくは崩れていないと判断しました。
#> - 要約: Welchのt検定 を選んだ理由は、データが continuous 型、群数 2、paired = "no"、repeated = "no" だったためです。
```

## 5. `check_design()`

設計が単純検定に向いているかを先に確認したいときに使います。

``` r
check_design(
  data = tbl_select,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  adjust = "no",
  language = "ja"
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

## まとめ

- [`select_test()`](https://dai540.github.io/statsguider/reference/select_test.md):
  いちばん基本の入口
- [`guided_test()`](https://dai540.github.io/statsguider/reference/guided_test.md):
  順番に選びたいとき
- [`recommend_test()`](https://dai540.github.io/statsguider/reference/recommend_test.md):
  実行前に推奨だけ確認したいとき
- [`run_test()`](https://dai540.github.io/statsguider/reference/run_test.md):
  推奨手法を実行したいとき
- [`check_design()`](https://dai540.github.io/statsguider/reference/check_design.md):
  設計の妥当性を先に見たいとき
