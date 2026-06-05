package com.example.wellbeing_app.usage

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context

class UsageStatsRepository(
    private val context: Context
) {
    private val ignoredPackages = setOf(
        "com.android.systemui",
        "com.google.android.inputmethod.latin",
        "com.miui.home",
        "com.samsung.android.honeyboard",
        "com.example.wellbeing_app"
    )

    fun calculateUsage(
        startTime: Long,
        endTime: Long
    ) : Map<String, Long> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usageStatsManager.queryEvents(startTime, endTime)
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