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

        // Query events from 1 day before to catch sessions started before startTime
        val queryStartTime = maxOf(0L, startTime - (24L * 60 * 60 * 1000))
        val events = usm.queryEvents(queryStartTime, endTime)

        val statsMap = mutableMapOf<String, Long>()

        // Track when each package comes to the foreground
        val startTimes = mutableMapOf<String, Long>()

        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {

            events.getNextEvent(event)

            val pkg = event.packageName ?: continue

            val eventType = event.eventType

            if (eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {

                // Record start time if not already recorded
                if (!startTimes.containsKey(pkg)) {
                    startTimes[pkg] = event.timeStamp
                }

            } else if (eventType == UsageEvents.Event.ACTIVITY_PAUSED ||
                eventType == UsageEvents.Event.ACTIVITY_STOPPED ||
                eventType == UsageEvents.Event.MOVE_TO_BACKGROUND) {

                // Close the session and calculate duration
                if (startTimes.containsKey(pkg)) {
                    val appStartTime = startTimes.remove(pkg)!!
                    val appEndTime = event.timeStamp

                    val overlapStart = maxOf(appStartTime, startTime)
                    val overlapEnd = minOf(appEndTime, endTime)

                    if (overlapStart < overlapEnd) {
                        val duration = overlapEnd - overlapStart
                        statsMap[pkg] = (statsMap[pkg] ?: 0L) + duration
                    }
                }
            }
        }

        // Close any sessions that are still active at endTime
        for ((pkg, appStartTime) in startTimes) {
            val overlapStart = maxOf(appStartTime, startTime)
            val overlapEnd = endTime
            if (overlapStart < overlapEnd) {
                val duration = overlapEnd - overlapStart
                statsMap[pkg] = (statsMap[pkg] ?: 0L) + duration
            }
        }

        return statsMap
    }
}

