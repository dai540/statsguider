# statsguider

Simple statistical test selection from a `data.frame`.

`statsguider` helps you choose a statistical method by branching on data properties, then run the recommended method.

## Website

- GitHub Pages site: [https://dai540.github.io/statsguider/](https://dai540.github.io/statsguider/)
- Site index HTML in the repository: [docs/index.html](https://github.com/dai540/statsguider/blob/main/docs/index.html)

## Install

```r
install.packages("remotes")
remotes::install_github("dai540/statsguider")
library(statsguider)
```

## Fastest way to use it

```r
dat <- subset(wet_example, visit == "week4")

select_test(
  data = dat,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  run = "run"
)
```

## Learn by scenarios

- English
  - [Start here](https://dai540.github.io/statsguider/articles/en-start.html)
  - [Choose by branching](https://dai540.github.io/statsguider/articles/en-branching.html)
  - [Scenario tutorials](https://dai540.github.io/statsguider/articles/en-examples.html)
  - [Main functions](https://dai540.github.io/statsguider/articles/en-functions.html)
- 日本語
  - [はじめに](https://dai540.github.io/statsguider/articles/ja-start.html)
  - [分岐で選ぶ](https://dai540.github.io/statsguider/articles/ja-branching.html)
  - [シナリオ別チュートリアル](https://dai540.github.io/statsguider/articles/ja-examples.html)
  - [主な関数](https://dai540.github.io/statsguider/articles/ja-functions.html)

## What the tutorial pages do

- English
  - each tutorial creates a small data table
  - each tutorial applies `select_test()` or `run_test()`
  - each scenario shows how to set the branching arguments
- 日本語
  - 各チュートリアルで小さなデータ表を自分で作ります
  - そのデータ表に `select_test()` や `run_test()` を適用します
  - 分岐に必要な引数をどう設定するかも一緒に示します
