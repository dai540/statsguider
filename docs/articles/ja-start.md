# はじめに

`statsguider`
は、データの性質を選ぶだけで使うべき統計手法を案内するパッケージです。

基本の流れは 3 段階です。

1.  データの性質を指定する
2.  推奨される手法を確認する
3.  必要ならそのまま実行する

## `select_test()` で使う主な引数

表の列を指定する引数:

- `data`: 解析に使う `data.frame`
- `outcome`: 結果変数の列名
- `group`: 群や条件を表す列名
- `id`: 対応あり・反復測定で使う被験者 ID 列

選択式の引数:

- `goal`
  - `"difference"`: 群間差を見たい
  - `"association"`: 関連を見たい
  - `"adjusted_effect"`: 調整付き効果を見たい
  - `"time_to_event"`: 生存時間を扱いたい
  - `"agreement"`: 一致度を見たい
  - `"equivalence"`: 等価性・非劣性を見たい
- `outcome_type`
  - `"continuous"`: 連続値
  - `"binary"`: 二値
  - `"nominal"`: 名義尺度
  - `"ordinal"`: 順序尺度
  - `"count"`: カウント
- `paired`
  - `"yes"`: 同じ対象を2回測っている
  - `"no"`: 独立した群を比べる
- `repeated`
  - `"yes"`: 同じ対象を3回以上測っている
  - `"no"`: 反復測定ではない
- `adjust`
  - `"yes"`: 共変量調整が必要
  - `"no"`: 単純比較でよい
- `normality`
  - `"auto"`: 自動判定
  - `"yes"`: 正規性を仮定する
  - `"no"`: 正規性を仮定しない
  - `"unknown"`: わからない
- `run`
  - `"recommend"`: 手法だけを返す
  - `"run"`: 手法を選んで実行する
- `language`
  - `"en"`: 英語表示
  - `"ja"`: 日本語表示

## まずは推奨だけを見る

``` r
dat <- subset(statsguider::wet_example, visit == "week4")

select_test(
  data = dat,
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

## そのまま実行する

``` r
select_test(
  data = dat,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  run = "run",
  language = "ja"
)
#> statsguider の結果
#> - 手法: Welchのt検定
#> - 理由: 連続値をもつ独立2群で、正規性も大きくは崩れていないと判断しました。
#> - 要約: Welchのt検定 を選んだ理由は、データが continuous 型、群数 2、paired = "no"、repeated = "no" だったためです。
```

## `guided_test()` で順番に選ぶ

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

[`select_test()`](https://dai540.github.io/statsguider/reference/select_test.md)
は引数を直接指定したいときに向いています。
[`guided_test()`](https://dai540.github.io/statsguider/reference/guided_test.md)
は質問に答えながら進みたいときに向いています。
