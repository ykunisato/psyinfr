
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

### jsPsych課題作成テンプレートの準備

以下のように，set_cbat("認知課題名（英語）","jsPsychのバージョン")を実行すると，exerciseフォルダ内に指定した認知課題名のフォルダを作成し，必要なjsPsych関連ファイルがダウンロードされます。特に設定をしなくても，その中にあるtask.jsファイルに書き込むだけでjsPsych課題が作成できます。なお，デフォルトのバージョンは"8.0.1"になるので，バージョンの情報を入れないと"8.0.1"が入ります。

``` r
psyinfr::set_cbat("stroop", "8.2.1")
```

Research Compendiumを使わない場合は，以下の用にuse_rc = FALSEにします（デフォルトはTRUEです）。

``` r
psyinfr::set_cbat("stroop", "8.2.1", use_rc = FALSE)
```

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



