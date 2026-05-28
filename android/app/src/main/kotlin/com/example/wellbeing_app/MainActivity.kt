package com.example.wellbeing_app

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Settings
import androidx.core.content.edit
import com.example.wellbeing_app.usage.UsageStatsRepository
import com.example.wellbeing_app.workers.WorkScheduler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.wellbeing_app/usage"
    private val repository by lazy { UsageStatsRepository(this) }

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
                    val stats = repository.calculateUsage(start, end)
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
                "getPendingUsageSync" -> {
                    val sharedPreferences = getSharedPreferences(
                        "usage_sync",
                        Context.MODE_PRIVATE
                    )
                    val json = sharedPreferences.getString(
                        "pending_usage",
                        null
                    )
                    result.success(json)
                }
                "clearPendingUsageSync" -> {
                    val sharedPreferences = getSharedPreferences(
                        "usage_sync",
                        Context.MODE_PRIVATE
                    )
                    sharedPreferences.edit {
                        remove("pending_usage")
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        WorkScheduler.scheduleNextSync(this)
    }
}