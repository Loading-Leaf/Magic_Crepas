package com.magicre2024.ai_art  // あなたのプロジェクトのパッケージ名に合わせてください

import android.content.pm.ActivityInfo // 必要に応じて
import android.os.Bundle // 必要に応じて
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 画面の向きを設定する場合
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
    }
}
