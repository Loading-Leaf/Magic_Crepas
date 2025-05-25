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
      int startIndex = (page - 1) * itemsPerPage; //1ページごと4個のあそび方を準備
      int endIndex = startIndex + itemsPerPage;

      //chaptersn: それぞれのあそび方で使用する文章
      List<String> chapters1 = [
        languageProvider.locallanguage == 2
            ? "This is the first screen!"
            : languageProvider.isHiragana
                ? "これはさいしょのがめんだよ"
                : "これは最初の画面だよ",
        languageProvider.locallanguage == 2
            ? "Try tapping 'Create art with AI'"
            : languageProvider.isHiragana
                ? "「AIでアートをつくる」をおしてみてね"
                : "「AIでアートを作る」を押してみてね",
        languageProvider.locallanguage == 2
            ? "This is the drawing screen.\nYou can also see previous artwork!"
            : languageProvider.isHiragana
                ? "これはえをつくるがめんだよ\nまえにつくったえもあるよ"
                : "これは絵を作る画面だよ\n前に作った絵もあるよ",
        languageProvider.locallanguage == 2
            ? "Tap 'Start Drawing' to begin!"
            : languageProvider.isHiragana
                ? "えをかくときは「おえかきする」をおしてね"
                : "絵を描くときは「お絵描きする」を押してね",
        languageProvider.locallanguage == 2
            ? "Use a big canvas, colorful palette, brushes, and stamps to draw!"
            : languageProvider.isHiragana
                ? "おおきなかみやカラフルなパレット、ふで、スタンプなどでえをかくよ"
                : "大きな紙とカラフルなパレット、筆、スタンプなどで絵を描くよ",
        languageProvider.locallanguage == 2
            ? "You can choose the palette, brush, and paper color from above.\nSee 'How to Draw' for details!"
            : languageProvider.isHiragana
                ? "うえからパレット、ふで、かみのいろをえらぶことができるよ\nくわしくは「おえかき」のあそびかたをみてね"
                : "上からパレット、筆、紙の色を選ぶことができるよ\n詳しくは「お絵描き」の遊び方を見てね",
        languageProvider.locallanguage == 2
            ? "I tried drawing!"
            : languageProvider.isHiragana
                ? "えをかいてみたよ"
                : "絵を描いてみたよ",
        languageProvider.locallanguage == 2
            ? "When you're done, tap 'Finished!'"
            : languageProvider.isHiragana
                ? "えをかきおわったら「できたよ」をおしてね"
                : "絵を描き終わったら「できたよ」を押してね",
        languageProvider.locallanguage == 2
            ? "Here's the drawing you made!"
            : languageProvider.isHiragana
                ? "かいたえがここにあるよ"
                : "描いた絵がここにあるよ",
        languageProvider.locallanguage == 2
            ? "Next, select a photo.\nTap 'Select Photo'"
            : languageProvider.isHiragana
                ? "つぎはしゃしんをえらんでみよう\n「しゃしんをえらぶ」をおしてね"
                : "次は写真を選んでみよう\n「写真を選ぶ」を押してね",
        languageProvider.locallanguage == 2
            ? "Selected a photo from the photo app!"
            : languageProvider.isHiragana
                ? "しゃしんアプリからしゃしんをえらんだよ"
                : "写真アプリから写真を選んだよ",
        languageProvider.locallanguage == 2
            ? "Try changing modes!\nThe method of cutting out photos changes with the mode"
            : languageProvider.isHiragana
                ? "モードをかえてみよう\nモードによってしゃしんをきりぬくほうほうがかわるよ"
                : "モードを変えてみよう\nモードによって写真を切り抜く方法が変わるよ",
        languageProvider.locallanguage == 2
            ? "This button shows the features of each mode!"
            : languageProvider.isHiragana
                ? "このボタンをおすとそれぞれのモードのとくちょうがみられるよ"
                : "このボタンを押すとそれぞれのモードの特徴が見られるよ",
        languageProvider.locallanguage == 2
            ? "Let me explain the modes!\nMode A lets you enter the drawing world, Mode B lets you summon things into your drawing!"
            : languageProvider.isHiragana
                ? "それぞれのモードについてはなすよ！\n「モードA」はえのせかいにはいれるし、「モードB」はえのなかにものをよびだせるんだよ！"
                : "それぞれのモードについて話すよ！\n「モードA」は絵の世界に入れるし、「モードB」は絵の中に物を呼び出せるんだよ！",
        languageProvider.locallanguage == 2
            ? "Mode A is great when there are lots of people or a table!"
            : languageProvider.isHiragana
                ? "「モードA」はひとがたくさんいるときやテーブルがあるときにおすすめ！"
                : "「モードA」は人がたくさんいる時やテーブルがある時にオススメ！",
        languageProvider.locallanguage == 2
            ? "Mode B is great when there are snacks or small items nearby!\nBut it's not good for photos with many people"
            : languageProvider.isHiragana
                ? "「モードB」はおやつやちいさいものがちかくにあるときにおすすめ！\nでも、たくさんひとがいるしゃしんにはむいていないよ"
                : "「モードB」はおやつや小さい物が近くにある時にオススメ！\nでも、たくさん人がいる写真には向いていないよ",
        languageProvider.locallanguage == 2
            ? "Mode C is recommended when you want to make everything *except* the background into art!"
            : languageProvider.isHiragana
                ? "「モードC」ははいけいいがいをアートにしたいときにおすすめ！"
                : "「モードC」は背景以外をアートにしたい時にオススメ！",
        languageProvider.locallanguage == 2
            ? "Mode D is recommended when you want to make small things or snacks into art!"
            : languageProvider.isHiragana
                ? "「モードD」はおやつやちいさいものをアートにしたいときにおすすめ！"
                : "「モードD」はおやつや小さい物をアートにしたい時にオススメ！",
        languageProvider.locallanguage == 2
            ? "Let's make art using Mode A!\n*Please do this with an internet connection"
            : languageProvider.isHiragana
                ? "「アートをつくる」で「モードA」のアートをつくろう！\n※ネットがつながっているところでやってね"
                : "「アートをつくる」で「モードA」のアートを作ろう！\n※ネットがつながっているところでやってね",
        languageProvider.locallanguage == 2
            ? "While AI is creating the art, play a spot-the-difference game!"
            : languageProvider.isHiragana
                ? "AIがえをつくっているあいだに、まちがいさがしであそぼう"
                : "AIが絵を作っている間に、間違いさがしで遊ぼう",
        languageProvider.locallanguage == 2
            ? "When you hear a sound, the drawing is complete!\nYou can also see the answers to the spot-the-difference game!"
            : languageProvider.isHiragana
                ? "おとがなったらえがかんせいするよ！\nえがかんせいすると、まちがいさがしのこたえもみれるよ"
                : "音が鳴ったら絵が完成するよ！\n絵が完成すると、間違いさがしの答えも見れるよ",
        languageProvider.locallanguage == 2
            ? "When you hear a sound, the drawing is complete!\nTap 'See the completed drawing'"
            : languageProvider.isHiragana
                ? "おとがなったらえがかんせいするよ！\n「かんせいしたえをみる」をおしてね"
                : "音が鳴ったら絵が完成するよ！\n「完成した絵を見る」を押してね",
        languageProvider.locallanguage == 2
            ? "You can see both your created art and your drawings!"
            : languageProvider.isHiragana
                ? "つくったえとおえかきしたえがみられるよ"
                : "作った絵とお絵描きした絵が見られるよ",
        languageProvider.locallanguage == 2
            ? "Try saving your artwork to your device.\nOn smartphones, it'll say 'Save to phone'; on tablets, 'Save to tablet'"
            : languageProvider.isHiragana
                ? "つくったえをスマホとタブレットにほぞんしてみよう\nスマホには「スマホにほぞん」、タブレットには「タブレットにほぞん」とでるよ"
                : "作った絵を保存してみよう\nスマホには「スマホに保存」、タブレットには「タブレットに保存」とでるよ",
        languageProvider.locallanguage == 2
            ? "Try saving your drawings too!\nSame buttons as before!"
            : languageProvider.isHiragana
                ? "おえかきしたえもほぞんしてみよう\nスマホには「スマホにほぞん」、タブレットには「タブレットにほぞん」とでるよ"
                : "お絵描きした絵も保存してみよう\nスマホには「スマホに保存」、タブレットには「タブレットに保存」とでるよ",
        languageProvider.locallanguage == 2
            ? "Tap on the artworks to see them larger!"
            : languageProvider.isHiragana
                ? "つくったえとおえかきしたえをタッチしてみよう\nそうするとおおきくみれるよ"
                : "作った絵とお絵描きした絵をタッチしてみよう\nそうすると大きく見れるよ",
        languageProvider.locallanguage == 2
            ? "Try sharing on SNS!"
            : "SNSなどにシェアしてみよう",
        languageProvider.locallanguage == 2
            ? "That's the end of the tutorial!\nEnjoy drawing!!!"
            : languageProvider.isHiragana
                ? "これであそびかたはおわりだよ！\nおえかき、たのしんでね！！！"
                : "これで遊び方は終わりだよ！\nお絵描き、楽しんでね！！！"
      ];

      List<String> chapters2 = [
        languageProvider.locallanguage == 2
            ? "This is the Drawing screen!"
            : languageProvider.isHiragana
                ? "これはおえかきのがめんだよ"
                : "これはお絵描きの画面だよ",
        languageProvider.locallanguage == 2
            ? "You can choose the color you want to use from the palette.\nTap the palette icon on the right to pick a color."
            : languageProvider.isHiragana
                ? "パレットでつかいたいいろをせんたくできるよ\nみぎのパレットマークをおすといろをえらべるよ"
                : "パレットで使いたい色を選択できるよ\n右のパレットマークを押すと色を選べるよ",
        languageProvider.locallanguage == 2
            ? "Press the '+' to mix colors and create a new one."
            : languageProvider.isHiragana
                ? "「+」をおすといろをまぜることができて\nあたらしいいろができるよ"
                : "「+」を押すと色を混ぜることができて\n新しい色ができるよ",
        languageProvider.locallanguage == 2
            ? "If you make a mistake, you can undo or redo it."
            : languageProvider.isHiragana
                ? "まちがえたらもどしたりやりなおしたりできるよ"
                : "間違えたら戻したりやり直したりできるよ",
        languageProvider.locallanguage == 2
            ? "Tap the brush icon on the right to change brush settings."
            : languageProvider.isHiragana
                ? "みぎのふでマークをおすとふでのせっていができるよ"
                : "右の筆マークを押すと筆の設定ができるよ",
        languageProvider.locallanguage == 2
            ? "You can change the size of the brush and stamps."
            : languageProvider.isHiragana
                ? "ふでやスタンプのおおきさをかえることができるよ"
                : "筆やスタンプの大きさを変えることができるよ",
        languageProvider.locallanguage == 2
            ? "You can also change the type of brushes and stamps."
            : languageProvider.isHiragana
                ? "ふでやスタンプのしゅるいをかえることができるよ"
                : "筆やスタンプの種類を変えることができるよ",
        languageProvider.locallanguage == 2
            ? "Black text shows pen types,\npurple text shows stamp types."
            : languageProvider.isHiragana
                ? "くろじがペンのしゅるい, \nむらさきのじがスタンプのしゅるいだよ"
                : "黒字がペンの種類, \n紫の字がスタンプの種類だよ",
        languageProvider.locallanguage == 2
            ? "Tap the square on the right to change the background paper color."
            : languageProvider.isHiragana
                ? "みぎのしかくをおすと、かみのいろのせっていができるよ"
                : "右の四角を押すと、紙の色の設定ができるよ",
        languageProvider.locallanguage == 2
            ? "You can choose the paper color from here."
            : languageProvider.isHiragana
                ? "このなかからかみのいろをかえれるよ"
                : "この中から紙の色を変えれるよ",
        languageProvider.locallanguage == 2
            ? "Let's start drawing now!"
            : languageProvider.isHiragana
                ? "さっそくおえかきをしてみよう"
                : "さっそくお絵描きをしてみよう",
        languageProvider.locallanguage == 2
            ? "First, select red.\n*The selected color will be surrounded by a thick border."
            : languageProvider.isHiragana
                ? "まず、あかをえらんで、\n※えらんだいろはふとくかこわれるよ"
                : "まず、赤を選んで、\n※選んだ色は太く囲われるよ",
        languageProvider.locallanguage == 2
            ? "Select a pen and draw on the paper on the left."
            : languageProvider.isHiragana
                ? "ペンをせんたくして、ひだりのかみにかいてみよう"
                : "ペンを選択して、左の紙に描いてみよう",
        languageProvider.locallanguage == 2
            ? "A line appeared!\nThe brush size and color are the ones you selected from the palette."
            : languageProvider.isHiragana
                ? "せんがでてきたよ\nみぎのふでのおおきさとふでのいろはパレットでえらんだいろとおなじになるよ"
                : "線が出てきたよ\n右の筆の大きさと筆の色はパレットで選んだ色と同じになるよ",
        languageProvider.locallanguage == 2
            ? "Now try drawing with the brush.\nSo many dots!"
            : languageProvider.isHiragana
                ? "つぎ、ブラシでかいてみよう\nてんだらけだね"
                : "次、ブラシで描いてみよう\n点だらけだね",
        languageProvider.locallanguage == 2
            ? "Let's try changing the paper color to blue once."
            : languageProvider.isHiragana
                ? "いっかい、あおいかみにかえてみよう"
                : "一回、青い紙に変えてみよう",
        languageProvider.locallanguage == 2
            ? "Use a stamp,\nand after drawing, try using color blend!"
            : languageProvider.isHiragana
                ? "スタンプつかって\nひととおりかいたら、いっかいいろをまぜるカラーブレンドをつかってみよう"
                : "スタンプ使って\n一通り描いたら、一回色を混ぜるカラーブレンドを使ってみよう",
        languageProvider.locallanguage == 2
            ? "Here, you'll mix two colors."
            : languageProvider.isHiragana
                ? "ここではふたつのいろをまぜるよ"
                : "ここでは2つの色を混ぜるよ",
        languageProvider.locallanguage == 2
            ? "Tap the circle for color 1."
            : languageProvider.isHiragana
                ? "いろ1のまるをおしてみよう"
                : "色1の丸を押してみよう",
        languageProvider.locallanguage == 2
            ? "After tapping, choose your favorite color from the palette on the right."
            : languageProvider.isHiragana
                ? "おしたらみぎのパレットからすきないろをえらぶよ"
                : "押したら右のパレットから好きな色を選ぶよ",
        languageProvider.locallanguage == 2
            ? "Do the same for color 2."
            : languageProvider.isHiragana
                ? "おなじようにいろ2もやってみよう"
                : "同じように色2もやってみよう",
        languageProvider.locallanguage == 2
            ? "After selecting, the frame for color 1 disappears from the palette."
            : languageProvider.isHiragana
                ? "せんたくしたらパレットにていろ1にがいとうするわくがなくなったよ"
                : "選択したらパレットにて色1に該当する枠がなくなったよ",
        languageProvider.locallanguage == 2
            ? "Choose from the palette again in the same way."
            : languageProvider.isHiragana
                ? "おなじようにパレットでえらぼう"
                : "同じようにパレットで選ぼう",
        languageProvider.locallanguage == 2
            ? "After choosing color 2, press 'Mix colors' to blend them."
            : languageProvider.isHiragana
                ? "いろ2をえらんだら、「いろをまぜる」でまぜてみよう"
                : "色2を選んだら、「色を混ぜる」で混ぜてみよう",
        languageProvider.locallanguage == 2
            ? "The mixed color appeared at the bottom.\nThis time, it's a mix of orange and green."
            : languageProvider.isHiragana
                ? "したのほうにまぜたいろができました\nこんかいはオレンジとみどりをあわせたいろだよ"
                : "下の方に混ぜた色ができました\n今回はオレンジと緑を合わせた色だよ",
        languageProvider.locallanguage == 2
            ? "If the mixed color isn't what you expected, press 'Try again'."
            : languageProvider.isHiragana
                ? "もしまぜたいろがおもいどおりでないときは、「やりなおす」をおしてね"
                : "もし混ぜた色が思い通りでない時は、「やり直す」を押してね",
        languageProvider.locallanguage == 2
            ? "If it's okay, press 'Looks good!'."
            : languageProvider.isHiragana
                ? "もしOKだったら「これでOK」をおしてね"
                : "もしOKだったら「これでOK」を押してね",
        languageProvider.locallanguage == 2
            ? "Pressing 'Looks good!' will confirm it.\nYou can make up to 6 colors."
            : languageProvider.isHiragana
                ? "OKなのでこれでOKをおします\nちなみにさいだい6しょくつくることができるよ"
                : "OKなのでこれでOKを押します\nちなみに最大6色作ることができるよ",
        languageProvider.locallanguage == 2
            ? "Right after pressing 'Looks good!', the color won't appear.\nTry tapping a palette color or logo once."
            : languageProvider.isHiragana
                ? "「これでOK」をおしてすぐはできたいろがでてこないので、\nいっかいパレットのいろやみぎのロゴをおしたりしてみよう"
                : "「これでOK」を押してすぐはできた色が出てこないので、\n一回パレットの色や右のロゴを押したりしてみよう",
        languageProvider.locallanguage == 2
            ? "Then the mixed color will appear at the bottom of the palette!"
            : languageProvider.isHiragana
                ? "そうするとパレットのしたのほうにまぜたいろがでてきたよ"
                : "そうするとパレットの下の方に混ぜた色が出てきたよ",
        languageProvider.locallanguage == 2
            ? "Try coloring with the mixed color!"
            : languageProvider.isHiragana
                ? "いっかい、まぜたいろでいろぬりしたよ"
                : "一回、混ぜた色で色塗りしたよ",
        languageProvider.locallanguage == 2
            ? "Once your drawing is done, press 'Finished!'\nThat's all for how to play!"
            : languageProvider.isHiragana
                ? "えができたら「できたよ」をおしてね\nこれであそびかたはおわりだよ！"
                : "絵ができたら「できたよ」を押してね\nこれで遊び方は終わりだよ！",
      ];

      List<String> chapters3 = [
        languageProvider.locallanguage == 2
            ? "While making the picture, you'll play a spot-the-difference game"
            : languageProvider.isHiragana
                ? "えをつくっているあいだはまちがいさがしであそぶよ"
                : "絵を作っている間はまちがいさがしで遊ぶよ",
        languageProvider.locallanguage == 2
            ? "Until the picture is finished, you can't see the answers or the completed picture yet"
            : languageProvider.isHiragana
                ? "かんせいしてないあいだはまちがいさがしのこたえと\nかんせいしたえはまだみれないよ"
                : "完成してない間はまちがいさがしの答えと\n完成した絵はまだ見れないよ",
        languageProvider.locallanguage == 2
            ? "If you find a mistake in the picture on the right, touch that spot"
            : languageProvider.isHiragana
                ? "みぎのえでまちがいなどみつけたら、そのばしょをタッチしてね"
                : "右の絵でまちがいなど見つけたら、その場所をタッチしてね",
        languageProvider.locallanguage == 2
            ? "You touched one! A red circle appears where you touched"
            : languageProvider.isHiragana
                ? "ひとつタッチしたよ\nタッチしたらそのばしょにあかいまるがでてくるよ"
                : "1つタッチしたよ\nタッチしたらその場所に赤い丸が出てくるよ",
        languageProvider.locallanguage == 2
            ? "If you touched the wrong place, you can undo or retry"
            : languageProvider.isHiragana
                ? "タッチしたばしょをまちがえたらもどしたりやりなおしたりできるよ"
                : "タッチした場所を間違えたら戻したりやり直したりできるよ",
        languageProvider.locallanguage == 2
            ? "Then, one red circle disappeared"
            : languageProvider.isHiragana
                ? "そうするとあかいまるがひとつきえたよ"
                : "そうすると赤い丸が1つ消えたよ",
        languageProvider.locallanguage == 2
            ? "When the sound plays and the 'The drawing is complete!' window appears, your picture is done"
            : languageProvider.isHiragana
                ? "おとがなり、「えができたよ」のウインドウがでたら\nえがかんせいしたよ"
                : "音が鳴り、「絵ができたよ」のウインドウが出たら\n絵が完成したよ",
        languageProvider.locallanguage == 2
            ? "Let's check the answers to the spot-the-difference"
            : languageProvider.isHiragana
                ? "まちがいさがしのこたえをみてみよう"
                : "まちがいさがしの答えを見てみよう",
        languageProvider.locallanguage == 2
            ? "When you press 'View completed picture', the game ends and you can see your final drawing.\nThat's the end of how to play!"
            : languageProvider.isHiragana
                ? "かんせいしたえをみるをおしたらまちがいさがしはおわり、\nできたえをみることができるよ\nこれであそびかたはおわりだよ！"
                : "完成した絵を見るを押したらまちがいさがしは終わり、\nできた絵を見ることができるよ\nこれで遊び方は終わりだよ！",
      ];

      List<String> chapters4 = [
        languageProvider.locallanguage == 2
            ? "This is the screen after the picture is completed"
            : languageProvider.isHiragana
                ? "かんせいしたあとのがめんだよ"
                : "完成した後の画面だよ",
        languageProvider.locallanguage == 2
            ? "If you want to save and keep your artwork, press 'Save to Gallery'"
            : languageProvider.isHiragana
                ? "もしアートなどをほぞんしてきろくしたいばあいは\n「ギャラリーにほぞんする」をおしてね"
                : "もしアートなどを保存して記録したい場合は\n「ギャラリーに保存する」を押してね",
        languageProvider.locallanguage == 2
            ? "Then a window for saving will appear"
            : languageProvider.isHiragana
                ? "そうするとほぞんようのウインドウがでてくるよ"
                : "そうすると保存用のウィンドウが出てくるよ",
        languageProvider.locallanguage == 2
            ? "First, check the picture. If it's okay, press 'Next'"
            : languageProvider.isHiragana
                ? "さいしょはえのかくにんでOKだったら「すすむ」をおしてね"
                : "最初は絵の確認でOKだったら「進む」を押してね",
        languageProvider.locallanguage == 2
            ? "Next, let's give your picture a title"
            : languageProvider.isHiragana
                ? "つぎタイトルをかいてみよう"
                : "次タイトルを書いてみよう",
        languageProvider.locallanguage == 2
            ? "Because it's a mix of sunset and sherbet,\nI'll call it 'Sunset Sherbet'"
            : languageProvider.isHiragana
                ? "ゆうやけとシャーベットのくみあわせなので\n「ゆうやけシャーベット」にするよ"
                : "夕焼けとシャーベットの組み合わせなので\n「夕焼けシャーベット」にするよ",
        languageProvider.locallanguage == 2
            ? "Once you've typed the title, press 'Next'"
            : languageProvider.isHiragana
                ? "にゅうりょくしたら「すすむ」をおしてね"
                : "入力したら「進む」を押してね",
        languageProvider.locallanguage == 2
            ? "Now, choose how you felt when drawing the picture"
            : languageProvider.isHiragana
                ? "つぎ、えをかいたときのきもちをえらんでね"
                : "次、絵を描いた時の気持ちを選んでね",
        languageProvider.locallanguage == 2
            ? "This time, I drew it when I was moved, so press 'Moved'"
            : languageProvider.isHiragana
                ? "こんかいはかんどうしたときにかいたから「かんどうする」をおしてね"
                : "今回は感動した時に描いたから「かんどうする」を押してね",
        languageProvider.locallanguage == 2
            ? "Then you’ll go to the next screen"
            : languageProvider.isHiragana
                ? "そうすると、つぎのがめんにいったよ"
                : "そうすると、次の画面に行ったよ",
        languageProvider.locallanguage == 2
            ? "Let's go back once and check the emotion you selected"
            : languageProvider.isHiragana
                ? "いっかい、「もどる」でえらんだかんじょうをかくにんしてみよう"
                : "一回、「戻る」で選んだ感情を確認してみよう",
        languageProvider.locallanguage == 2
            ? "The emotion you selected earlier turned pink.\nIf it doesn't match how you felt, you can change it"
            : languageProvider.isHiragana
                ? "さっきえらんだかんじょうは、ピンクいろにかわっているよ\nもしえをかいたときのきもちがちがうなどあったらかえれるよ"
                : "さっき選んだ感情は、ピンク色に変わっているよ\nもし描いた時の気持ちが違うなどあったら変えれるよ",
        languageProvider.locallanguage == 2
            ? "If you want to keep it as 'Moved', press 'Next'"
            : languageProvider.isHiragana
                ? "もし「かんどうする」のままにしたかったら「すすむ」をおしてね"
                : "もし「かんどうする」のままにしたかったら「進む」を押してね",
        languageProvider.locallanguage == 2
            ? "Finally, write more about how you felt when drawing"
            : languageProvider.isHiragana
                ? "さいご、かいたときにさらにかんじたきもちをかいてね"
                : "最後、描いた時にさらに感じた気持ちを書いてね",
        languageProvider.locallanguage == 2
            ? "You can write your feelings here"
            : languageProvider.isHiragana
                ? "ここでかんじょうをかくことができるよ"
                : "ここで感情を書くことができるよ",
        languageProvider.locallanguage == 2
            ? "I was moved by the taste of the sherbet, so I wrote\n'It was really delicious!'"
            : languageProvider.isHiragana
                ? "シャーベットのあじにかんどうしたので\n「とてもおいしかったです」とかいたよ"
                : "シャーベットの味に感動したので\n「とても美味しかったです」と書いたよ",
        languageProvider.locallanguage == 2
            ? "If you're done, press 'Next'"
            : languageProvider.isHiragana
                ? "できたら「すすむ」をおすよ"
                : "できたら「進む」を押すよ",
        languageProvider.locallanguage == 2
            ? "Then, it will be saved"
            : languageProvider.isHiragana
                ? "そうするとほぞんできたよ"
                : "そうすると保存できたよ",
        languageProvider.locallanguage == 2
            ? "Finally, you can view the saved artwork in the gallery.\nCheck the 'How to use Gallery' for details.\nThat's the end of how to use it!"
            : languageProvider.isHiragana
                ? "さいご、ギャラリーにてほぞんしたアートがみれるよ\nくわしくはギャラリーのあそびかたをみてね\nこれであそびかたはおわりだよ！"
                : "最後、ギャラリーにて保存したアートが見れるよ\n詳しくはギャラリーの遊び方を見てね\nこれで遊び方は終わりだよ！",
      ];

      List<String> chapters5 = [
        languageProvider.locallanguage == 2
            ? "Now you can use drawings made with colored pencils, crayons, etc. in Magic Craypas!"
            : languageProvider.isHiragana
                ? "いろえんぴつやクレヨンなどでかいたえもまじっくくれぱすで\nつかえるようになったよ"
                : "色鉛筆やクレヨンなどで描いた絵もまじっくくれぱすで\n使えるようになったよ",
        languageProvider.locallanguage == 2
            ? "Press 'Choose from Photo'"
            : languageProvider.isHiragana
                ? "「しゃしんからえらぶ」をおしてね"
                : "「写真から選ぶ」を押してね",
        languageProvider.locallanguage == 2
            ? "Then you’ll return to the preparation screen and be able to use the drawing from the photo"
            : languageProvider.isHiragana
                ? "そうすると、せいせいじゅんびがめんにもどってしゃしんにあるえをつかうことができるよ"
                : "そうすると、生成準備画面に戻って写真にある絵を使うことができるよ",
        languageProvider.locallanguage == 2
            ? "I selected a sunset drawing made with crayons"
            : languageProvider.isHiragana
                ? "クレヨンでかいたゆうやけのえをえらんだよ"
                : "クレヨンで描いた夕焼けの絵を選んだよ",
        languageProvider.locallanguage == 2
            ? "Now that you’ve chosen a drawing and a photo, you're ready to create art!\nLet’s try making one!"
            : languageProvider.isHiragana
                ? "えとしゃしんをえらんだのでアートをつくるじゅんびかんりょうだよ\nいっかいつくってみよう"
                : "絵と写真を選んだのでアートを作る準備完了だよ\n一回作ってみよう",
        languageProvider.locallanguage == 2
            ? "This is the artwork made with Mode C\nTry tapping the artwork you created"
            : languageProvider.isHiragana
                ? "モードCでかいたえだよ\nつくったえをタップしてみよう"
                : "モードCで描いた絵だよ\n作った絵をタップしてみよう",
        languageProvider.locallanguage == 2
            ? "It looks like crayon-style art!\nTap outside the picture to close it"
            : languageProvider.isHiragana
                ? "クレヨンのようにアートができているね\nえのそとがわをおすとがぞうとじるよ"
                : "クレヨンのようにアートができているね\n絵の外側を押すと画像閉じるよ",
        languageProvider.locallanguage == 2
            ? "Try using colored pencils, crayons, or paints too!\nThat’s the end of the guide!"
            : languageProvider.isHiragana
                ? "いろえんぴつやクレヨン、えのぐなどでもためしてみてね\nこれであそびかたはおわりだよ！"
                : "色鉛筆やクレヨン、絵の具などでも試してみてね\nこれで遊び方は終わりだよ！",
      ];

      List<String> chapters6 = [
        languageProvider.locallanguage == 2
            ? "You can access the gallery with saved art from the home screen."
            : languageProvider.isHiragana
                ? "ほぞんしたアートがあるギャラリーはホームがめんからいけるよ"
                : "保存したアートがあるギャラリーはホーム画面から行けるよ",
        languageProvider.locallanguage == 2
            ? "Press 'View Gallery'"
            : languageProvider.isHiragana
                ? "「ギャラリーをみる」をおしてね"
                : "「ギャラリーを見る」を押してね",
        languageProvider.locallanguage == 2
            ? "The gallery contains all the art you’ve saved so far."
            : languageProvider.isHiragana
                ? "ギャラリーにはいままでほぞんしたアートがあるよ"
                : "ギャラリーには今まで保存したアートがあるよ",
        languageProvider.locallanguage == 2
            ? "Select one saved drawing.\nLet’s try selecting the 'Sunset Sherbet' on the left."
            : languageProvider.isHiragana
                ? "きろくしたえをひとつえらぶよ\nためしにひだりの「ゆうやけシャーベット」をえらんでみるね"
                : "記録した絵を１つ選ぶよ\n試しに左の「夕焼けシャーベット」を選んでみるね",
        languageProvider.locallanguage == 2
            ? "Then you’ll see the feelings and title chosen when saving."
            : languageProvider.isHiragana
                ? "そうすると、ほぞんのときにえらんだかんじょうやタイトルがでてくるよ"
                : "そうすると、保存の時に選んだ感情やタイトルが出てくるよ",
        languageProvider.locallanguage == 2
            ? "Also, tap the artwork to enlarge it."
            : languageProvider.isHiragana
                ? "また、つくったえなどをタップすると、かくだいしてみれるよ"
                : "また、作った絵などをタップすると、拡大して見れるよ",
        languageProvider.locallanguage == 2
            ? "The picture will get bigger.\nTap outside the image to close it."
            : languageProvider.isHiragana
                ? "そうすると、おおきくなったよ\nえのそとがわをおすとがぞうとじるよ"
                : "そうすると、大きくなったよ\n絵の外側を押すと画像閉じるよ",
        languageProvider.locallanguage == 2
            ? "You can save pictures just like the ones created by AI."
            : languageProvider.isHiragana
                ? "AIによってできたあとのおなじようにえなどをほぞんできるよ"
                : "AIによってできた後と同じように絵などを保存できるよ",
        languageProvider.locallanguage == 2
            ? "Try pressing 'View Details'"
            : languageProvider.isHiragana
                ? "「くわしくみる」をおしてみてね"
                : "「詳しく見る」を押してみてね",
        languageProvider.locallanguage == 2
            ? "You’ll see detailed feelings and the photo used when making the drawing."
            : languageProvider.isHiragana
                ? "そうするとしょうさいなきもちとえをつくったときにつかったしゃしんがみれるよ"
                : "そうすると詳細な気持ちと絵を作った時に使った写真が見れるよ",
        languageProvider.locallanguage == 2
            ? "You can also delete saved drawings."
            : languageProvider.isHiragana
                ? "ほぞんしたえをさくじょすることもできるよ"
                : "保存した絵を削除することもできるよ",
        languageProvider.locallanguage == 2
            ? "A confirmation will appear.\nIf you press 'Delete,' the saved drawing and title will be removed."
            : languageProvider.isHiragana
                ? "そうすると、さくじょのかくにんがくるよ\n「さくじょする」をおしたらそのほぞんしたえやタイトルがきえるよ"
                : "そうすると、削除の確認がくるよ\n「削除する」を押したらその保存した絵やタイトルが消えるよ",
        languageProvider.locallanguage == 2
            ? "That’s the end of the guide!"
            : languageProvider.isHiragana
                ? "これであそびかたはおわりだよ！"
                : "これで遊び方は終わりだよ！",
      ];

      List<String> chapters7 = [
        languageProvider.locallanguage == 2
            ? "After finishing your drawing, you can enjoy it in another mode."
            : languageProvider.isHiragana
                ? "えがかんせいしたあと、べつのモードでたのしむことができるよ"
                : "絵が完成した後、別のモードで楽しむことができるよ",
        languageProvider.locallanguage == 2
            ? "Press 'Use Another Mode'"
            : languageProvider.isHiragana
                ? "「べつのモードをつかう」をおしてみて"
                : "「別のモードを使う」を押してみて",
        languageProvider.locallanguage == 2
            ? "Then you can see comparison images and select other modes."
            : languageProvider.isHiragana
                ? "そうするとほかのモードのひかくがぞうとモードせんたくができるよ"
                : "そうすると他のモードの比較画像とモード選択ができるよ",
        languageProvider.locallanguage == 2
            ? "Choose the mode you want to try.\nHere, we will use Mode B."
            : languageProvider.isHiragana
                ? "ためしたいモードをえらぶよ\nここではモードBでやるよ"
                : "試したいモードを選ぶよ\nここではモードBでやるよ",
        languageProvider.locallanguage == 2
            ? "While creating similarly, you will play spot-the-difference."
            : languageProvider.isHiragana
                ? "おなじようにつくっているあいだはまちがいさがしをするよ"
                : "同じように作っている間はまちがいさがしをするよ",
        languageProvider.locallanguage == 2
            ? "The drawing you tried in the different mode appeared.\nThis is the end of the guide."
            : languageProvider.isHiragana
                ? "べつモードでためしたえがでてきたよ\nこれであそびかたはおわりだよ"
                : "別モードで試した絵が出てきたよ\nこれで遊び方は終わりだよ",
      ];

      List<String> chapters8 = [
        languageProvider.locallanguage == 2
            ? "I’ll teach you how to set sounds and language."
            : languageProvider.isHiragana
                ? "おととよみがなのせっていのやりかたをおしえるね"
                : "音と読み仮名の設定のやり方を教えるね",
        languageProvider.locallanguage == 2
            ? "Press the 'Settings' button."
            : languageProvider.isHiragana
                ? "「せってい」ボタンをおしてね"
                : "「設定」ボタンを押してね",
        languageProvider.locallanguage == 2
            ? "Then the settings window will appear.\nSound off means volume 0, sound on means with sound.\nYou can also switch between Japanese and English modes."
            : languageProvider.isHiragana
                ? "そうするとせっていウインドウがでてきたよ\nおとなしはおんりょう0、おとありはおとつきであそべるよ\nにほんごえいごモードにへんこうできるよ"
                : "そうすると設定ウインドウが出てきたよ\n音なしは音量0、音ありは音付きで遊べるよ\n日本語英語モードに変更できるよ",
        languageProvider.locallanguage == 2
            ? "Next,  select 'Japanese' to change Japanese."
            : languageProvider.isHiragana
                ? "つぎ、したにスクロールすると「ひらがなカタカナ」をえらんでよみがなへんこうできるよ"
                : "次、したにスクロールすると「ひらがなカタカナ」を選んで読み仮名変更できるよ",
        languageProvider.locallanguage == 2
            ? "Pressing 'Japanese' changes the text behind to Japanese."
            : languageProvider.isHiragana
                ? "「ひらがなカタカナ」をおすと、うしろはひらがなになったよ"
                : "「ひらがなカタカナ」を押すと、後ろはひらがなになったよ",
        languageProvider.locallanguage == 2
            ? "This is the home screen where everything is written in Japanese."
            : languageProvider.isHiragana
                ? "すべてひらがなになったホームがめんだよ"
                : "全てひらがなになったホーム画面だよ",
        languageProvider.locallanguage == 2
            ? "You can press 'Settings' again to switch back to English."
            : languageProvider.isHiragana
                ? "また「せってい」をおすとかんじに戻せるよ"
                : "また「せってい」を押すと漢字に戻せるよ",
        languageProvider.locallanguage == 2
            ? "When you switch back to 'English,' the text behind is also written in English."
            : languageProvider.isHiragana
                ? "「かんじ」にもどすとうしろはかんじでもかかれるよ"
                : "「漢字」に戻すと後ろは漢字でも書かれるよ",
        languageProvider.locallanguage == 2
            ? "This is the end of the guide."
            : languageProvider.isHiragana
                ? "これであそびかたはおわりだよ"
                : "これで遊び方は終わりだよ",
      ];

      //tutorialItems: それぞれあそび方を格納する。
      //主に準備する説明とチュートリアルの番号(説明用の画像を格納するディレクトリを準備してる)、チュートリアル名を準備
      List<Map<String, dynamic>> tutorialItems = [
        {
          'title': page == 1
              ? (languageProvider.locallanguage == 2
                  ? "Overview of playing"
                  : languageProvider.isHiragana
                      ? 'ひととおりのやりかた'
                      : '一通りのやりかた')
              : (languageProvider.locallanguage == 2
                  ? "Drawing 2"
                  : languageProvider.isHiragana
                      ? "おえかき2"
                      : "お絵描き2"),
          'chapters': page == 1 ? chapters1 : chapters5,
          'tutorialNumber': page == 1 ? 1 : 5,
        },
        {
          'title': page == 1
              ? (languageProvider.locallanguage == 2
                  ? "Drawing"
                  : languageProvider.isHiragana
                      ? 'おえかき'
                      : 'お絵描き')
              : languageProvider.locallanguage == 2
                  ? "Gallery"
                  : 'ギャラリー',
          'chapters': page == 1 ? chapters2 : chapters6,
          'tutorialNumber': page == 1 ? 2 : 6,
        },
        {
          'title': page == 1
              ? languageProvider.locallanguage == 2
                  ? "The differences"
                  : 'まちがいさがし'
              : (languageProvider.locallanguage == 2
                  ? "Another modes"
                  : languageProvider.isHiragana
                      ? 'べつのモード'
                      : '別のモード'),
          'chapters': page == 1 ? chapters3 : chapters7,
          'tutorialNumber': page == 1 ? 3 : 7,
        },
        {
          'title': page == 1
              ? (languageProvider.locallanguage == 2
                  ? "Save gallery"
                  : languageProvider.isHiragana
                      ? 'ギャラリーほぞん'
                      : 'ギャラリー保存')
              : (languageProvider.locallanguage == 2
                  ? "Setting"
                  : languageProvider.isHiragana
                      ? 'せってい'
                      : "設定"),
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
                          (languageProvider.locallanguage == 2
                                  ? 'assets/tutorial_en/'
                                  : 'assets/tutorial/') +
                              '${itemIndex + 1 + (page - 1) * 4}.png',
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
                  languageProvider.locallanguage == 2
                      ? "Tutorial"
                      : languageProvider.isHiragana
                          ? 'あそびかた'
                          : 'あそび方',
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
                        setState(() => page -= 1); //ページ移動できる場合は押すことが可能
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
                        setState(() => page += 1); //ページ移動できる場合は押すことが可能
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
                      languageProvider.locallanguage == 2
                          ? "Back to Home"
                          : languageProvider.isHiragana
                              ? 'ホームにもどる'
                              : 'ホームに戻る',
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
