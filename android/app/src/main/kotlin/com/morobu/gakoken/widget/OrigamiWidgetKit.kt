package com.morobu.gakoken.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import android.net.Uri
import android.os.Build
import android.util.TypedValue
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Widgets de Android de la serie Origami (OR-17): piezas comunes.
 *
 * Flutter deja un solo JSON ya calculado y traducido en las preferencias de
 * home_widget (clave [SNAPSHOT_KEY]); los widgets solo lo leen y lo dibujan,
 * nunca calculan ni abren la base de datos.
 *
 * Cada widget tiene dos estilos que el usuario elige al ponerlo (y despues,
 * manteniendolo presionado, en Android 12+): [Style.NORMAL], tarjeta con los
 * colores del tema activo de la app, y [Style.NOTHING], como los widgets
 * propios del Launcher: sin tarjeta, tinta clara sobre el fondo de pantalla y
 * cifras en Doto. Ninguno lleva esquina doblada.
 */
object OrigamiWidgetKit {
    const val SNAPSHOT_KEY = "origami_widget_snapshot"
    const val LOCAL_PREFS = "origami_widget_local"
    const val ACTION_LAUNCH = "es.antonborri.home_widget.action.LAUNCH"

    enum class Style { NORMAL, NOTHING }

    data class Palette(
        val bg: Int,
        val text: Int,
        val text2: Int,
        val primary: Int,
        val onPrimary: Int,
        val border: Int,
        val success: Int,
        val error: Int,
        val warning: Int,
        val disabled: Int,
        val dark: Boolean,
        /** Color secundario del tema (en Eloisa, el de grabacion). 0 = usar primary. */
        val secondary: Int = 0,
    ) {
        val accent: Int get() = if (secondary != 0) secondary else primary
    }

    fun snapshot(context: Context): JSONObject? = try {
        HomeWidgetPlugin.getData(context).getString(SNAPSHOT_KEY, null)?.let { JSONObject(it) }
    } catch (_: Exception) {
        null
    }

    fun local(context: Context) = context.getSharedPreferences(LOCAL_PREFS, Context.MODE_PRIVATE)

    // --- Estilo por widget ---------------------------------------------------

    fun style(context: Context, id: Int): Style =
        if (local(context).getString("style_$id", null) == Style.NOTHING.name) Style.NOTHING else Style.NORMAL

    fun setStyle(context: Context, id: Int, style: Style) {
        local(context).edit().putString("style_$id", style.name).apply()
    }

    fun forget(context: Context, ids: IntArray) {
        val e = local(context).edit()
        ids.forEach { e.remove("style_$it") }
        e.apply()
    }

