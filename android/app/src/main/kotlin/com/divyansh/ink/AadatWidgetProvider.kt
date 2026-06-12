package com.divyansh.ink

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class AadatWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.aadat_widget)
            
            // Set current date formatted like "Thu, 12 Jun"
            try {
                val currentDate = java.text.SimpleDateFormat("EEE, d MMM", java.util.Locale.US).format(java.util.Date())
                views.setTextViewText(R.id.widget_date, currentDate)
            } catch (e: Exception) {
                // Fail-safe
            }
            
            val habitCount = widgetData.getInt("habit_count", 0)
            
            if (habitCount == 0) {
                views.setViewVisibility(R.id.widget_empty_text, View.VISIBLE)
                views.setViewVisibility(R.id.widget_row_0, View.GONE)
                views.setViewVisibility(R.id.widget_row_1, View.GONE)
                views.setViewVisibility(R.id.widget_row_2, View.GONE)
                views.setViewVisibility(R.id.widget_row_3, View.GONE)
                views.setViewVisibility(R.id.widget_more_text, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_empty_text, View.GONE)
                
                val rows = arrayOf(R.id.widget_row_0, R.id.widget_row_1, R.id.widget_row_2, R.id.widget_row_3)
                val names = arrayOf(R.id.widget_name_0, R.id.widget_name_1, R.id.widget_name_2, R.id.widget_name_3)
                val checkboxes = arrayOf(R.id.widget_checkbox_0, R.id.widget_checkbox_1, R.id.widget_checkbox_2, R.id.widget_checkbox_3)
                val streaks = arrayOf(R.id.widget_streak_0, R.id.widget_streak_1, R.id.widget_streak_2, R.id.widget_streak_3)
                val dividers = arrayOf(R.id.widget_divider_0, R.id.widget_divider_1, R.id.widget_divider_2)
                
                for (i in 0 until 4) {
                    val habitId = widgetData.getInt("habit_id_$i", -1)
                    if (i < habitCount && habitId != -1) {
                        views.setViewVisibility(rows[i], View.VISIBLE)
                        if (i > 0) {
                            views.setViewVisibility(dividers[i - 1], View.VISIBLE)
                        }
                        
                        val name = widgetData.getString("habit_name_$i", "")
                        val completed = widgetData.getBoolean("habit_completed_$i", false)
                        val streak = widgetData.getInt("habit_streak_$i", 0)
                        
                        views.setTextViewText(names[i], name)
                        views.setTextViewText(streaks[i], if (streak > 0) "${streak}d" else "")
                        
                        if (completed) {
                            views.setImageViewResource(checkboxes[i], R.drawable.widget_checked)
                        } else {
                            views.setImageViewResource(checkboxes[i], R.drawable.widget_unchecked)
                        }
                        
                        // Set up pending intent for interactive check-in on the entire row
                        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("aadat://checkin?id=$habitId")
                        )
                        views.setOnClickPendingIntent(rows[i], backgroundIntent)
                        
                    } else {
                        views.setViewVisibility(rows[i], View.GONE)
                        if (i > 0) {
                            views.setViewVisibility(dividers[i - 1], View.GONE)
                        }
                    }
                }

                val truncatedCount = widgetData.getInt("habit_truncated_count", 0)
                if (truncatedCount > 0) {
                    views.setViewVisibility(R.id.widget_more_text, View.VISIBLE)
                    views.setTextViewText(R.id.widget_more_text, "+$truncatedCount more")
                } else {
                    views.setViewVisibility(R.id.widget_more_text, View.GONE)
                }
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
