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
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(startTime, endTime)
        val statsMap = mutableMapOf<String, Long>()
        val startTimes = mutableMapOf<String, Long>()

        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName

            // Logic: Catch the exact moments the app was used
            when (event.eventType) {

                UsageEvents.Event.ACTIVITY_RESUMED,
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {

                    if (!startTimes.containsKey(pkg)) {
                        startTimes[pkg] = event.timeStamp
                    }
                }

                UsageEvents.Event.ACTIVITY_PAUSED,
                UsageEvents.Event.MOVE_TO_BACKGROUND -> {

                    val start = startTimes[pkg]

                    if (start != null) {

                        val duration = event.timeStamp - start

                        if (duration > 0) {
                            statsMap[pkg] =
                                (statsMap[pkg] ?: 0L) + duration
                        }

                        startTimes.remove(pkg)
                    }
                }
            }
        }

        for ((pkg, start) in startTimes) {

            val duration = endTime - start

            if (duration > 0) {
                statsMap[pkg] =
                    (statsMap[pkg] ?: 0L) + duration
            }

            if (pkg.isNullOrEmpty()) continue

            if (
                pkg == "com.android.systemui" ||
                pkg.contains("launcher")
            ) continue
        }


        return statsMap
    }
}
