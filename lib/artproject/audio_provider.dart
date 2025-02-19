import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioProvider with ChangeNotifier {
  double _volume = 1.0; // 音量（1.0 は最大、0.0 はミュート）
  bool _isMuted = false; // ミュート状態
  final AudioPlayer _audioPlayer = AudioPlayer(); // AudioPlayerのインスタンス
  AudioSession? _audioSession;

  double get volume => _volume;
  bool get isMuted => _isMuted;
  AudioPlayer get audioPlayer => _audioPlayer; // AudioPlayerのインスタンスを提供

  AudioProvider() {
    _loadVolume(); // 初期化時に音量を読み込む
    _initAudioSession(); // オーディオセッションの初期化
  }

  Future<void> _initAudioSession() async {
    _audioSession = await AudioSession.instance;
    await _audioSession?.configure(AudioSessionConfiguration.music());
  }

  // 音量を変更するメソッド
  void setVolume(double volume) async {
    _volume = volume; //音量のボリュームを設定
    _isMuted = (volume == 0.0);
    _audioPlayer.setVolume(volume); // AudioPlayerの音量を更新
    notifyListeners(); // 音量が変更されたことを通知
    _saveVolume(volume); // 音量を保存
  }

  // 音量を保存するメソッド
  Future<void> _saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volume); // 音量を保存
  }

  // 音量を読み込むメソッド
  Future<void> _loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('volume') ?? 1.0; // 保存されている音量を読み込み、デフォルトは1.0
    _isMuted = (_volume == 0.0); // 保存された音量が 0.0 の場合ミュート
    _audioPlayer.setVolume(_volume); // 読み込んだ音量をAudioPlayerに反映
    notifyListeners(); // 音量が設定されたことを通知
  }

  // 音を停止するメソッド
  void stopAudio() {
    _audioPlayer.stop(); // 音を停止
  }

  // 音を一時停止するメソッド
  void pauseAudio() {
    _audioPlayer.pause(); // 音を一時停止
  }

  // 音を再生するメソッド
  void playSound(String soundFile) {
    _audioPlayer.play(AssetSource(soundFile)); // 指定された音声ファイルを再生
  }
}
