package com.example.wellbeing_app.workers

import android.content.Context
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import java.util.Calendar
import java.util.concurrent.TimeUnit

object WorkScheduler {
    fun scheduleNextSync(context: Context) {
        val delay = getDelayUntilNextSync()

        /*
            PeriodicWorkRequest
            ---------------------
                automatic repeat
                minimum interval = 15 min
                less timing control

            OneTimeWorkRequest
            ---------------------
                runs once
                you manually reschedule
                better timing control
                better for midnight analytics
        */

        val workRequest = OneTimeWorkRequestBuilder<UsageSyncWorker>()
            .setInitialDelay(
                delay,
                TimeUnit.MILLISECONDS
            )
            .build()

        WorkManager
            .getInstance(context)
            // If old worker exists, replace it with new one.
            .enqueueUniqueWork(
                "daily_usage_sync",
                ExistingWorkPolicy.REPLACE,
                workRequest
            )
    }

    private fun getDelayUntilNextSync(): Long {

        val now = Calendar.getInstance()

        val target = Calendar.getInstance()

        // next day
        target.add(Calendar.DAY_OF_YEAR, 1)

        // 12:15 AM
        target.set(Calendar.HOUR_OF_DAY, 0)
        target.set(Calendar.MINUTE, 15)
        target.set(Calendar.SECOND, 0)
        target.set(Calendar.MILLISECOND, 0)

        return target.timeInMillis - now.timeInMillis
    }
}