package com.morobu.gakoken.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.morobu.gakoken.R
import com.morobu.gakoken.widget.OrigamiWidgetKit.Style
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Configuracion de un widget (OR-17): elegir su estilo, Normal o Nothing.
 * Sale al ponerlo y, en Android 12+, al mantenerlo presionado > Ajustes del
 * widget. Es una lista flotante (G-13), no una hoja de abajo; tocar fuera o
 * Atras deja el estilo que ya tenia (Normal si es nuevo) y el widget se queda.
 */
class WidgetStyleActivity : Activity() {
    private var widgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        widgetId = intent?.extras?.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            ?: AppWidgetManager.INVALID_APPWIDGET_ID
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }
        // Salir sin elegir no cancela el widget: se queda con su estilo.
        setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId))
        setContentView(build())
    }

    private fun dp(v: Float) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, resources.displayMetrics)
    private fun dpi(v: Float) = dp(v).roundToInt()

    private fun build(): View {
        val snap = OrigamiWidgetKit.snapshot(this)
        val p = OrigamiWidgetKit.palette(this, snap, GAKOKEN_FALLBACK)
        val current = OrigamiWidgetKit.style(this, widgetId)
        val dots: Typeface? = if (Build.VERSION.SDK_INT >= 26) runCatching { resources.getFont(R.font.doto) }.getOrNull() else null

        val root = FrameLayout(this).apply {
            setBackgroundColor(0x66000000)
            setOnClickListener { done(current) }
        }
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpi(20f), dpi(20f), dpi(20f), dpi(16f))
            background = GradientDrawable().apply {
                setColor(p.bg)
                cornerRadius = dp(20f)
                setStroke(dpi(1f), p.border)
            }
            isClickable = true
        }
        card.addView(TextView(this).apply {
            text = getString(R.string.origami_widget_style_title)
            setTextColor(p.text)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
            typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
        })
        val options = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, dpi(16f), 0, 0)
        }
        val screenDp = resources.configuration.screenWidthDp
        val optionW = min(150, (min(screenDp - 48, 360) - 40 - 12) / 2)
        val optionH = (optionW * 0.62f).roundToInt()
        for ((i, style) in listOf(Style.NORMAL, Style.NOTHING).withIndex()) {
            val selected = style == current
            val option = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER_HORIZONTAL
                setPadding(dpi(6f), dpi(6f), dpi(6f), dpi(8f))
                background = GradientDrawable().apply {
                    cornerRadius = dp(16f)
                    setColor(0)
                    setStroke(dpi(if (selected) 2f else 1f), if (selected) p.primary else p.border)
                }
                setOnClickListener { done(style) }
                contentDescription = label(style)
            }
            option.addView(ImageView(this).apply {
                setImageBitmap(OrigamiWidgetKit.stylePreview(this@WidgetStyleActivity, style, p, optionW, optionH, dots))
                importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
            }, LinearLayout.LayoutParams(dpi(optionW.toFloat()), dpi(optionH.toFloat())))
            option.addView(TextView(this).apply {
                text = label(style)
                setTextColor(if (selected) p.primary else p.text)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
                maxLines = 1
                setPadding(0, dpi(8f), 0, 0)
            })
            options.addView(option, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                if (i > 0) marginStart = dpi(12f)
            })
        }
        card.addView(options)
        if (Build.VERSION.SDK_INT >= 31) {
            card.addView(TextView(this).apply {
                text = getString(R.string.origami_widget_style_hint)
                setTextColor(p.text2)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
                maxWidth = dpi(300f)
                setPadding(0, dpi(14f), 0, 0)
            })
        }
        root.addView(card, FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER))
        return root
    }

    private fun label(style: Style) = getString(
        if (style == Style.NOTHING) R.string.origami_widget_style_nothing else R.string.origami_widget_style_normal,
    )

    private fun done(style: Style) {
        OrigamiWidgetKit.setStyle(this, widgetId, style)
        OrigamiWidgetKit.refresh(this, widgetId)
        finish()
    }

    @Deprecated("Atras deja el estilo que tenia")
    override fun onBackPressed() {
        done(OrigamiWidgetKit.style(this, widgetId))
    }
}
