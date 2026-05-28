package com.example.wellbeing_app.workers

import android.util.Log
import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.wellbeing_app.usage.UsageStatsRepository
import org.json.JSONObject
import java.util.Calendar
import androidx.core.content.edit

class UsageSyncWorker(
    context: Context,
    params : WorkerParameters
) : CoroutineWorker(context, params) {
    /*
        Worker = task container
        doWork() = actual task execution
    */
    override suspend fun doWork(): Result {
        /*
            Why applicationContext
            Inside worker:
                - no Activity exists
                - no FlutterActivity exists
                - no UI lifecycle exists
            Worker is pure background execution.

            So: applicationContext
        */
        return try {
            val repository = UsageStatsRepository(applicationContext)

            val calendar = Calendar.getInstance()

            // move to yesterday
            calendar.add(Calendar.DAY_OF_YEAR, -1)

            // yesterday 00:00:00
            calendar.set(Calendar.HOUR_OF_DAY, 0)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            calendar.set(Calendar.MILLISECOND, 0)

            val startTime = calendar.timeInMillis

            // yesterday 23:59:59
            calendar.set(Calendar.HOUR_OF_DAY, 23)
            calendar.set(Calendar.MINUTE, 59)
            calendar.set(Calendar.SECOND, 59)
            calendar.set(Calendar.MILLISECOND, 999)

            val endTime = calendar.timeInMillis

            val usageMap =
                repository.calculateUsage(
                    startTime,
                    endTime
                )

            val sharedPreferences = applicationContext.getSharedPreferences(
                "usage_sync",
                Context.MODE_PRIVATE
            )

            val json = JSONObject(usageMap as Map<*,*>).toString()

            Log.d( "UsageSyncWorker", "Saved JSON: $json" )

            sharedPreferences
                .edit {
                    putString("pending_usage", json)
                }

            Log.d( "UsageSyncWorker", "Usage Result: $usageMap" )
            WorkScheduler.scheduleNextSync(applicationContext)
            Result.success()
        } catch(e: Exception) {
            Log.e( "UsageSyncWorker", "Worker failed", e )
            Result.failure()
        }

    }
}