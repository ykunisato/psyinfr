# psyinfr::set_manuscript() の使い方

Quarto Manuscripts形式で「論文（paper.qmd）」と「解析ノートブック（notebooks/）」をひとまとめに管理するためのプロジェクトを作る関数です。解析ノートブックで作った図や表を、論文本文にショートコードで埋め込めるのが最大の特徴です。

---

## 1. このプロジェクトの考え方

Quarto Manuscriptsでは、役割ごとにファイルを分けます。

| ファイル | 役割 |
| --- | --- |
| `paper.qmd` | 論文本文。文章を書く場所。解析はここでやらない |
| `notebooks/Data_collection.qmd` | データ収集の記録。cbat4rで調査を作るコード |
| `notebooks/Analysis_01.qmd` | 解析。図や表はここで作る |
| `_quarto.yml` | プロジェクト全体の設定（出力形式、ノートブックの一覧） |

論文本文には解析コードを書かず、**ノートブックで作った結果を「埋め込む」**という形をとります。こうすると、解析をやり直したときに論文の図表も自動で更新され、数値の転記ミスもなくなります。

---

## 2. プロジェクトを作る

RStudioのConsoleで以下を実行します。

```r
# 初回のみ
remotes::install_github("ykunisato/psyinfr")

# プロジェクトの作成
psyinfr::set_manuscript()
```

カレントディレクトリに `manuscript` フォルダができます。Research Compendiumの中に作る場合など、場所や名前を変えたいときは引数を指定してください。

```r
psyinfr::set_manuscript(project_name = "sotsuron", output_dir = "paper")
```

### 引数

| 引数 | デフォルト | 説明 |
| --- | --- | --- |
| `project_name` | `"manuscript"` | 作成するフォルダ名 |
| `output_dir` | `"."` | プロジェクトを作る場所 |
| `add_root_dir` | `TRUE` | `FALSE`にすると`output_dir`直下に直接ファイルを置く |
| `overwrite` | `FALSE` | `paper.qmd`や`_quarto.yml`が既にある場合は停止する。`TRUE`で上書き |
| `open` | RStudioなら`TRUE` | 作成後に`paper.qmd`を開く |

### できあがるフォルダ

```
manuscript/
├── _quarto.yml            プロジェクト設定
├── paper.qmd              論文本文（senshuQmdテンプレート）
├── bibliography.bib       引用文献
├── figures/               論文に直接貼る図の置き場
├── _extensions/senshu/    senshu-pdf の書式定義（編集不要）
├── notebooks/
│   ├── Analysis_01.qmd
│   └── Data_collection.qmd
├── data/
│   └── jatos_results_data_demo.txt   動作確認用のデモデータ（100名分）
└── .gitignore
```

