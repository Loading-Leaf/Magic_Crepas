import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3661514139640335/2039147077';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3661514139640335/5976847494';
    } else {
      // ignore: unnecessary_new
      throw new UnsupportedError('Unsupported platform');
    }
  }
}
