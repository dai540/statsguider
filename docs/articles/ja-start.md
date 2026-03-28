# はじめに

`statsguider`
は、データの性質を順に選ぶだけで、使うべき統計手法を案内し、そのまま実行できるパッケージです。

基本の流れは 3 段階です。

1.  データの性質を選ぶ
2.  推奨される手法を確認する
3.  必要ならそのまま実行する

## まず使う関数

最初に覚える関数は
[`select_test()`](https://dai540.github.io/statsguider/reference/select_test.md)
です。

最低限必要なのは次の列指定です。

- `data`: 解析する `data.frame`
- `outcome`: 結果の列
- `group`: 群や条件の列
- `id`: 対応ありや反復測定のときの個体 ID 列

列指定以外は、基本的に選択式の引数です。

- `goal`
  - `"difference"`: 群間差をみたい
  - `"association"`: 関連をみたい
  - `"adjusted_effect"`: 調整した効果をみたい
  - `"time_to_event"`: 生存時間をみたい
  - `"agreement"`: 一致度をみたい
  - `"equivalence"`: 等価性や非劣性をみたい
- `outcome_type`
  - `"continuous"`: 連続値
  - `"binary"`: 二値
  - `"nominal"`: 名義カテゴリ
  - `"ordinal"`: 順序カテゴリ
  - `"count"`: カウント
- `paired`
  - `"yes"`: 同じ個体を 2 回比べる
  - `"no"`: 独立した群を比べる
- `repeated`
  - `"yes"`: 同じ個体を 3 回以上測る
  - `"no"`: 反復測定ではない
- `adjust`
  - `"yes"`: 共変量調整が必要
  - `"no"`: 単純比較でよい
- `normality`
  - `"auto"`: 自動で参考判定する
  - `"yes"`: 正規性を仮定する
  - `"no"`: 正規性を仮定しない
  - `"unknown"`: わからない
- `run`
  - `"recommend"`: 推奨手法だけを返す
  - `"run"`: 推奨手法をそのまま実行する
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
#> statsguider の案内
#> - 動作: 推奨
#> - 推奨手法: Welchのt検定
#> - 代替手法: Mann-Whitney U検定
#> - 理由: 独立2群の連続アウトカムで正規性も大きくは外れていないと判断しました。
#> - 次の一歩: Welchのt検定に進みます。必要なら順位ベースの代替も検討してください。
#> - 補足:
#>   * 正規性を自動判定し、`yes` と分類しました。
```

この例では、独立 2 群の連続値なので、まず推奨手法が返ります。

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
#> - 理由: 独立2群の連続アウトカムで正規性も大きくは外れていないと判断しました。
#> - 要約: Welchのt検定 が選ばれた理由は、データが continuous 型、群数 2、paired = no、repeated = no と判定されたためです。
```

解析まで進めたいときは `run = "run"` にします。

## 質問に答えながら進める

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
#> statsguider の案内
#> - 動作: 推奨
#> - 推奨手法: Welchのt検定
#> - 代替手法: Mann-Whitney U検定
#> - 理由: 独立2群の連続アウトカムで正規性も大きくは外れていないと判断しました。
#> - 次の一歩: Welchのt検定に進みます。必要なら順位ベースの代替も検討してください。
#> - 補足:
#>   * 正規性を自動判定し、`yes` と分類しました。
```

[`guided_test()`](https://dai540.github.io/statsguider/reference/guided_test.md)
は、分岐を一つずつ確認したいときに向いています。

## 次に読む記事

- [`select_test()`](https://dai540.github.io/statsguider/reference/select_test.md)
  を中心に知りたいとき: 「主な関数」
- いろいろなデータ表で試したいとき: 「シナリオ別チュートリアル」
- 分岐の考え方を見たいとき: 「分岐で選ぶ」
