package com.example.wellbeing_app

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.wellbeing_app/usage"

    // Ignore noisy/system apps
    private val ignoredPackages = setOf(
        "com.android.systemui",
        "com.google.android.inputmethod.latin",
        "com.miui.home",
        "com.samsung.android.honeyboard"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPreciseUsage" -> {
                    val start = call.argument<Long>("start") ?: 0L
                    val end = call.argument<Long>("end") ?: 0L
                    val stats = calculateUsage(start, end)
                    result.success(stats)
                }
                "isUsageAccessGranted" -> {
                    val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
                    val mode = appOps.checkOpNoThrow(
                        AppOpsManager.OPSTR_GET_USAGE_STATS,
                        Process.myUid(),
                        packageName
                    )
                    result.success(
                        mode == AppOpsManager.MODE_ALLOWED
                    )
                }
                "openUsageAccessSettings" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun calculateUsage(
        startTime: Long,
        endTime: Long
    ): Map<String, Long> {

        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE)
                    as UsageStatsManager

        val events =
            usageStatsManager.queryEvents(startTime, endTime)

        val statsMap = mutableMapOf<String, Long>()

        var currentApp: String? = null
        var currentStartTime = 0L

        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {

            events.getNextEvent(event)

            val pkg = event.packageName ?: continue

            // Ignore system/noisy apps
            if (ignoredPackages.contains(pkg)) {
                continue
            }

            when (event.eventType) {

                UsageEvents.Event.MOVE_TO_FOREGROUND -> {

                    // Ignore duplicate foreground events
                    if (pkg == currentApp) {
                        continue
                    }

                    // Close previous app session
                    if (currentApp != null) {

                        val duration =
                            event.timeStamp - currentStartTime

                        if (duration > 0) {

                            statsMap[currentApp!!] =
                                (statsMap[currentApp!!] ?: 0L) + duration
                        }
                    }

                    // Start new app session
                    currentApp = pkg
                    currentStartTime = event.timeStamp
                }

                UsageEvents.Event.MOVE_TO_BACKGROUND -> {

                    // Close only matching app
                    if (pkg == currentApp) {

                        val duration =
                            event.timeStamp - currentStartTime

                        if (duration > 0) {

                            statsMap[pkg] =
                                (statsMap[pkg] ?: 0L) + duration
                        }

                        currentApp = null
                    }
                }
            }
        }

        // Close dangling session
        if (currentApp != null) {

            val duration =
                endTime - currentStartTime

            if (duration > 0) {

                statsMap[currentApp!!] =
                    (statsMap[currentApp!!] ?: 0L) + duration
            }
        }

        return statsMap
    }
}