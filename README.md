# MstdnAnalyzer

シンプルなマストドンの解析ツールです。  
[こちらを参考にしています](https://github.com/x0rz/tweets_analyzer)。

ユーザーが面倒くさくなるため、アプリ化をしていません。その為、グローバルなツイートのみしか取得できません。
そんな理由で、できることが少ないです。

出来ること

- [x] ツイート時間帯などの解析

出来ないこと
- [x] ダイレクトメッセージなどのリプライの解析

やろうと思えば出来ることは多いですが、取り合えず現時点でできる事は

- 時間ごとのツイート数の解析
- 曜日ごとのツイート数の解析

となっています。

## Installation

Rubyが必要です。最新版であることが望ましいです。

    $ gem install mstdn_analyzer

## Usage

#### Basic

    $ mstdn_analyzer -i https://mstdn-workers.com -u t0p_l1ght

 サンプリングするtootの数を増やします   

    $ mstdn_analyzer -i https://mstdn-workers.com -u t0p_l1ght

ブーストを含まないで解析します。

mstdn_analyzer -i https://mstdn-workers.com -u t0p_l1ght --no-boost

``` sh
$ mstdn_analyzer help analyze
Usage:
  mstdn_analyzer analyze -i, --instance-url=INSTANCE_URL -u, --username=USERNAME

Options:
  -i, --instance-url=INSTANCE_URL  # [Require]instance url(e.g. https://mstdn-workers.com)
  -u, --username=USERNAME          # [Require]username(e.g. t0p_l1ght)
  -l, [--limit=N]                  # limit the number of toots
                                   # Default: 5000
      [--boost], [--no-boost]      # evaluate boost or does not

analyze toots
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MstdnAnalyzer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mstdn_analyzer/blob/master/CODE_OF_CONDUCT.md).
