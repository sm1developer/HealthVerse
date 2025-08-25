package com.appverse.healthverse

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.content.Context
import android.provider.Settings
import android.net.Uri
import android.app.usage.UsageStatsManager
import android.content.pm.PackageManager
import android.Manifest
import android.content.pm.PackageManager.PERMISSION_GRANTED
import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {
    private val CHANNEL = "battery_optimizer"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestBatteryOptimizationExemption" -> {
                    requestBatteryOptimizationExemption(result)
                }
                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }
                "startSleepTrackingService" -> {
                    startSleepTrackingService(result)
                }
                "stopSleepTrackingService" -> {
                    stopSleepTrackingService(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun requestBatteryOptimizationExemption(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            val packageName = packageName
            
            if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
                result.success(true)
            } else {
                result.success(true)
            }
        } else {
            result.success(true)
        }
    }
    
    private fun isIgnoringBatteryOptimizations(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            powerManager.isIgnoringBatteryOptimizations(packageName)
        } else {
            true
        }
    }
    
    private fun startSleepTrackingService(result: MethodChannel.Result) {
        try {
            val intent = Intent(this, SleepTrackingService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("SERVICE_ERROR", "Failed to start sleep tracking service", e.message)
        }
    }
    
    private fun stopSleepTrackingService(result: MethodChannel.Result) {
        try {
            val intent = Intent(this, SleepTrackingService::class.java)
            stopService(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("SERVICE_ERROR", "Failed to stop sleep tracking service", e.message)
        }
    }
    
    override fun onResume() {
        super.onResume()
        // Check battery optimization status when app resumes
        if (!isIgnoringBatteryOptimizations()) {
            // Show a gentle reminder to the user
            // This could be implemented as a dialog or notification
        }
    }
}


