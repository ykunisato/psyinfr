
# psyinfr

<!-- badges: start -->
<!-- badges: end -->

psyinfrは心理学のインフラツールとなることを目的としたRパッケージです。

## インストール方法

以下の方法でGitHub経由でインストールができます。

``` r
# install.packages("remotes")
remotes::install_github("ykunisato/psyinfr")
```

## 使用方法

### 使用準備

psyinfrはrstudioとgithubの利用が前提となっていますので，rstudioとgithubアカウントを作成してください。githubでプライベートアカウントを作って，rstudioで使えるようにしてください。

### Research Compendiumの準備

以下を実行すると，研究に必要なファイルとフォルダを用意するResearch Compendiumが作られます。

``` r
psyinfr::set_rc()
```



### 研究ルーティン関数

その日の研究の開始時に以下の関数を実行すると，GitHubのリポジトリからプルを行った上で，ラボノートを作成します。ラボノートは自動で開きますので，適宜メモをとりながら研究を実施して，適宜knitをしてください。

``` r
psyinfr::researchIn()
``` 

その日の研究の終了時に以下の関数を実行すると，ラボノートを保存した上で，変更加えたファイルにコミットを加えた上で，GitHubに自動的にプッシュします。

``` r
psyinfr::researchOut()
```

日々の研究は，researchIn()で初めて，researchOut()で終わります。なお，バックアップ先がOSFが良い場合は，up2osf()も使えます。

### jsPsych課題作成テンプレート(JATOS用)の準備

以下を実行すると、カレントワーキングディレクリーに認知課題名のフォルダを作成し，必要なjsPsych関連ファイルがダウンロードされます。
特に設定をしなくても，その中にあるtask.jsファイルに書き込むだけでjsPsych課題が作成できます。

``` r
psyinfr::set_cbat("stroop", "8.2.2")
```

