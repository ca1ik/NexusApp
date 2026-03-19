package com.example.nexus_app

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.plugin.common.MethodChannel

/**
 * Exposes fine-grained haptic patterns to Flutter via MethodChannel.
 *
 * Patterns:
 *  - "fracture" : Long, crescendo vibration sequence — mirrors the psychological rupture.
 *  - "arena"    : Short, rhythmic double-pulse — tension escalation in battle mode.
 */
class HapticFeedbackChannel(private val context: Context) {

    companion object {
        const val CHANNEL_NAME = "com.example.nexus_app/haptic"

        // Fracture: growing intensity — 200ms → 400ms → 600ms bursts
        private val FRACTURE_TIMINGS = longArrayOf(0L, 200L, 100L, 400L, 50L, 600L)
        private val FRACTURE_AMPLITUDES = intArrayOf(0, 140, 0, 200, 0, 255)

        // Arena: double-tap rhythm
        private val ARENA_TIMINGS = longArrayOf(0L, 80L, 40L, 80L)
        private val ARENA_AMPLITUDES = intArrayOf(0, 200, 0, 255)
    }

    fun setupChannel(channel: MethodChannel) {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "triggerFractureHaptic" -> {
                    vibrate(FRACTURE_TIMINGS, FRACTURE_AMPLITUDES)
                    result.success(null)
                }
                "triggerArenaHaptic" -> {
                    vibrate(ARENA_TIMINGS, ARENA_AMPLITUDES)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun vibrate(timings: LongArray, amplitudes: IntArray) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE)
                    as VibratorManager
            val vibrator = manager.defaultVibrator
            vibrator.vibrate(
                VibrationEffect.createWaveform(timings, amplitudes, -1),
            )
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            @Suppress("DEPRECATION")
            val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            vibrator.vibrate(
                VibrationEffect.createWaveform(timings, amplitudes, -1),
            )
        } else {
            @Suppress("DEPRECATION")
            val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            @Suppress("DEPRECATION")
            vibrator.vibrate(timings, -1)
        }
    }
}
