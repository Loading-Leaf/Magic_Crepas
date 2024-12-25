package com.magicre2024.ai_art

import android.content.pm.ActivityInfo
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    fun onCreate(savedInstanceState: Bundle?) { // override を削除！
        super.onCreate(savedInstanceState)
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
    }
}