    /** Vuelve a dibujar un solo widget, sea del proveedor que sea. */
    fun refresh(context: Context, id: Int) {
        val info = AppWidgetManager.getInstance(context).getAppWidgetInfo(id) ?: return
        val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE).apply {
            component = info.provider
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(id))
        }
        context.sendBroadcast(intent)
    }

    // --- Colores ---------------------------------------------------------------

    private fun systemIsDark(context: Context): Boolean =
        (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) ==
            Configuration.UI_MODE_NIGHT_YES

    /**
     * Paleta del tema activo. El JSON trae `theme.light` y, si la app sigue al
     * sistema, `theme.dark`; `theme.mode` dice cual usar ("light", "dark" o "system").
     */
    fun palette(context: Context, snap: JSONObject?, fallback: Palette): Palette {
        val theme = snap?.optJSONObject("theme") ?: return fallback
        val mode = theme.optString("mode", "light")
        val pick = when {
            mode == "dark" -> theme.optJSONObject("dark") ?: theme.optJSONObject("light")
            mode == "system" && systemIsDark(context) -> theme.optJSONObject("dark") ?: theme.optJSONObject("light")
            else -> theme.optJSONObject("light")
        } ?: return fallback
        fun c(key: String, def: Int) = if (pick.has(key)) pick.optLong(key).toInt() else def
        val bg = c("bg", fallback.bg)
        return Palette(
            bg = bg,
            text = c("text", fallback.text),
            text2 = c("text2", fallback.text2),
            primary = c("primary", fallback.primary),
            onPrimary = c("onPrimary", fallback.onPrimary),
            border = c("border", fallback.border),
            success = c("success", fallback.success),
            error = c("error", fallback.error),
            warning = c("warning", fallback.warning),
            disabled = c("disabled", fallback.disabled),
            dark = luminance(bg) < 0.4f,
            secondary = c("secondary", fallback.secondary),
        )
    }

    /**
     * Paleta Nothing, igual a la tinta de los widgets propios del Launcher: sin
     * tarjeta, directo sobre el fondo de pantalla, texto casi blanco con sombra
     * suave (la sombra va en los layouts), superficies translucidas de tinta y
     * un solo acento rojo para lo que esta grabando (no rojo puro, G-07).
     * [bg] y [border] son la pastilla translucida de botones y barra de busqueda.
     */
    fun nothing(base: Palette): Palette {
        val red = 0xFFE5333B.toInt()
        return Palette(
            bg = INK_SURFACE,
            text = INK,
            text2 = INK_MUTED,
            primary = red,
            onPrimary = INK,
            border = INK_BORDER,
            success = base.success,
            error = red,
            warning = base.warning,
            disabled = 0x66F7F7F5,
            dark = true,
            secondary = red,
        )
    }

    const val INK = 0xFFF7F7F5.toInt()
    const val INK_MUTED = 0xCCF7F7F5.toInt()
    const val INK_SURFACE = 0x2EF7F7F5
    const val INK_BORDER = 0x52F7F7F5

    fun paletteFor(context: Context, snap: JSONObject?, fallback: Palette, style: Style): Palette {
        val base = palette(context, snap, fallback)
        return if (style == Style.NOTHING) nothing(base) else base
    }

    fun blend(a: Int, b: Int, t: Float): Int {
        fun ch(x: Int, y: Int) = (x + (y - x) * t).roundToInt().coerceIn(0, 255)
        return Color.argb(
            255,
            ch(Color.red(a), Color.red(b)),
            ch(Color.green(a), Color.green(b)),
            ch(Color.blue(a), Color.blue(b)),
        )
    }

    fun withAlpha(color: Int, alpha: Float): Int =
        Color.argb((alpha.coerceIn(0f, 1f) * 255).roundToInt(), Color.red(color), Color.green(color), Color.blue(color))

    fun luminance(color: Int): Float =
        (0.2126f * Color.red(color) + 0.7152f * Color.green(color) + 0.0722f * Color.blue(color)) / 255f

    // --- Medidas -----------------------------------------------------------------

    /** Tamano real del widget en dp, en vertical: ancho minimo y alto maximo. */
    fun sizeDp(manager: AppWidgetManager, id: Int): Pair<Int, Int> {
        val o = manager.getAppWidgetOptions(id)
        val w = o.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
        val h = o.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 0)
        return Pair(if (w > 0) w else 250, if (h > 0) h else 110)
    }

    fun dp(context: Context, v: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, context.resources.displayMetrics)

    /** Radio de esquina de los widgets del sistema (Android 12+); antes, 24 dp. */
    fun cornerDp(context: Context): Float {
        if (Build.VERSION.SDK_INT >= 31) {
            try {
                val px = context.resources.getDimension(android.R.dimen.system_app_widget_background_radius)
                if (px > 0f) return px / context.resources.displayMetrics.density
            } catch (_: Exception) {
            }
        }
        return 24f
    }

    /** Escala de los bitmaps: la densidad, sin pasar de 900 px de ancho. */
    private fun scaleFor(context: Context, wDp: Int): Float {
        val d = context.resources.displayMetrics.density
        return min(d, 900f / max(1, wDp))
    }

    // --- Piezas de dibujo ------------------------------------------------------

    /**
     * Fondo del widget: tarjeta redondeada con el radio del sistema y borde
     * fino, como las Card de la app. [radiusDp] grande da una pastilla.
     */
    fun card(context: Context, wDp: Int, hDp: Int, p: Palette, radiusDp: Float = cornerDp(context)): Bitmap {
        val s = scaleFor(context, wDp)
        val w = max(1, (wDp * s).roundToInt())
        val h = max(1, (hDp * s).roundToInt())
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        val stroke = max(1f, 1f * s)
        val inset = stroke / 2
        val r = min(radiusDp * s, min(w, h) / 2f)
        val rect = RectF(inset, inset, w - inset, h - inset)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.style = Paint.Style.FILL
        paint.color = p.bg
        c.drawRoundRect(rect, r, r, paint)
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = stroke
        paint.color = p.border
        c.drawRoundRect(rect, r, r, paint)
        return bmp
    }

    /** Barra fina con pista, como la LineBar de la app. */
    fun bar(context: Context, wDp: Int, ratio: Float, color: Int, track: Int, thicknessDp: Float = 4f): Bitmap {
        val s = scaleFor(context, wDp)
        val w = max(2, (wDp * s).roundToInt())
        val h = max(2, (thicknessDp * s).roundToInt())
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val rad = h / 2f
        paint.color = track
        c.drawRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), rad, rad, paint)
        val fill = (w * ratio.coerceIn(0f, 1f))
        if (fill > 0f) {
            paint.color = color
            c.drawRoundRect(RectF(0f, 0f, max(fill, h.toFloat()), h.toFloat()), rad, rad, paint)
        }
        return bmp
    }

    /** Circulo solido (punto de color de leyendas y botones). */
    fun circle(context: Context, sizeDp: Float, color: Int): Bitmap {
        val px = max(2, dp(context, sizeDp).roundToInt())
        val bmp = Bitmap.createBitmap(px, px, Bitmap.Config.ARGB_8888)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.color = color
        Canvas(bmp).drawCircle(px / 2f, px / 2f, px / 2f, paint)
        return bmp
    }

    /** Aro (borde de los botones de tinta del estilo Nothing). */
    fun ring(context: Context, sizeDp: Float, color: Int, strokeDp: Float = 1.5f): Bitmap {
        val px = max(2, dp(context, sizeDp).roundToInt())
        val bmp = Bitmap.createBitmap(px, px, Bitmap.Config.ARGB_8888)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val sw = max(1f, dp(context, strokeDp))
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = sw
        paint.color = color
        Canvas(bmp).drawCircle(px / 2f, px / 2f, px / 2f - sw / 2f, paint)
        return bmp
    }

    /** Pastilla redondeada de un color (fondo de botones). */
    fun pill(context: Context, wDp: Int, hDp: Int, color: Int, radiusDp: Float = 16f): Bitmap {
        val s = scaleFor(context, wDp)
        val w = max(2, (wDp * s).roundToInt())
        val h = max(2, (hDp * s).roundToInt())
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.color = color
        val r = min(radiusDp * s, min(w, h) / 2f)
        Canvas(bmp).drawRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), r, r, paint)
        return bmp
    }

    /** Fila de puntos (barra del estilo Nothing): los primeros [ratio] encendidos. */
    fun dotBar(context: Context, wDp: Int, ratio: Float, on: Int, off: Int, pitchDp: Float = 7f): Bitmap {
        val pitch = dp(context, pitchDp)
        val n = max(4, (wDp / pitchDp).toInt())
        val w = max(2, (n * pitch).roundToInt())
        val h = max(2, pitch.roundToInt())
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val lit = (n * ratio.coerceIn(0f, 1f)).roundToInt().let { if (ratio > 0f) max(1, it) else 0 }
        for (i in 0 until n) {
            paint.color = if (i < lit) on else off
            c.drawCircle(pitch * i + pitch / 2f, h / 2f, pitch * 0.36f, paint)
        }
        return bmp
    }

    /**
     * Muestra de un estilo para la ventana de configuracion. Nothing se dibuja
     * sobre un fondo de pantalla de ejemplo, como queda en inicio; [dots] es Doto.
     */
    fun stylePreview(context: Context, style: Style, base: Palette, wDp: Int, hDp: Int, dots: Typeface?): Bitmap {
        val s = scaleFor(context, wDp)
        val w = max(1, (wDp * s).roundToInt())
        val h = max(1, (hDp * s).roundToInt())
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val pad = 14f * s
        if (style == Style.NOTHING) {
            val p = nothing(base)
            val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val c = Canvas(bmp)
            val r = 18f * s
            paint.shader = LinearGradient(0f, 0f, w.toFloat(), h.toFloat(), 0xFF3B4250.toInt(), 0xFF6B5B73.toInt(), Shader.TileMode.CLAMP)
            c.drawRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), r, r, paint)
            paint.shader = null
            paint.color = p.primary
            c.drawCircle(pad + 4f * s, pad + 4f * s, 4f * s, paint)
            paint.color = p.text
            paint.typeface = dots ?: Typeface.MONOSPACE
            paint.textSize = 30f * s
            paint.setShadowLayer(6f * s, 0f, 0f, 0x66000000)
            c.drawText("12:34", pad, h - pad, paint)
            return bmp
        }
        val bmp = card(context, wDp, hDp, base, 18f)
        val c = Canvas(bmp)
        val r = 13f * s
        paint.color = base.primary
        c.drawCircle(pad + r, h / 2f, r, paint)
        val x = pad + 2 * r + 10f * s
        paint.color = base.text
        c.drawRoundRect(RectF(x, h / 2f - 9f * s, w - pad - 8f * s, h / 2f - 3f * s), 3f * s, 3f * s, paint)
        paint.color = base.text2
        c.drawRoundRect(RectF(x, h / 2f + 3f * s, w - pad - 28f * s, h / 2f + 8f * s), 3f * s, 3f * s, paint)
        return bmp
    }

    // --- Acciones ----------------------------------------------------------------

    /** Abre la app en la pantalla exacta (deep link que Flutter recibe con home_widget). */
    fun launch(context: Context, activity: Class<*>, uri: String, requestCode: Int): PendingIntent {
        val intent = Intent(context, activity).apply {
            action = ACTION_LAUNCH
            data = Uri.parse(uri)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= 23) flags = flags or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getActivity(context, requestCode, intent, flags)
    }

    /** Broadcast al propio proveedor (por ejemplo, la pausa de Eloisa). */
    fun selfBroadcast(context: Context, provider: Class<*>, action: String, widgetId: Int): PendingIntent {
        val intent = Intent(context, provider).apply {
            this.action = action
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            data = Uri.parse("origami-widget://$action/$widgetId")
        }
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= 23) flags = flags or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, widgetId, intent, flags)
    }

    fun refreshAll(context: Context, provider: Class<*>) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, provider))
        if (ids.isEmpty()) return
        val intent = Intent(context, provider).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        context.sendBroadcast(intent)
    }

    fun text(views: RemoteViews, id: Int, value: CharSequence?, color: Int) {
        views.setTextViewText(id, value ?: "")
        views.setTextColor(id, color)
    }

    fun JSONObject.str(key: String, def: String = ""): String =
        if (has(key) && !isNull(key)) optString(key, def) else def

    fun JSONArray.objects(): List<JSONObject> = (0 until length()).mapNotNull { optJSONObject(it) }
}