set_cbat()はversion 0.3.2からjsPsych課題作成テンプレートの提供を[cbat4r](https://github.com/cba-toolbox/cbat4r)パッケージに移管し、psyinfrはcbat4rの関数を再エクスポートする形になりました。それに伴い、旧`use_rc`引数は`output_dir`・`add_root_dir`引数に置き換わっています。

- `output_dir`（デフォルト`"."`）　課題フォルダを作成する場所を指定します。
- `add_root_dir`（デフォルト`TRUE`）　`TRUE`の場合はoutput_dir内に認知課題名のフォルダを作成し、その中にHTMLファイルとjsPsych関連ファイルがダウンロードされます。`FALSE`の場合はoutput_dir直下に配置されます。

旧`use_rc`との対応は以下の通りです。

- 旧 use_rc = 1　→　`set_cbat("stroop", "8.2.2")` (output_dir = ".", add_root_dir = TRUE)
- 旧 use_rc = 2　→　`set_cbat("stroop", "8.2.2", add_root_dir = FALSE)`
- 旧 use_rc = 3　→　`set_cbat("stroop", "8.2.2", output_dir = "exercise")`（exerciseフォルダが存在している必要があります）

### JATOSIFY

「jsPsych課題作成テンプレート(JATOS用)」で作成した課題のフォルダを作業用フォルダにコピーした上で、その作業用フォルダ内で以下のコードを実行すると、JATOSにアップロード可能なJZIPファイルを作れます。
作業用フォルダにコピーしてから作業するのは、作用フォルダ内のフォルダとファイルを丸ごと圧縮するためです。
study_titleに実験（課題）名、html_file_listにjsPsych課題のHTMLのリスト（この順番でJATOS上の実験が行われます）,JATOS_versionにJATOSのバージョンを指定してください。


``` r
psyinfr::jatosify(study_title = "exp01", html_file_list = c("ic.html","age_gender.html","task01.html"), JATOS_version = "3.9")
```

### Quarto Manuscriptsプロジェクトの準備

論文（`paper.qmd`）と解析ノートブックをひとまとめにしたQuarto Manuscriptsプロジェクトを作成します。

``` r
psyinfr::set_manuscript()
```

以下の構成のフォルダが作られます。`paper.qmd`は[senshuQmd](https://github.com/ykunisato/senshuQmd)テンプレートのものです。

```
manuscript/
  _quarto.yml
  paper.qmd            論文（senshuQmdテンプレート）
  bibliography.bib
  figures/
  _extensions/senshu/  senshu-pdf の書式定義
  notebooks/
    Analysis_01.qmd    解析ノートブック（psyinfr::readJatos()でデータを読み込む例）
    Data_collection.qmd データ収集ノートブック（cbat4rで調査を作る例）
  data/
    jatos_results_data_demo.txt  動作確認用のデモデータ（100名分）
```

`data`フォルダにはJATOS形式のデモデータが入っており，`Analysis_01.qmd`がそれを読み込むようになっています。そのためプロジェクトを作った直後でもレンダーが通ります。自分のデータが集まったら`data`フォルダに置いて，`Analysis_01.qmd`のファイル名を書き換えてください。

`Analysis_01.qmd`には，senshuQmdテンプレートと同じような解析の例（記述統計，相関，ヒストグラム，t検定と効果量，平均値の棒グラフ，クロス集計とカイ二乗検定，重回帰分析）と，その結果を`paper.qmd`に埋め込む方法の解説が入っています。実行には`knitr`，`tidyverse`，`psych`，`jtools`，`ggsignif`，`effsize`が必要です。

レンダーには以下を使います。`_manuscript`フォルダにウェブサイト（`index.html`）とPDF（`paper.pdf`）が出力され，ノートブックも一緒に公開されます。

``` r
psyinfr::render_manuscript("manuscript")
```

RStudioのRenderボタンは`quarto preview`を実行しますが，プレビューはプロジェクトの最初の書式（ウェブサイト）しかレンダーせず，PDFはダウンロードのリンクをクリックしたときに作られます。毎回PDFまで作りたい場合は`render_manuscript()`（中身は`quarto render`）を使ってください。プレビューを見ながら書きたい場合は`render_manuscript("manuscript", preview = TRUE)`とすると，全書式をレンダーした上でプレビューが立ち上がります。

出力形式は`_quarto.yml`の`format`で指定しています（そのため`paper.qmd`のYAMLからは`format:`の行を外してあります）。また，`execute-dir: project`を指定しているので，ノートブックからもプロジェクト直下からの相対パス（`data/...`）でデータを読み込めます。

主な引数は以下の通りです。

- `project_name`（デフォルト`"manuscript"`）　作成するプロジェクトのフォルダ名です。
- `output_dir`（デフォルト`"."`）　プロジェクトを作成する場所を指定します。
- `add_root_dir`（デフォルト`TRUE`）　`FALSE`にすると`output_dir`直下にファイルを配置します。
- `overwrite`（デフォルト`FALSE`）　`paper.qmd`や`_quarto.yml`が既にある場合は停止します。`TRUE`で上書きします。

### JATOSの結果データの整形

JATOSからエクスポートした結果データ（1行が1コンポーネントのjsPsychデータになっているテキストファイル）を，Rで解析できる形に整形します。

``` r
d <- psyinfr::readJatos("jatos_results_data_20260809054431.txt")
d
#> <jatos_data>
#>   participants: 5
#>   tasks       : ic, qnr_mood, qnr_sleep, completion_code
```

以下の3つのデータフレームがリストで返ってきます。

- `d$trials`　1行が1試行。`rt`や`trial_type`などの試行レベルの変数がそのまま列になります。
- `d$long`　1行が1つの回答項目（参加者×課題×試行×項目）。`{"mood_1":1,"mood_2":0}`のような`response`が`item`と`value`に展開され，数値に変換できるものは`value_num`にも入ります。
- `d$wide`　1行が1参加者，1列が1項目。統計解析でよく使う形式です。

``` r
head(d$wide)
#>   workerID approval mood_1 mood_2 mood_3 sleep_1 sleep_2 sleep_3 ...
#> 1     1552 説明を...      1      0      1       0       2       1
```

主な引数は以下の通りです。

- `format`（デフォルト`"all"`）　`"trials"`, `"long"`, `"wide"`を指定すると，そのデータフレームだけを返します。
- `id_col`（デフォルト`"workerID"`）/ `task_col`（デフォルト`"taskName"`）　参加者と課題を識別する変数名を指定します。
- `extra_cols`（デフォルト なし）　`d$wide`に加えたい試行レベルの列を指定します。例えば`extra_cols = "id"`とすると，完了コード（参加ID）の列が追加されます。
- `prefix`（デフォルト`"auto"`）　`d$wide`の列名の付け方です。`"auto"`は課題間で重複する項目名（や`response`）にだけ課題名を付け，`"always"`は常に付け，`"never"`は付けません。
- `drop_cols`（デフォルト なし）　`d$trials`から落とす列を指定します。`drop_cols = "stimulus"`とするとHTMLの長い文字列を除けます。

``` r
psyinfr::readJatos("jatos_results_data_20260809054431.txt",
                   format = "wide", extra_cols = "id")
```

なお，1行ごとのテキスト形式だけでなく，ファイル全体がJSON配列の形式や，JATOSのメタデータ付きJSONエクスポートも読み込めます。メタデータ付きの場合は`jatos_workerId`などの列が追加されます。壊れている行はスキップして警告を出します。

### Phase3用テンプレートの準備

以下のように，set_phaser("ゲーム名（英語）","Phaser3のバージョン")を実行すると，exerciseフォルダ内に指定したゲーム名のフォルダを作成し，必要なファイルを用意します(use_rc = FALSEにするとカレントディレクトリー内にフォルダを作ります)。ゲーム名.htmlを開くとデモ的なものがうごきます。ゲーム名のついたフォルダ内のtask.jsファイルを編集していくとゲーム作れます。

``` r
psyinfr::set_phaser("game1","3.80.1",use_rc = TRUE)
```

Research Compendiumを使わない場合は，以下の用にuse_rc = FALSEにします（デフォルトはTRUEです）。

``` r
psyinfr::set_phaser("game1","3.80.1",use_rc = FALSE)
```

なお，Phase3はローカルで動作確認する場合は，ローカルサーバーが必要です。Rでもservrパッケージで簡単にローカルサーバーがたてられるので，以下を実行して表示されたURLで動作確認ができます（RStudioのViewerで見れるので確認が楽です）。

``` r
servr::httd()
```

ローカルサーバーは以下で止められます。

``` r
servr::daemon_stop(1)
```
  

### 高負荷計算関数

負荷の高い計算をするために一時的に高スペックなPCやサーバーを使用する場合，解析が終了したら通知し，自動的にGitHubにアップされると便利です。そのために，まず，以下でgitとslackの設定をします（なお，slackはご自身でSlack APIの設定をされて，メッセージを送信するチャンネルとトークンが取得済みとします。また，RstudioにGitHubリポジトリをクローン済みとします）。

``` r
psyinfr::setGitSlack(git_name,git_email,slack_token,slack_channel)
```

上記の関数で，slackとgithubの設定ができたら，runHighLoad()で高負荷なRコードを書いたファイルを指定します。指定するRファイルは１つでも走りますが（Stanなどが想定されます），複数のファイルも指定できます。複数ファイルが指定されたら，parallel::parLapply()で並列化して実行します。計算がすべて終了したら，slackの設定したチャンネルに「2022/03/15 06:05  負荷の高い計算が終了しました。関連するファイルをコミットしてプッシュしました。」といったメッセージが送付され，リポジトリの更新されたファイルはコミットされて，プッシュされます。

``` r
psyinfr::runHighLoad(c("t1.R","t2.R","t3.R"))
```



