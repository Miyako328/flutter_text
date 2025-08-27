package com.example.flutter_text

import java.lang.RuntimeException

private var startX: Int = 0
private var startY: Int = 0
private var startMillTime = 0L

class InputShell {
    private val logTag = "ScreenClickMotion"

    fun screenClickStart(x: Int, y: Int) {
        try {
            startX = x
            startY = y
            startMillTime = System.currentTimeMillis()
        } catch (err: Exception) {
            throw RuntimeException(err)
        }
    }

    fun screenClickEnd(x:Int, y: Int) {
        try {
            var duration = System.currentTimeMillis() - startMillTime
            if (duration <= 0) {
                duration = 100
            }

            Runtime.getRuntime().exec("input swipe $startX $startY $x $y $duration")
        } catch (err: Exception) {
            throw RuntimeException(err)
        }
    }

    // 模拟按键操作，4 返回键 3 home键 187 最近任务
    fun keyEventClick(key:Int) {
        try {
            Runtime.getRuntime().exec("input keyevent $key")
        } catch (err:Exception) {
            throw RuntimeException(err)
        }
    }
}