import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_art/artproject/audio_provider.dart';
import 'package:ai_art/artproject/effect_utils.dart';
import 'tutorial_detail_page.dart';
import 'package:ai_art/artproject/language_provider.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int page = 1;
  final int itemsPerPage = 4;
  final int totalItems = 8; // 総アイテム数を設定

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double fontsize_big = screenSize.width / 64;
    double fontsize = screenSize.width / 74.6;
    final audioProvider = Provider.of<AudioProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    List<Widget> buildTutorialGrid() {
      List<Widget> rows = [];
      int startIndex = (page - 1) * itemsPerPage;
      int endIndex = startIndex + itemsPerPage;

      List<String> chapters1 = [
        languageProvider.isHiragana ? "これはさいしょのがめんだよ" : "これは最初の画面だよ",
        languageProvider.isHiragana
            ? "「AIでアートをつくる」をおしてみてね"
            : "「AIでアートを作る」を押してみてね",
        languageProvider.isHiragana
            ? "これはえをつくるがめんだよ\nまえにつくったえもあるよ"
            : "これは絵を作る画面だよ\n前に作った絵もあるよ",
        languageProvider.isHiragana
            ? "えをかくときは「おえかきする」をおしてね"
            : "絵を描くときは「お絵描きする」を押してね",
        languageProvider.isHiragana
            ? "おおきなかみやカラフルなパレット、ふで、スタンプなどでえをかくよ"
            : "大きな紙とカラフルなパレット、筆、スタンプなどで絵を描くよ",
        languageProvider.isHiragana
            ? "うえからパレット、ふで、かみのいろをえらぶことができるよ\nくわしくは「おえかき」のあそびかたをみてね"
            : "上からパレット、筆、紙の色を選ぶことができるよ\n詳しくは「お絵描き」のあそび方を見てね",
        languageProvider.isHiragana ? "えをかいてみたよ" : "絵を描いてみたよ",
        languageProvider.isHiragana
            ? "えをかきおわったら「できたよ」をおしてね"
            : "絵を描き終わったら「できたよ」を押してね",
        languageProvider.isHiragana ? "かいたえがここにあるよ" : "描いた絵がここにあるよ",
        languageProvider.isHiragana
            ? "つぎはしゃしんをえらんでみよう\n「しゃしんをえらぶ」をおしてね"
            : "次は写真を選んでみよう\n「写真を選ぶ」を押してね",
        languageProvider.isHiragana ? "しゃしんアプリからしゃしんをえらんだよ" : "写真アプリから写真を選んだよ",
        languageProvider.isHiragana
            ? "モードをかえてみよう\nモードによってしゃしんをきりぬくほうほうがかわるよ"
            : "モードを変えてみよう\nモードによって写真を切り抜く方法が変わるよ",
        languageProvider.isHiragana
            ? "このボタンをおすとそれぞれのモードのとくちょうがみられるよ"
            : "このボタンを押すとそれぞれのモードの特徴が見られるよ",
        languageProvider.isHiragana
            ? "それぞれのモードについてはなすよ！\n「モードA」はえのせかいにはいれるし、「モードB」はえのなかにものをよびだせるんだよ！"
            : "それぞれのモードについて話すよ！\n「モードA」は絵の世界に入れるし、「モードB」は絵の中に物を呼び出せるんだよ！",
        languageProvider.isHiragana
            ? "「モードA」はひとがたくさんいるときやテーブルがあるときにおすすめ！"
            : "「モードA」は人がたくさんいる時やテーブルがある時にオススメ！",
        languageProvider.isHiragana
            ? "「モードB」はおやつやちいさいものがちかくにあるときにおすすめ！\nでも、たくさんひとがいるしゃしんにはむいていないよ"
            : "「モードB」はおやつや小さい物が近くにある時にオススメ！\nでも、たくさん人がいる写真には向いていないよ",
        languageProvider.isHiragana
            ? "「モードC」ははいけいいがいをアートにしたいときにおすすめ！"
            : "「モードC」は背景以外をアートにしたい時にオススメ！",
        languageProvider.isHiragana
            ? "「モードD」はおやつやちいさいものをアートにしたいときにおすすめ！"
            : "「モードD」はおやつや小さい物をアートにしたい時にオススメ！",
        languageProvider.isHiragana
            ? "「アートをつくる」で「モードA」のアートをつくろう！\n※ネットがつながっているところでやってね"
            : "「アートをつくる」で「モードA」のアートを作ろう！\n※ネットがつながっているところでやってね",
        languageProvider.isHiragana
            ? "AIがえをつくっているあいだに、まちがいさがしであそぼう"
            : "AIが絵を作っている間に、間違いさがしで遊ぼう",
        languageProvider.isHiragana
            ? "おとがなったらえがかんせいするよ！\nえがかんせいすると、まちがいさがしのこたえもみれるよ"
            : "音が鳴ったら絵が完成するよ！\n絵が完成すると、間違いさがしの答えも見れるよ",
        languageProvider.isHiragana
            ? "おとがなったらえがかんせいするよ！\n「かんせいしたえをみる」をおしてね"
            : "音が鳴ったら絵が完成するよ！\n「完成した絵を見る」を押してね",
        languageProvider.isHiragana
            ? "つくったえとおえかきしたえがみられるよ"
            : "作った絵とお絵描きした絵が見られるよ",
        languageProvider.isHiragana ? "つくったえをほぞんしてみよう" : "作った絵を保存してみよう",
        languageProvider.isHiragana ? "おえかきしたえもほぞんしてみよう" : "お絵描きした絵も保存してみよう",
        languageProvider.isHiragana
            ? "つくったえとおえかきしたえをタッチしてみよう\nそうするとおおきくみれるよ"
            : "作った絵とお絵描きした絵をタッチしてみよう\nそうすると大きく見れるよ",
        languageProvider.isHiragana ? "SNSなどにシェアしてみよう" : "SNSなどにシェアしてみよう",
        languageProvider.isHiragana
            ? "これであそびかたはおわりだよ！\nおえかき、たのしんでね！！！"
            : "これで遊び方は終わりだよ！\nお絵描き、楽しんでね！！！"
      ];

      List<String> chapters2 = [
        languageProvider.isHiragana ? "これはおえかきのがめんだよ" : "これはお絵描きの画面だよ",
        languageProvider.isHiragana
            ? "パレットでつかいたいいろをせんたくできるよ\nみぎのパレットマークをおすといろをえらべるよ"
            : "パレットで使いたい色を選択できるよ\n右のパレットマークを押すと色を選べるよ",
        languageProvider.isHiragana
            ? "「+」をおすといろをまぜることができて\nあたらしいいろができるよ"
            : "「+」を押すと色を混ぜることができて\n新しい色ができるよ",
        languageProvider.isHiragana
            ? "まちがえたらもどしたりやりなおしたりできるよ"
            : "間違えたら戻したりやり直したりできるよ",
        languageProvider.isHiragana
            ? "みぎのふでマークをおすとふでのせっていができるよ"
            : "右の筆マークを押すと筆の設定ができるよ",
        languageProvider.isHiragana
            ? "ふでやスタンプのおおきさをかえることができるよ"
            : "筆やスタンプの大きさを変えることができるよ",
        languageProvider.isHiragana
            ? "ふでやスタンプのしゅるいをかえることができるよ"
            : "筆やスタンプの種類を変えることができるよ",
        languageProvider.isHiragana
            ? "くろじがペンのしゅるい, \nむらさきのじがスタンプのしゅるいだよ"
            : "黒字がペンの種類, \n紫の字がスタンプの種類だよ",
        languageProvider.isHiragana
            ? "みぎのしかくをおすと、かみのいろのせっていができるよ"
            : "右の四角を押すと、紙の色の設定ができるよ",
        languageProvider.isHiragana ? "このなかからかみのいろをかえれるよ" : "この中から紙の色を変えれるよ",
        languageProvider.isHiragana ? "さっそくおえかきをしてみよう" : "さっそくお絵描きをしてみよう",
        languageProvider.isHiragana ? "まず、あかをえらんで、" : "まず、赤を選んで、",
        languageProvider.isHiragana
            ? "ペンをせんたくして、ひだりのかみにかいてみよう"
            : "ペンを選択して、左の紙に描いてみよう",
        languageProvider.isHiragana
            ? "せんがでてきたよ\nみぎのふでのおおきさとふでのいろはパレットでえらんだいろとおなじになるよ"
            : "線が出てきたよ\n右の筆の大きさと筆の色はパレットで選んだ色と同じになるよ",
        languageProvider.isHiragana
            ? "つぎ、ブラシでかいてみよう\nてんだらけだね"
            : "次、ブラシで描いてみよう\n点だらけだね",
        languageProvider.isHiragana ? "いっかい、あおいかみにかえてみよう" : "一回、青い紙に変えてみよう",
        languageProvider.isHiragana
            ? "ひととおりかいたら、いっかいいろをまぜるカラーブレンドをつかってみよう"
            : "一通り描いたら、一回色を混ぜるカラーブレンドを使ってみよう",
        languageProvider.isHiragana ? "ここではふたつのいろをまぜるよ" : "ここでは2つの色を混ぜるよ",
        languageProvider.isHiragana ? "いろ1のしかくをおしてみよう" : "色1の四角を押してみよう",
        languageProvider.isHiragana
            ? "おしたらみぎのパレットからすきないろをえらぶよ"
            : "押したら右のパレットから好きな色を選ぶよ",
        languageProvider.isHiragana ? "おなじようにいろ2もやってみよう" : "同じように色2もやってみよう",
        languageProvider.isHiragana
            ? "せんたくしたらパレットにていろ1にがいとうするわくがなくなったよ"
            : "選択したらパレットにて色1に該当する枠がなくなったよ",
        languageProvider.isHiragana ? "おなじようにパレットでえらぼう" : "同じようにパレットで選ぼう",
        languageProvider.isHiragana
            ? "いろ2をえらんだら、「いろをまぜる」でまぜてみよう"
            : "色2を選んだら、「色を混ぜる」で混ぜてみよう",
        languageProvider.isHiragana
            ? "したのほうにまぜたいろができました\nこんかいはオレンジとみどりをあわせたいろだよ"
            : "下の方に混ぜた色ができました\n今回はオレンジと緑を合わせた色だよ",
        languageProvider.isHiragana
            ? "もしまぜたいろがおもいどおりでないときは、「やりなおす」をおしてね"
            : "もし混ぜた色が思い通りでない時は、「やり直す」を押してね",
        languageProvider.isHiragana
            ? "もしOKだったら「これでOK」をおしてね"
            : "もしOKだったら「これでOK」を押してね",
        languageProvider.isHiragana
            ? "OKなのでこれでOKをおします\nちなみにさいだい6しょくつくることができるよ"
            : "OKなのでこれでOKを押します\nちなみに最大6色作ることができるよ",
        languageProvider.isHiragana
            ? "「これでOK」をおしてすぐはできたいろがでてこないので、\nいっかいパレットのいろやみぎのロゴをおしたりしてみよう"
            : "「これでOK」を押してすぐはできた色が出てこないので、\n一回パレットの色や右のロゴを押したりしてみよう",
        languageProvider.isHiragana
            ? "そうするとパレットのしたのほうにまぜたいろがでてきたよ"
            : "そうするとパレットの下の方に混ぜた色が出てきたよ",
        languageProvider.isHiragana ? "いっかい、まぜたいろでいろぬりしたよ" : "一回、混ぜた色で色塗りしたよ",
        languageProvider.isHiragana
            ? "えができたら「できたよ」をおしてね\nこれであそびかたはおわりだよ！"
            : "絵ができたら「できたよ」を押してね\nこれで遊び方は終わりだよ！"
      ];

      List<String> chapters3 = [
        languageProvider.isHiragana
            ? "えをつくっているあいだはまちがいさがしであそぶよ"
            : "絵を作っている間はまちがいさがしで遊ぶよ",
        languageProvider.isHiragana
            ? "かんせいしてないあいだはまちがいさがしのこたえと\nかんせいしたえはまだみれないよ"
            : "完成してない間はまちがいさがしの答えと\n完成した絵はまだ見れないよ",
        languageProvider.isHiragana
            ? "みぎのえでまちがいなどみつけたら、そのばしょをタッチしてね"
            : "右の絵でまちがいなど見つけたら、その場所をタッチしてね",
        languageProvider.isHiragana
            ? "ひとつタッチしたよ\nタッチしたらそのばしょにあかいまるがでてくるよ"
            : "1つタッチしたよ\nタッチしたらその場所に赤い丸が出てくるよ",
        languageProvider.isHiragana
            ? "タッチしたばしょをまちがえたらもどしたりやりなおしたりできるよ"
            : "タッチした場所を間違えたら戻したりやり直したりできるよ",
        languageProvider.isHiragana ? "そうするとあかいまるがひとつきえたよ" : "そうすると赤い丸が1つ消えたよ",
        languageProvider.isHiragana
            ? "おとがなり、「えができたよ」のウインドウがでたら\nえがかんせいしたよ"
            : "音が鳴り、「絵ができたよ」のウインドウが出たら\n絵が完成したよ",
        languageProvider.isHiragana ? "まちがいさがしのこたえをみてみよう" : "まちがいさがしの答えを見てみよう",
        languageProvider.isHiragana
            ? "かんせいしたえをみるをおしたらまちがいさがしはおわり、\nできたえをみることができるよ\nこれであそびかたはおわりだよ！"
            : "完成した絵を見るを押したらまちがいさがしは終わり、\nできた絵を見ることができるよ\nこれで遊び方は終わりだよ！"
      ];

      List<String> chapters4 = [
        languageProvider.isHiragana ? "かんせいしたあとのがめんだよ" : "完成した後の画面だよ",
        languageProvider.isHiragana
            ? "もしえなどをほぞんしてきろくしたいばあいは\n「プロジェクトをほぞん」をおしてね"
            : "もし絵などを保存して記録したい場合は\n「プロジェクトを保存」を押してね",
        languageProvider.isHiragana
            ? "そうするとほぞんようのウインドウがでてくるよ"
            : "そうすると保存用のウィンドウが出てくるよ",
        languageProvider.isHiragana ? "いっかいタイトルをかいてみよう" : "一回タイトルを書いてみよう",
        languageProvider.isHiragana
            ? "ゆうやけとシャーベットのくみあわせなので\n「ゆうやけシャーベット」にするよ"
            : "夕焼けとシャーベットの組み合わせなので\n「夕焼けシャーベット」にするよ",
        languageProvider.isHiragana ? "にゅうりょくしたら「すすむ」をおしてね" : "入力したら「進む」を押してね",
        languageProvider.isHiragana
            ? "つぎ、えをかいたときのきもちをえらんでね"
            : "次、絵を描いた時の気持ちを選んでね",
        languageProvider.isHiragana
            ? "こんかいはかんどうしたときにかいたから「かんどうする」をおしてね"
            : "今回は感動した時に描いたから「かんどうする」を押してね",
        languageProvider.isHiragana ? "そうすると、つぎのがめんにいったよ" : "そうすると、次の画面に行ったよ",
        languageProvider.isHiragana
            ? "いっかい、「もどる」でえらんだかんじょうをかくにんしてみよう"
            : "一回、「戻る」で選んだ感情を確認してみよう",
        languageProvider.isHiragana
            ? "さっきえらんだかんじょうは、ピンクいろにかわっているよ\nもしえをかいたときのきもちがちがうなどあったらかえれるよ"
            : "さっき選んだ感情は、ピンク色に変わっているよ\nもし描いた時の気持ちが違うなどあったら変えれるよ",
        languageProvider.isHiragana
            ? "もし「かんどうする」のままにしたかったら「すすむ」をおしてね"
            : "もし「かんどうする」のままにしたかったら「進む」を押してね",
        languageProvider.isHiragana
            ? "さいご、かいたときにさらにかんじたきもちをかいてね"
            : "最後、描いた時にさらに感じた気持ちを書いてね",
        languageProvider.isHiragana ? "ここでかんじょうをかくことができるよ" : "ここで感情を書くことができるよ",
        languageProvider.isHiragana
            ? "シャーベットのあじにかんどうしたので\n「とてもおいしかったです」とかいたよ"
            : "シャーベットの味に感動したので\n「とても美味しかったです」と書いたよ",
        languageProvider.isHiragana ? "できたら「すすむ」をおすよ" : "できたら「進む」を押すよ",
        languageProvider.isHiragana ? "そうするとほぞんできたよ" : "そうすると保存できたよ",
        languageProvider.isHiragana
            ? "さいご、ギャラリーにてほぞんしたプロジェクトがみれるよ\nくわしくはギャラリーのあそびかたをみてね\nこれであそびかたはおわりだよ！"
            : "最後、ギャラリーにて保存したプロジェクトが見れるよ\n詳しくはギャラリーの遊び方を見てね\nこれで遊び方は終わりだよ！"
      ];

      List<String> chapters5 = [
        languageProvider.isHiragana
            ? "いろえんぴつやクレヨンなどでかいたえもまじっくくれぱすで\nつかえるようになったよ"
            : "色鉛筆やクレヨンなどで描いた絵もまじっくくれぱすで\n使えるようになったよ",
        languageProvider.isHiragana ? "「しゃしんからえらぶ」をおしてね" : "「写真から選ぶ」を押してね",
        languageProvider.isHiragana
            ? "そうすると、せいせいじゅんびがめんにもどってしゃしんにあるえをつかうことができるよ"
            : "そうすると、生成準備画面に戻って写真にある絵を使うことができるよ",
        languageProvider.isHiragana
            ? "クレヨンでかいたゆうやけのえをえらんだよ"
            : "クレヨンで描いた夕焼けの絵を選んだよ",
        languageProvider.isHiragana
            ? "えとしゃしんをえらんだのでアートをつくるじゅんびかんりょうだよ\nいっかいつくってみよう"
            : "絵と写真を選んだのでアートを作る準備完了だよ\n一回作ってみよう",
        languageProvider.isHiragana
            ? "モードCでかいたえだよ\nつくったえをタップしてみよう"
            : "モードCで描いた絵だよ\n作った絵をタップしてみよう",
        languageProvider.isHiragana
            ? "クレヨンのようにアートができているね"
            : "クレヨンのようにアートができているね",
        languageProvider.isHiragana
            ? "いろえんぴつやクレヨン、パステルなどでもためしてみてね\nこれであそびかたはおわりだよ！"
            : "色鉛筆やクレヨン、パステルなどでも試してみてね\nこれで遊び方は終わりだよ！"
      ];

      List<String> chapters6 = [
        languageProvider.isHiragana
            ? "ほぞんしたプロジェクトがあるギャラリーはホームがめんからいけるよ"
            : "保存したプロジェクトがあるギャラリーはホーム画面から行けるよ",
        languageProvider.isHiragana ? "「ギャラリーをみる」をおしてね" : "「ギャラリーを見る」を押してね",
        languageProvider.isHiragana
            ? "ギャラリーにはいままでほぞんしたプロジェクトがいっぱいあるよ"
            : "ギャラリーには今まで保存したプロジェクトがいっぱいあるよ",
        languageProvider.isHiragana
            ? "きろくしたえをひとつえらぶよ\nためしにひだりの「ゆうやけシャーベット」をえらんでみるね"
            : "記録した絵を１つ選ぶよ\n試しに左の「夕焼けシャーベット」を選んでみるね",
        languageProvider.isHiragana
            ? "そうすると、ほぞんのときにえらんだかんじょうやタイトルがでてくるよ"
            : "そうすると、保存の時に選んだ感情やタイトルが出てくるよ",
        languageProvider.isHiragana
            ? "また、つくったえなどをタップすると、かくだいしてみれるよ"
            : "また、作った絵などをタップすると、拡大して見れるよ",
        languageProvider.isHiragana ? "そうすると、おおきくなったよ" : "そうすると、大きくなったよ",
        languageProvider.isHiragana
            ? "AIによってできたあとのおなじようにえなどをほぞんできるよ"
            : "AIによってできた後と同じように絵などを保存できるよ",
        languageProvider.isHiragana ? "「くわしくみる」をおしてみるね" : "「詳しく見る」を押してみるね",
        languageProvider.isHiragana
            ? "そうするとしょうさいなきもちとえをつくったときにつかったしゃしんがみれるよ"
            : "そうすると詳細な気持ちと絵を作った時に使った写真が見れるよ",
        languageProvider.isHiragana
            ? "プロジェクトをさくじょすることもできるよ"
            : "プロジェクトを削除することもできるよ",
        languageProvider.isHiragana
            ? "そうすると、さくじょのかくにんがくるよ\n「さくじょする」をおしたらそのプロジェクトがきえるよ"
            : "そうすると、削除の確認がくるよ\n「削除する」を押したらそのプロジェクトが消えるよ",
        languageProvider.isHiragana ? "これであそびかたはおわりだよ！" : "これで遊び方は終わりだよ！"
      ];

      List<String> chapters7 = [
        languageProvider.isHiragana
            ? "えがかんせいしたあと、べつのモードでたのしむことができるよ"
            : "絵が完成した後、別のモードで楽しむことができるよ",
        languageProvider.isHiragana ? "「べつのモードをつかう」をおしてみて" : "「別のモードを使う」を押してみて",
        languageProvider.isHiragana
            ? "そうするとほかのモードのひかくがぞうとモードせんたくができるよ"
            : "そうすると他のモードの比較画像とモード選択ができるよ",
        languageProvider.isHiragana
            ? "ためしたいモードをえらぶよ\nここではモードCでやるよ"
            : "試したいモードを選ぶよ\nここではモードCでやるよ",
        languageProvider.isHiragana
            ? "おなじようにつくっているあいだはまちがいさがしをするよ"
            : "同じように作っている間はまちがいさがしをするよ",
        languageProvider.isHiragana
            ? "べつモードでためしたえがでてきたよ\nこれであそびかたはおわりだよ"
            : "別モードで試した絵が出てきたよ\nこれで遊び方は終わりだよ"
      ];

      List<String> chapters8 = [
        languageProvider.isHiragana
            ? "おととよみがなのせっていのやりかたをおしえるね"
            : "音と読み仮名の設定のやり方を教えるね",
        languageProvider.isHiragana ? "「せってい」ボタンをおしてね" : "「設定」ボタンを押してね",
        languageProvider.isHiragana
            ? "そうするとせっていウインドウがでてきたよ\nおとなしはおんりょう0、おとありはおとつきであそべるよ"
            : "そうすると設定ウインドウが出てきたよ\n音なしは音量0、音ありは音付きで遊べるよ",
        languageProvider.isHiragana
            ? "つぎ、「ひらがなカタカナ」をえらんでよみがなへんこうできるよ"
            : "次、「ひらがなカタカナ」を選んで読み仮名変更できるよ",
        languageProvider.isHiragana
            ? "そうするとうしろはひらがなになったよ\n※りようきやくとおといあわせはいじょう"
            : "そうすると後ろはひらがなになったよ\n※利用規約とお問い合わせは除く",
        languageProvider.isHiragana
            ? "すべてひらがなになったホームがめんだよ"
            : "全てひらがなになったホーム画面だよ",
        languageProvider.isHiragana
            ? "また「せってい」をおすとかんじに戻せるよ"
            : "また「せってい」を押すと漢字に戻せるよ",
        languageProvider.isHiragana
            ? "「かんじ」にもどすとうしろはかんじでもかかれるよ"
            : "「漢字」に戻すと後ろは漢字でも書かれるよ",
        languageProvider.isHiragana ? "これであそびかたはおわりだよ" : "これで遊び方は終わりだよ"
      ];

      List<Map<String, dynamic>> tutorialItems = [
        {
          'title': page == 1
              ? (languageProvider.isHiragana ? 'ひととおりのやりかた' : '一通りのやりかた')
              : (languageProvider.isHiragana ? "おえかき2" : "お絵描き2"),
          'chapters': page == 1 ? chapters1 : chapters5,
          'tutorialNumber': page == 1 ? 1 : 5,
        },
        {
          'title': page == 1
              ? (languageProvider.isHiragana ? 'おえかき' : 'お絵描き')
              : 'ギャラリー',
          'chapters': page == 1 ? chapters2 : chapters6,
          'tutorialNumber': page == 1 ? 2 : 6,
        },
        {
          'title': page == 1
              ? 'まちがいさがし'
              : (languageProvider.isHiragana ? 'べつのモード' : '別のモード'),
          'chapters': page == 1 ? chapters3 : chapters7,
          'tutorialNumber': page == 1 ? 3 : 7,
        },
        {
          'title': page == 1
              ? (languageProvider.isHiragana ? 'プロジェクトほぞん' : 'プロジェクト保存')
              : (languageProvider.isHiragana ? 'せってい' : "設定"),
          'chapters': page == 1 ? chapters4 : chapters8,
          'tutorialNumber': page == 1 ? 4 : 8,
        },
      ];

      // 利用可能なアイテム数に基づいて終了インデックスを調整
      endIndex = endIndex.clamp(0, totalItems);

      // 2行2列のグリッドを作成
      for (int rowIndex = 0; rowIndex < 2; rowIndex++) {
        List<Widget> rowChildren = [];

        for (int colIndex = 0; colIndex < 2; colIndex++) {
          int itemIndex = (rowIndex * 2) + colIndex;

          if (itemIndex < endIndex && itemIndex < tutorialItems.length) {
            rowChildren.add(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      height: screenSize.width * 0.094,
                      width: screenSize.width * 0.20,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image.asset(
                          'assets/tutorial/${itemIndex + 1 + (page - 1) * 4}.png',
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: Text(
                      tutorialItems[itemIndex]['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 67, 195),
                    ),
                    onPressed: () {
                      audioProvider.playSound("tap1.mp3");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TutorialDetailPage(
                            tutorialnumber: tutorialItems[itemIndex]
                                ["tutorialNumber"],
                            chapters: tutorialItems[itemIndex]["chapters"],
                            title: tutorialItems[itemIndex]["title"],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            // 空のウィジェットを追加して配置を維持
            rowChildren.add(SizedBox(
              width: screenSize.width * 0.20,
              height: screenSize.width * 0.094 + 48, // ボタンの高さを考慮
            ));
          }
        }

        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowChildren,
          ),
        );
      }

      return rows;
    }

    return PopScope(
      // ここを追加
      canPop: false, // false で無効化
      child: Scaffold(
        body: GestureDetector(
          onTapUp: (details) {
            showSparkleEffect(context, details.localPosition);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  languageProvider.isHiragana ? 'あそびかた' : 'あそび方',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize_big,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: page > 1
                            ? Color.fromARGB(255, 255, 67, 195)
                            : const Color.fromARGB(255, 199, 198, 198)),
                    onPressed: () {
                      if (page > 1) {
                        setState(() => page -= 1);
                        audioProvider.playSound("tap1.mp3");
                      }
                    },
                    tooltip: 'left',
                    splashColor: Color.fromARGB(255, 255, 67, 195),
                    iconSize: MediaQuery.of(context).size.width / 28,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildTutorialGrid(),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward,
                        color: page < 2
                            ? Color.fromARGB(255, 255, 67, 195)
                            : const Color.fromARGB(255, 199, 198, 198)),
                    onPressed: () {
                      if (page * itemsPerPage < totalItems) {
                        setState(() => page += 1);
                        audioProvider.playSound("tap1.mp3");
                      }
                    },
                    tooltip: 'right',
                    splashColor: Color.fromARGB(255, 255, 67, 195),
                    iconSize: MediaQuery.of(context).size.width / 28,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      audioProvider.playSound("tap1.mp3");
                      Navigator.pushNamed(context, '/');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 204, 255),
                    ),
                    child: Text(
                      languageProvider.isHiragana ? 'ホームにもどる' : 'ホームに戻る',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontsize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
