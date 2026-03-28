# 分岐で選ぶ

このページでは、`statsguider`
がどのような分岐で手法を選ぶかを大づかみに説明します。

``` mermaid
flowchart TD
    A["Start with the research question"] --> B["Compare groups"]
    A --> C["Measure association"]
    A --> D["Estimate an adjusted effect or prediction"]
    A --> E["Analyze time-to-event"]
    A --> F["Measure agreement or reproducibility"]
    A --> G["Show equivalence or non-inferiority"]
```

version 1.0.0 で主に対応しているのは、群間差の分岐です。

## 群間差の中での基本分岐

``` mermaid
flowchart TD
    A["Compare groups"] --> B{"Outcome type"}
    B --> C["Continuous"]
    B --> D["Binary or nominal"]
    B --> E["Ordinal"]
    B --> F["Count"]

    C --> C1{"How many groups?"}
    C1 -->|2| C2{"Paired?"}
    C1 -->|3 or more| C3{"Repeated?"}
    C2 -->|No| C4{"Normality?"}
    C2 -->|Yes| C5{"Normality of paired difference?"}
    C4 -->|Yes| T1["Welch t-test"]
    C4 -->|No| T2["Mann-Whitney U test"]
    C5 -->|Yes| T3["Paired t-test"]
    C5 -->|No| T4["Wilcoxon signed-rank test"]
    C3 -->|No| C6{"Normality?"}
    C3 -->|Yes| C7{"Continuous repeated data?"}
    C6 -->|Yes| T5["Welch ANOVA or ANOVA"]
    C6 -->|No| T6["Kruskal-Wallis test"]
    C7 -->|Yes| T7["Repeated-measures ANOVA"]
    C7 -->|No| T8["Friedman test"]

    D --> D1{"Paired?"}
    D1 -->|No| D2{"Expected counts small?"}
    D1 -->|Yes| T9["McNemar test"]
    D2 -->|Yes| T10["Fisher exact test"]
    D2 -->|No| T11["Chi-squared test"]

    E --> E1{"Paired or repeated?"}
    E1 -->|Independent 2 groups| T12["Mann-Whitney U test"]
    E1 -->|Paired 2 groups| T13["Wilcoxon signed-rank test"]
    E1 -->|Independent 3+ groups| T14["Kruskal-Wallis test"]
    E1 -->|Repeated 3+ groups| T15["Friedman test"]

    F --> T16["Redirect to count regression"]
```

## どんなときに止めるか

`statsguider` は、無理に単純検定へ進めないようにしています。

次のような場合は、推奨ではなく停止や別枝への案内を返します。

- 共変量で調整したい
- 生存時間を扱いたい
- 一致度をみたい
- 等価性や非劣性を示したい
- カウントデータを単純検定だけで扱おうとしている

## 実際の操作はもっとシンプル

分岐図の全体を覚える必要はありません。

実際には、次のように選択式の引数を入れるだけです。

``` r
select_test(
  data = dat,
  outcome = "biomarker",
  group = "group",
  outcome_type = "continuous",
  paired = "no",
  repeated = "no",
  run = "recommend"
)
```

必要な情報だけを入れれば、`statsguider`
がその分岐に沿って手法を案内します。
