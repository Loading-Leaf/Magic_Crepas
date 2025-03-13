# まじっくくれぱす
## 子供の想像力と感性を基に新たなアートを生成するアプリケーション

## アプリの公開リンク
https://apps.apple.com/us/app/%E3%81%BE%E3%81%98%E3%81%A3%E3%81%8F%E3%81%8F%E3%82%8C%E3%81%B1%E3%81%99/id6738901848<br>
※リリース段階<br>
2024年12月31日: アプリケーション正式リリース<br>
2025年1月22日: アプリの文字の大きさや配置などを修正<br>
2025年2月21日: アップデート予定※現在使用している<br>
今後: androidで配信予定 <br>
※flutter buildするとエラーが出ているため、コードの理解と最適な手段を行う際に別プロジェクトで使用<br>

## 背景
開発者自身、幼少期よりお絵描きや工作を好んでいたが、引っ越しや大掃除の際に作品を捨てざるを得ず、写真で記録した経験を持つ。
また、現在アルバイト中のキッズプログラミング教室では、
生徒がロボットを改造・プログラミングするものの、共同利用のため分解を余儀なくされる。
これらの経験から、作品の廃棄や分解が子供の感性と想像力を損なうことに問題意識を抱いている。

## 主な機能
主な機能<br>
1. お絵描き<br>
a. パレット→15色を選ぶ<br>
b. カラーブレンド→パレットの15色の中から色を混ぜる<br>
c. 太さ→ペンの太さを変更<br>
d. 筆の選択→筆かブラシを選択<br>
e. スタンプの選択<br>
f. 紙の種類の選択<br>
g. 修正ボタン<br>
h. 描画画面で絵として写真を選択<br>
2. 写真選択<br>
3. 画像生成<br>
a. AIが画像生成完成するまでまちがいさがしで遊んでもらう<br>
b. 子供が描いた絵の画風を写真に反映させる<br>
c. モード選択でアートのパターンを楽しむ<br>
4. アートのシェア→SNSへシェアが可能<br>
5. プロジェクトの保存→アートの作品名とアート、描いた時の気持ちの選択して保存<br>
6. 保存したプロジェクトを見るギャラリー<br>
7. 遊び方ガイド<br>


## ファイル構成
lib <br>
 ├artproject<br>
 │      └audio_provider.dart: 音量や使う音源の種類を一括で管理<br>
 │      └database_helper.dart: 使用する写真を格納する際に使用<br>
 │      └drawing_database_helper.dart: 絵を格納する際に使用<br>
 │      └effects_utils.dart: 画像やボタンなどをタップした際の星型エフェクトを出す仕掛け<br>
 │      └gallery_database_helper.dart: ギャラリーに保存する感情や絵などを格納する際に使用<br>
 │      └language_provider.dart: 仮名文字か漢字どちらかを表示および言語設定するために使用<br>
 │      └modal_provider.dart: 綺麗にモーダルで表示させるために使用<br>
 │      └terms_of_service.dart: 利用規約を表示<br>
 │<br>
 ├Pythoncodes→Pythonanywhere上で使用するコードを可視化※通常は私のGoogle DriveとPythonanywhereに格納<br>
 │          └flask_app.py→Tensorflowを使用した画像生成プロセスを可視化<br>
 │          └magicre.ipynb→まじっくくれぱす上で画像生成するための実験を行った<br>
 │          └segmentation.ipunb: yoloを使ったモデルを保存するために使用<br>
 │<br>
 ├screens<br>
 │      └drawing_page.dart: 絵を描くための画面として使用<br>
 │      └gallery_detail_page.dart: 保存した絵と感情を個別に表示するために使用<br>
 │      └generate_page.dart: 描いた絵と選択した写真を確認するのとAIで生成準備するために使用<br>
 │      └image_gallery_page.dart: 保存した絵を一覧で表示するために使用→絵をタップしたらgallery_detail_page.dartに移動<br>
 │      └main_page.dart: アプリ起動したときに到達するページ→AIで描画するための画面やあそび方に遷移することができる<br>
 │      └output_page.dart: 生成した絵を表示&ギャラリー・端末に保存&別のモードで試す機能が可能<br>
 │      └tutorial_detail_page.dart: お絵描きやまちがいさがしなど具体的なあそび方を閲覧可能<br>
 │      └tutorial_page.dart: あそび方を表示するために表示→選択するとtutorial_detail_page.dartに移動<br>
 │      <br>
 └main.dart→画面遷移と、仮名文字設定と音声を管理<br>

## 工夫した点
・snackbarという画面の下に表示するバーはボタンが押せないことが多い<br>
→改善点としてモーダル表示を活用<br>
・SQLiteを駆使して保存内容やFlaskに送る内容を設定<br>
・if文と関数を駆使して音声を調節・仮名文字か漢字を設定<br>
・領域抽出としてRembgとYoloを組み合わせ<br>
・情報が多すぎる場合は、モーダルやボタンを駆使して別途表示できるようにする<br>

## 画像生成の過程
以下の技術で画像生成を行っている。<br>
1: アプリ上で絵と写真をPythonanywhereに送信<br>
2: 絵と写真を使った画風変換<br>
3: 写真を使い、対象物と背景をRembgとセグメンテーションによって分類<br>
4: モードによって画風変換した画像部分を設定して画像作成<br>
5: 生成した画像をFlaskに送る<br>

## ビルドの段階_iOS
1. Githubにコミット<br>
2. Githubを介してCI/CDツールであるCodemagicにてアプリをビルド<br>
3. ビルド完了したら、App Store Connectにビルドを反映させてTestflightでテストプレイ<br>

## ビルドの段階_android
1. 「flutter build apk --release」を実行<br>
2. Google Driveにapkファイルを入れ、アンドロイド端末でテストプレイ<br>
3. プレイでUIや機能が最適だったらbundleファイルを作成 ※「flutte build appbundle --release」を実行<br>


## 今後のコーディング
・まちがいさがしやギャラリー保存など専用のモーダルを格納するdartファイルをmodal_provider.dartのように使用する予定<br>
・スタンプの種類や色の種類など格納する際、for文でコンパクトにする予定<br>
・英語対応実装中<br>
・第3者に使い勝手と欲しい機能をヒアリングして今後のアップデートで追加予定<br>
