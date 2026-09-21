package com.example.draaxi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.draaxi/google_api_keys"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "getKeys" -> {
                            val mapsApiKey = getString(R.string.google_maps_key)
                            val placesApiKey = getString(R.string.google_places_key)
                            result.success(
                                    mapOf(
                                            "mapsApiKey" to mapsApiKey,
                                            "placesApiKey" to placesApiKey,
                                    ),
                            )
                        }
                        else -> result.notImplemented()
                    }
                }
    }
}
