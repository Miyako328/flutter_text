package com.example.flutter_text

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import com.hjq.permissions.XXPermissions
import org.json.JSONObject

class MainActivity: FlutterActivity() {

    companion object {
        var flutterMethodChannel: MethodChannel? = null
    }

    private val channelTag = "mChannel"
    private val logTag = "MainActivity"

    @RequiresApi(Build.VERSION_CODES.N)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        flutterMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelTag
        )
        initFlutterChannel(flutterMethodChannel!!)
    }

    @RequiresApi(Build.VERSION_CODES.N)
    private fun initFlutterChannel(flutterMethodChannel: MethodChannel) {
        flutterMethodChannel.setMethodCallHandler { call, result ->
            // make sure result will be invoked, otherwise flutter will await forever
            when (call.method) {
                "touch_input" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && call.arguments != null) {
                        var map = call.arguments as Map<*, *>;
                        val displayMetrics = resources.displayMetrics
                        var dx = map["x"] as Double * displayMetrics.widthPixels;
                        var dy = map["y"] as Double * displayMetrics.heightPixels;
                        var kind = map["kind"] as String;

                        if (kind == "onTapDown") {
                            InputService.ctx?.onTouchInput(4, dx.toInt(), dy.toInt())
                        } else if (kind == "onTapUp") {
                            InputService.ctx?.onTouchInput(6, dx.toInt(), dy.toInt())
                        } else {
                            InputService.ctx?.onTouchInput(5, dx.toInt(), dy.toInt())
                        }
                    }
                    result.success(true)
                }
                "physic_input" -> {
                    var map = call.arguments as Map<*, *>
                    var kind = map["kind"] as String

                    if (kind == "back") {

                    } else if (kind == "home") {
                        var intent = Intent(Intent.ACTION_MAIN)
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        intent.addCategory(Intent.CATEGORY_HOME)
                        this.startActivity(intent)
                    } else if (kind == "list") {
                        InputService.ctx?.physicGesture(AccessibilityService.GLOBAL_ACTION_RECENTS)
                    }
                }
                "input_shell" -> {
                    var map = call.arguments as Map<*, *>;
                    val displayMetrics = resources.displayMetrics
                    var dx = map["x"] as Double * displayMetrics.widthPixels;
                    var dy = map["y"] as Double * displayMetrics.heightPixels;
                    var kind = map["kind"] as String;

                    if (kind == "onTapDown") {
                        InputShell().screenClickStart(dx.toInt(), dy.toInt())
                    } else if (kind == "onTapUp") {
                        InputShell().screenClickEnd(dx.toInt(), dy.toInt())
                    }
                }
                "check_permission" -> {
                    if (call.arguments is String) {
                        result.success(XXPermissions.isGranted(context, call.arguments as String))
                    } else {
                        result.success(false)
                    }
                }
                "request_permission" -> {
                    if (call.arguments is String) {
                        var intent = Intent(call.arguments as String);
                        context.startActivity(intent);
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                else -> {
                    result.error("-1", "No such method", null)
                }
            }
        }
    }

}
