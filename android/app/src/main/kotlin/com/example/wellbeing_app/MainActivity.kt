package com.example.wellbeing_app

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.wellbeing_app/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getPreciseUsage") {
                val start = call.argument<Long>("start") ?: 0L
                val end = call.argument<Long>("end") ?: 0L
                val stats = calculateUsage(start, end)
                result.success(stats)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun calculateUsage(startTime: Long, endTime: Long): Map<String, Long> {

        val usm =
            getSystemService(Context.USAGE_STATS_SERVICE)
                    as UsageStatsManager

        val events = usm.queryEvents(startTime, endTime)

        val statsMap = mutableMapOf<String, Long>()

        var currentPackage: String? = null
        var currentStartTime = 0L

        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {

            events.getNextEvent(event)

            val pkg = event.packageName ?: continue

            when (event.eventType) {

                UsageEvents.Event.ACTIVITY_RESUMED,
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {

                    // close previous app session
                    if (currentPackage != null) {

                        val duration =
                            event.timeStamp - currentStartTime

                        if (duration > 0) {
                            statsMap[currentPackage!!] =
                                (statsMap[currentPackage!!] ?: 0L) + duration
                        }
                    }

                    // start new session
                    currentPackage = pkg
                    currentStartTime = event.timeStamp
                }
            }
        }

        // close final open app
        if (currentPackage != null) {

            val duration = endTime - currentStartTime

            if (duration > 0) {
                statsMap[currentPackage!!] =
                    (statsMap[currentPackage!!] ?: 0L) + duration
            }
        }

        return statsMap
    }
}