`paper.qmd` は [senshuQmd](https://github.com/ykunisato/senshuQmd) テンプレートをダウンロードしたものです。専修大学人間科学部心理学科の卒論・修論の書式で出力されます。

> 補足：`paper.qmd` のYAMLから `format:` の行を外してあります。Manuscriptsプロジェクトでは出力形式を `_quarto.yml` 側でまとめて指定するためです。`paper.qmd` のYAMLには `title` と `author` だけ書き換えてください。

---

## 3. レンダーして出力を確認する

ConsoleでRの関数を実行します。ウェブサイトとPDFの両方が作られます。

```r
psyinfr::render_manuscript("manuscript")
```

書きながらブラウザで確認したいときは、`preview = TRUE` にするとプレビューのサーバーが立ち上がります（止めるときはConsoleでEscキー）。

```r
psyinfr::render_manuscript("manuscript", preview = TRUE)
```

Terminalから直接実行しても同じです。

```bash
cd manuscript
quarto render
```

出力は `_manuscript` フォルダにまとまって作られます。

| ファイル | 内容 |
| --- | --- |
| `_manuscript/index.html` | 論文＋ノートブックのウェブサイト |
| `_manuscript/paper.pdf` | PDF（senshu-pdf） |
| `_manuscript/notebooks/*-preview.html` | 各ノートブックのプレビュー |

`_manuscript` はレンダーのたびに作り直されるので、直接編集しないでください。

### RStudioのRenderボタンについて

RStudioのRenderボタンは `quarto preview` を実行します。プレビューはプロジェクトの**最初の書式（ウェブサイト）しかレンダーしない**仕様で、PDFはウェブサイト上のダウンロードリンクをクリックしたときに作られます。これはQuartoの仕様なので、設定では変えられません。

**毎回PDFまで作りたいときは、Renderボタンではなく `psyinfr::render_manuscript()` を使ってください。**

---

## 4. 【重要】Analysis_01.qmd の結果を paper.qmd に埋め込む

ここがManuscriptsプロジェクトの中心です。手順は **「①ノートブックのチャンクにラベルをつける」→「②論文本文にショートコードを書く」** の2つだけです。

### 4-1. ステップ①：チャンクに `label` をつける

`notebooks/Analysis_01.qmd` のRチャンクに、`#|` で始まるチャンクオプションでラベルをつけます。**ラベルのつけ方には決まりがあります。**

| 出力の種類 | ラベルの先頭 | 一緒に必要なオプション |
| --- | --- | --- |
| 図（プロット） | `fig-` | `fig-cap:`（図のキャプション） |
| 表 | `tbl-` | `tbl-cap:`（表のキャプション） |

**図の例：**

````
```{r}
#| label: fig-plot01
#| fig-cap: "気分得点と睡眠得点の散布図"
ggplot(data, aes(x = sleep_1, y = mood_1)) +
  geom_point()
```
````

**表の例：**

````
```{r}
#| label: tbl-descriptives
#| tbl-cap: "各変数の記述統計"
knitr::kable(psych::describe(data))
```
````

ラベルをつけるときの注意点です。

- `fig-` `tbl-` で始めないと、番号（図1、表1）も相互参照もつきません。
- `fig-cap:` `tbl-cap:` を書き忘れると、キャプションのない図表になり、番号もつきません。
- ラベルは **プロジェクト全体で重複させない** でください（`Analysis_01.qmd` と `Analysis_02.qmd` で同じラベルはNG）。
- ラベルに使えるのは半角英数字とハイフン、アンダースコアです。日本語は使えません。
- `psyinfr::set_manuscript()` が用意する `Analysis_01.qmd` には `descriptives` `plot01` といったラベルが最初から入っています。埋め込みたくなったら `tbl-descriptives` `fig-plot01` のように先頭を付け替えてください。

### 4-2. ステップ②：paper.qmd にショートコードを書く

`paper.qmd` の結果を書きたい場所に、次の1行を書きます。

```
{{< embed notebooks/Analysis_01.qmd#fig-plot01 >}}
```

読み方は「`notebooks/Analysis_01.qmd` というファイルの、`fig-plot01` というラベルのセルの出力をここに貼れ」です。

- パスは **paper.qmd から見た相対パス** です。`paper.qmd` はプロジェクト直下にあるので、いつも `notebooks/` から書き始めます。
- `#` の後ろにはラベルを、`fig-` や `tbl-` も含めてそのまま書きます。
- ショートコードは **段落として独立した行** に書いてください（前後に空行を入れる）。文章の途中には書けません。

### 4-3. 本文から「図1」「表1」と参照する

ラベルの頭に `@` をつけると、番号つきのリンクになります。番号は自動で振られるので、図の順番を入れ替えても直す必要はありません。

```
分析の結果、気分得点と睡眠得点には正の相関がみられた（@fig-plot01）。
各変数の記述統計は @tbl-descriptives に示す。

{{< embed notebooks/Analysis_01.qmd#fig-plot01 >}}

{{< embed notebooks/Analysis_01.qmd#tbl-descriptives >}}
```

これで本文に番号が入り、クリックすると図表に飛びます。参照はショートコードより前に書いても後に書いても構いません。

なお、初期設定では番号が `Figure 1` `Table 1` と英語で表示されます。「図1」「表1」にする方法は付録を見てください。

### 4-4. まとめた実例

**notebooks/Analysis_01.qmd**

````
## 記述統計

```{r}
#| label: tbl-descriptives
#| tbl-cap: "各変数の記述統計"
knitr::kable(psych::describe(data))
```

## 解析

```{r}
#| label: fig-plot01
#| fig-cap: "睡眠得点と気分得点の関係"
ggplot(data, aes(x = sleep_1, y = mood_1)) +
  geom_point() +
  theme_bw()
```
````

**paper.qmd**

```
## 結果

参加者の記述統計を @tbl-descriptives に示す。

{{< embed notebooks/Analysis_01.qmd#tbl-descriptives >}}

睡眠得点と気分得点の関係を @fig-plot01 に示す。

{{< embed notebooks/Analysis_01.qmd#fig-plot01 >}}
```

`paper.qmd` の側では `library()` もデータの読み込みも不要です。埋め込みは「ノートブックを実行した結果を貼り付ける」動作なので、論文側で計算をやり直すことはありません。

### 4-5. コードも一緒に見せたいとき

ショートコードに `echo=true` を足すと、出力の上にそのセルのRコードも表示されます。方法の説明や付録で便利です。

```
{{< embed notebooks/Analysis_01.qmd#fig-plot01 echo=true >}}
```

### 4-6. 図でも表でもない出力を埋め込みたいとき

`summary()` の出力のように、図でも表でもない結果も埋め込めます。この場合ラベルは `fig-` `tbl-` で始めなくて構いません。

````
```{r}
#| label: model-summary
summary(model)
```
````

```
{{< embed notebooks/Analysis_01.qmd#model-summary >}}
```

ただし、この形式では番号（図1、表1）がつかず、`@model-summary` での相互参照もできません。本文から番号で参照したいものは、必ず `fig-` か `tbl-` にしてください。

### 4-7. うまくいかないときのチェックリスト

**`ERROR: The cell fig-xxx does not exist in notebook notebooks/Analysis_01.qmd`**

ショートコードに書いたラベルが、ノートブックの中に見つかりません。

- ラベルのつづりが `#| label:` と一致しているか
- `fig-` や `tbl-` を書き忘れていないか（本文側だけ直しても直りません）
- ノートブックのファイル名・パスが合っているか

**図や表に番号がつかない／`@fig-xxx` が「?fig-xxx」と表示される**

- ラベルが `fig-` `tbl-` で始まっていない
- `fig-cap:` `tbl-cap:` を書いていない

**同じ図が2回出てくる、番号がずれる**

同じラベルのセルを2か所に埋め込むと、同じ図に別々の番号が振られ、`@fig-xxx` のリンク先もずれます。**1つのセルの埋め込みは1か所だけ**にしてください。同じ図を2回見せたい場合は、ノートブック側でセルを分けて別のラベルをつけます。

**PDFに図表が入らない／PDFが更新されない**

RStudioのRenderボタン（プレビュー）はウェブサイトだけを作ります。PDFを確認するときは `psyinfr::render_manuscript()` を使ってください。

**ノートブックを直したのに結果が変わらない**

このプロジェクトは `_quarto.yml` で `execute: freeze: auto` を設定しており、変更のないノートブックは再実行されません（毎回すべて計算し直さないための設定です）。結果が古いままのときは、`_freeze` フォルダを削除してからレンダーし直してください。

**新しいノートブックを追加したとき**

`notebooks/Analysis_02.qmd` のようにファイルを増やしたら、`_quarto.yml` の `notebooks:` にも追記してください。

```yaml
manuscript:
  article: paper.qmd
  notebooks:
    - notebooks/Analysis_01.qmd
    - notebooks/Analysis_02.qmd
    - notebooks/Data_collection.qmd
```

追記しなくても埋め込み自体はできてしまいますが、追記しないと次の2つの問題が起きます。

- ウェブサイトの一覧に載らず、読者がノートブックそのものをダウンロードできない
- そのノートブックだけ作業ディレクトリが `notebooks` フォルダになり、`data/...` でデータを読み込めなくなる

新しいノートブックを作ったら必ず追記する、と覚えておいてください。

---

## 5. データの置き場所

解析用のデータは `data` フォルダに置きます。このフォルダは `set_manuscript()` が作り、動作確認用のデモデータ（JATOS形式・100名分）が最初から入っています。`Analysis_01.qmd` がそれを読み込むようになっているので、**プロジェクトを作った直後でもそのままレンダーできます**。

```
manuscript/
├── data/
│   └── jatos_results_data_demo.txt
└── notebooks/
    └── Analysis_01.qmd
```

自分のデータが集まったら、JATOSからエクスポートしたファイルを同じ `data` フォルダに置き、`Analysis_01.qmd` のファイル名を書き換えてください。

```r
data <- readJatos("data/jatos_results_data_demo.txt", format = "wide")
```

パスの書き方は、**プロジェクト直下からの相対パス**です。`notebooks` フォルダの中にあるファイルからでも `../data/` とは書きません。

これは `_quarto.yml` に次の設定が入っているためです。この設定があると、ノートブックも論文本文も、プロジェクトのルートを作業ディレクトリとしてRのコードが実行されます。消してしまうと `notebooks` フォルダが作業ディレクトリになり、データが読み込めなくなるので注意してください。

```yaml
project:
  type: manuscript
  execute-dir: project
```

個人情報を含むデータや、公開前のデータは `.gitignore` に追加して、GitHubに上がらないようにしてください。

---

## 6. 執筆の流れ（まとめ）

1. `psyinfr::set_manuscript()` でプロジェクトを作る
2. `notebooks/Data_collection.qmd` を書き換えて、cbat4rで調査・実験を作る（JATOSにアップロード）
3. データを集めて、JATOSからエクスポートしたファイルを `data/` に置く（デモデータと差し替える）
4. `notebooks/Analysis_01.qmd` で `psyinfr::readJatos()` を使ってデータを整形し、解析する
5. 図表のチャンクに `fig-` `tbl-` で始まるラベルとキャプションをつける
6. `paper.qmd` に文章を書き、`{{< embed ... >}}` で図表を埋め込み、`@fig-xxx` で参照する
7. `psyinfr::render_manuscript()` でレンダーして `_manuscript/paper.pdf` を確認する

---

## 付録：「Figure 1」を「図1」と表示する

デフォルトでは図表の番号が `Figure 1` `Table 1` と英語で表示されます。日本語にしたい場合は、`_quarto.yml` の末尾に次の1行を追加してレンダーし直してください。

```yaml
lang: ja
```

`図 1` `表 1` と表示されるようになります。
