import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioProvider with ChangeNotifier {
  double _volume = 1.0; // 音量（1.0 は最大、0.0 はミュート）
  final AudioPlayer _audioPlayer = AudioPlayer(); // AudioPlayerのインスタンス

  double get volume => _volume;

  AudioPlayer get audioPlayer => _audioPlayer; // AudioPlayerのインスタンスを提供

  // 音量を変更するメソッド
  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(volume); // AudioPlayerの音量を更新
    notifyListeners(); // 音量が変更されたことを通知
  }

  // 音を停止するメソッド
  void stopAudio() {
    _audioPlayer.stop(); // 音を停止
  }

  // 音を停止するメソッド
  void pauseAudio() {
    _audioPlayer.pause(); // 音を停止
  }

  // 音を再生するメソッド
  void playSound(String soundFile) {
    _audioPlayer.play(AssetSource(soundFile)); // 指定された音声ファイルを再生
  }
}
