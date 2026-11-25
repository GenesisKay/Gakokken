package com.morobu.gakoken.widget

import android.Manifest
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.text.format.DateUtils
import android.text.format.Formatter
import android.util.Log
import android.util.Size
import android.view.View
import android.widget.RemoteViews
import com.morobu.gakoken.MainActivity
import com.morobu.gakoken.R
import com.morobu.gakoken.widget.OrigamiWidgetKit.Style
import com.morobu.gakoken.widget.OrigamiWidgetKit.objects
import com.morobu.gakoken.widget.OrigamiWidgetKit.str
import org.json.JSONObject
import java.io.File
import kotlin.concurrent.thread
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/** Paleta del tema Gakoken por si la app aun no deja datos. */
internal val GAKOKEN_FALLBACK = OrigamiWidgetKit.Palette(
    bg = 0xFFF5F5F5.toInt(),
    text = 0xFF2B1A0E.toInt(),
    text2 = 0xFF6E4A2C.toInt(),
    primary = 0xFFE65C00.toInt(),
    onPrimary = 0xFFFFFFFF.toInt(),
    border = 0xFFF7E3CC.toInt(),
    success = 0xFF4F8F6A.toInt(),
    error = 0xFFB84A4A.toInt(),
    warning = 0xFFC2A14D.toInt(),
    disabled = 0xFFB89A7E.toInt(),
    dark = false,
)

/**
 * Base de los widgets de Gakoken: estilo de cada widget (Normal o Nothing, se
 * elige en [WidgetStyleActivity]), colores y estado vacio.
 */
abstract class GakokenWidgetProvider : AppWidgetProvider() {
    abstract val layoutId: Int
    abstract val nothingLayoutId: Int

    /** Nothing va sin tarjeta; un widget que la quiera (la barra de Buscar) la dibuja el mismo. */
    open val drawsOwnPaper = false

    abstract fun fill(context: Context, views: RemoteViews, id: Int, snap: JSONObject, p: OrigamiWidgetKit.Palette, wDp: Int, hDp: Int, style: Style)

    override fun onDeleted(context: Context, ids: IntArray) {
        OrigamiWidgetKit.forget(context, ids)
    }

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { render(context, manager, it) }
    }

    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, id: Int, newOptions: Bundle?) {
        render(context, manager, id)
    }

    open fun render(context: Context, manager: AppWidgetManager, id: Int) {
        manager.updateAppWidget(id, build(context, manager, id))
    }

    /**
     * Las vistas del widget. Un error al dibujar no tumba el receiver ni deja el widget
     * en blanco: sale el aviso de abrir la app (skill origami-widgets, W-07).
     */
    protected fun build(context: Context, manager: AppWidgetManager, id: Int): RemoteViews = try {
        buildViews(context, manager, id)
    } catch (e: Exception) {
        Log.e("GakokenWidget", "render $id", e)
        RemoteViews(context.packageName, layoutId).apply {
            setViewVisibility(R.id.widget_content, View.GONE)
            setViewVisibility(R.id.widget_message, View.VISIBLE)
            setTextViewText(R.id.widget_message, context.getString(R.string.gakoken_widget_open_app))
            setOnClickPendingIntent(R.id.widget_root, link(context, "gakoken://usage", id, 19))
        }
    }

    private fun buildViews(context: Context, manager: AppWidgetManager, id: Int): RemoteViews {
        val snap = OrigamiWidgetKit.snapshot(context)
        val style = OrigamiWidgetKit.style(context, id)
        val p = OrigamiWidgetKit.paletteFor(context, snap, GAKOKEN_FALLBACK, style)
        val (w, h) = OrigamiWidgetKit.sizeDp(manager, id)
        val nothing = style == Style.NOTHING
        val views = RemoteViews(context.packageName, if (nothing) nothingLayoutId else layoutId)
        // Nothing no lleva tarjeta: va directo sobre el fondo de pantalla, como en el Launcher.
        if (!nothing && !drawsOwnPaper) views.setImageViewBitmap(R.id.widget_paper, OrigamiWidgetKit.card(context, w, h, p))
        views.setViewVisibility(R.id.widget_message, View.GONE)
        views.setViewVisibility(R.id.widget_content, View.VISIBLE)
        fill(context, views, id, snap ?: JSONObject(), p, w, h, style)
        return views
    }

    protected fun showMessage(context: Context, views: RemoteViews, id: Int, message: String, uri: String, p: OrigamiWidgetKit.Palette, style: Style) {
        views.setViewVisibility(R.id.widget_content, View.GONE)
        views.setViewVisibility(R.id.widget_message, View.VISIBLE)
        OrigamiWidgetKit.text(views, R.id.widget_message, message, if (style == Style.NOTHING) p.text else p.primary)
        views.setOnClickPendingIntent(R.id.widget_root, link(context, uri, id, 19))
    }

    protected fun link(context: Context, uri: String, id: Int, slot: Int) =
        OrigamiWidgetKit.launch(context, MainActivity::class.java, uri, id * 20 + slot)

    protected fun t(context: Context, snap: JSONObject, key: String, fallback: Int): String {
        val v = snap.optJSONObject("t")?.str(key).orEmpty()
        return v.ifEmpty { context.getString(fallback) }
    }

    protected fun rowLayout(style: Style) =
        if (style == Style.NOTHING) R.layout.gakoken_widget_row_nothing else R.layout.gakoken_widget_row

    protected fun openUri(path: String, isDir: Boolean) =
        "gakoken://open?path=" + Uri.encode(path) + "&dir=" + (if (isDir) "1" else "0")

    /** Acceso a todos los archivos (como pide la app); sin el, Dar permiso (OR-12). */
    protected fun hasStorage(context: Context): Boolean =
        if (Build.VERSION.SDK_INT >= 30) {
            Environment.isExternalStorageManager()
        } else {
            context.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }
}

// --- Buscar (4 x 1) -----------------------------------------------------------

/** Barra que abre la busqueda de Gakoken con el teclado listo. */
class SearchWidgetProvider : GakokenWidgetProvider() {
    override val layoutId = R.layout.gakoken_widget_search
    override val nothingLayoutId = R.layout.gakoken_widget_search_nothing
    override val drawsOwnPaper = true

    override fun fill(context: Context, views: RemoteViews, id: Int, snap: JSONObject, p: OrigamiWidgetKit.Palette, wDp: Int, hDp: Int, style: Style) {
        val nothing = style == Style.NOTHING
        if (nothing) {
            // Pastilla de tinta translucida de 52 dp, como la barra de busqueda del Launcher.
            val pillH = min(52, max(36, hDp - 16))
            views.setImageViewBitmap(R.id.widget_paper, OrigamiWidgetKit.card(context, max(60, wDp - 12), pillH, p, pillH / 2f))
        } else {
            views.setImageViewBitmap(R.id.widget_paper, OrigamiWidgetKit.card(context, wDp, hDp, p))
        }
        views.setInt(R.id.widget_icon, "setColorFilter", if (nothing) p.text else p.primary)
        OrigamiWidgetKit.text(views, R.id.widget_hint, t(context, snap, "search", R.string.gakoken_widget_search_hint), p.text2)
        views.setOnClickPendingIntent(R.id.widget_root, link(context, "gakoken://search", id, 0))
    }
}

// --- Espacio (2 x 2 a 4 x 2) ----------------------------------------------------

/** Usado contra total con la barra de colores por tipo de la pestana Espacio. */
class StorageWidgetProvider : GakokenWidgetProvider() {
    override val layoutId = R.layout.gakoken_widget_storage
    override val nothingLayoutId = R.layout.gakoken_widget_storage_nothing

    override fun fill(context: Context, views: RemoteViews, id: Int, snap: JSONObject, p: OrigamiWidgetKit.Palette, wDp: Int, hDp: Int, style: Style) {
        if (!hasStorage(context)) {
            showMessage(context, views, id, t(context, snap, "grant", R.string.gakoken_widget_grant), "gakoken://usage", p, style)
            return
        }
        val space = snap.optJSONObject("space")
        if (space == null) {
            showMessage(context, views, id, context.getString(R.string.gakoken_widget_open_app), "gakoken://usage", p, style)
            return
        }
        OrigamiWidgetKit.text(views, R.id.widget_title, t(context, snap, "usage", R.string.gakoken_widget_storage_name), p.text2)
        OrigamiWidgetKit.text(views, R.id.widget_amount, space.str("used"), p.text)
        OrigamiWidgetKit.text(views, R.id.widget_total, " / " + space.str("total"), p.text2)
        OrigamiWidgetKit.text(views, R.id.widget_caption, space.str("free"), p.text2)
        val slices = space.optJSONArray("slices")?.objects().orEmpty()
            .map { it.optDouble("f", 0.0).toFloat() to it.optLong("color", it.optLong("c")).toInt() }
        val freeColor = space.optLong("freeColor", p.border.toLong()).toInt()
        val usedF = space.optDouble("usedF", 0.0).toFloat()
        val list = if (slices.isEmpty()) listOf(usedF to p.primary) else slices
        val barW = max(60, wDp - 32)
        if (style == Style.NOTHING) {
            // Nothing: fila de puntos de tinta, encendidos los del espacio usado.
            views.setImageViewBitmap(R.id.widget_bar, OrigamiWidgetKit.dotBar(context, barW, usedF, p.text, p.border))
        } else {
            views.setImageViewBitmap(R.id.widget_bar, segmentedBar(context, barW, list, freeColor))
        }
        views.setOnClickPendingIntent(R.id.widget_root, link(context, "gakoken://usage", id, 0))
    }

    /** Una sola barra con un tramo por tipo y lo libre al final, como en la app. */
    private fun segmentedBar(context: Context, wDp: Int, slices: List<Pair<Float, Int>>, free: Int): Bitmap {
        val d = context.resources.displayMetrics.density
        val s = min(d, 900f / wDp)
        val w = (wDp * s).roundToInt()
        val h = (12 * s).roundToInt()
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        val clip = Path().apply { addRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), h / 2f, h / 2f, Path.Direction.CW) }
        c.clipPath(clip)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.color = free
        c.drawRect(0f, 0f, w.toFloat(), h.toFloat(), paint)
        val gap = 1.5f * s
        var x = 0f
        for ((f, color) in slices) {
            val sw = w * f.coerceIn(0f, 1f)
            if (sw <= 0f) continue
            paint.color = color
            c.drawRect(x, 0f, min(w.toFloat(), x + sw - gap).coerceAtLeast(x + 1f), h.toFloat(), paint)
            x += sw
        }
        return bmp
    }
}

// --- Favoritos (2 x 2 a 4 x 3) --------------------------------------------------

class FavoritesWidgetProvider : GakokenWidgetProvider() {
    override val layoutId = R.layout.gakoken_widget_list
    override val nothingLayoutId = R.layout.gakoken_widget_list_nothing

    override fun fill(context: Context, views: RemoteViews, id: Int, snap: JSONObject, p: OrigamiWidgetKit.Palette, wDp: Int, hDp: Int, style: Style) {
        val items = snap.optJSONArray("favorites")?.objects().orEmpty()
        if (snap.length() == 0) {
            showMessage(context, views, id, context.getString(R.string.gakoken_widget_open_app), "gakoken://favorites", p, style)
            return
        }
        if (items.isEmpty()) {
            showMessage(context, views, id, t(context, snap, "emptyFavorites", R.string.gakoken_widget_empty_favorites), "gakoken://favorites", p, style)
            return
        }
        OrigamiWidgetKit.text(views, R.id.widget_title, t(context, snap, "favorites", R.string.gakoken_widget_favorites_name), p.text2)
        val rows = max(1, min(12, (hDp - 44) / 40))
        views.removeAllViews(R.id.widget_list)
        items.take(rows).forEachIndexed { i, f ->
            val dir = f.optBoolean("dir")
            val row = RemoteViews(context.packageName, rowLayout(style))
            row.setImageViewResource(R.id.widget_row_icon, if (dir) R.drawable.gakoken_widget_folder else R.drawable.gakoken_widget_file)
            row.setInt(R.id.widget_row_icon, "setColorFilter", if (dir && style == Style.NORMAL) p.primary else if (dir) p.text else p.text2)
            row.setViewVisibility(R.id.widget_row_thumb, View.GONE)
            OrigamiWidgetKit.text(row, R.id.widget_row_name, f.str("name"), p.text)
            row.setViewVisibility(R.id.widget_row_info, View.GONE)
            row.setOnClickPendingIntent(R.id.widget_row, link(context, openUri(f.str("path"), dir), id, 1 + i))
            views.addView(R.id.widget_list, row)
        }
        views.setOnClickPendingIntent(R.id.widget_root, link(context, "gakoken://favorites", id, 0))
    }
}

// --- Recientes (4 x 2 o mas) ----------------------------------------------------

/**
 * Ultimos archivos (por ejemplo lo descargado hoy) con miniatura. Los lee del
 * indice de medios de Android, del mas nuevo al mas viejo, en segundo plano;
 * deja fuera ocultos y la papelera de Gakoken.
 */
class RecentWidgetProvider : GakokenWidgetProvider() {
    override val layoutId = R.layout.gakoken_widget_list
    override val nothingLayoutId = R.layout.gakoken_widget_list_nothing

    private class Recent(val path: String, val name: String, val modified: Long, val size: Long, val uri: Uri, val mime: String?)

    @Volatile
    private var recents: List<Recent> = emptyList()

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val pending = goAsync()
        thread(name = "gakoken-widget-recent") {
            try {
                ids.forEach { renderNow(context, manager, it) }
            } finally {
                pending.finish()
            }
        }
    }

    override fun render(context: Context, manager: AppWidgetManager, id: Int) {
        val pending = goAsync()
        thread(name = "gakoken-widget-recent") {
            try {
                renderNow(context, manager, id)
            } finally {
                pending.finish()
            }
        }
    }

    private fun renderNow(context: Context, manager: AppWidgetManager, id: Int) {
        val (_, h) = OrigamiWidgetKit.sizeDp(manager, id)
        recents = if (hasStorage(context)) query(context, max(1, min(10, (h - 44) / 40))) else emptyList()
        manager.updateAppWidget(id, build(context, manager, id))
    }

    override fun fill(context: Context, views: RemoteViews, id: Int, snap: JSONObject, p: OrigamiWidgetKit.Palette, wDp: Int, hDp: Int, style: Style) {
        if (!hasStorage(context)) {
            showMessage(context, views, id, t(context, snap, "grant", R.string.gakoken_widget_grant), "gakoken://usage", p, style)
            return
        }
        val items = recents
        if (items.isEmpty()) {
            showMessage(context, views, id, context.getString(R.string.gakoken_widget_empty_recent), "gakoken://search", p, style)
            return
        }
        OrigamiWidgetKit.text(views, R.id.widget_title, t(context, snap, "recent", R.string.gakoken_widget_recent_name), p.text2)
        views.removeAllViews(R.id.widget_list)
        val thumbPx = OrigamiWidgetKit.dp(context, 32f).roundToInt()
        items.forEachIndexed { i, r ->
            val row = RemoteViews(context.packageName, rowLayout(style))
            val thumb = thumbnail(context, r, thumbPx)
            if (thumb != null) {
                row.setViewVisibility(R.id.widget_row_icon, View.GONE)
                row.setViewVisibility(R.id.widget_row_thumb, View.VISIBLE)
                row.setImageViewBitmap(R.id.widget_row_thumb, rounded(thumb, thumbPx))
            } else {
                row.setViewVisibility(R.id.widget_row_thumb, View.GONE)
                row.setImageViewResource(R.id.widget_row_icon, R.drawable.gakoken_widget_file)
                row.setInt(R.id.widget_row_icon, "setColorFilter", p.text2)
            }
            OrigamiWidgetKit.text(row, R.id.widget_row_name, r.name, p.text)
            val info = DateUtils.formatDateTime(
                context,
                r.modified,
                DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_ABBREV_MONTH or DateUtils.FORMAT_SHOW_TIME,
            ) + " · " + Formatter.formatShortFileSize(context, r.size)
            row.setViewVisibility(R.id.widget_row_info, View.VISIBLE)
            OrigamiWidgetKit.text(row, R.id.widget_row_info, info, p.text2)
            row.setOnClickPendingIntent(R.id.widget_row, link(context, openUri(r.path, false), id, 1 + i))
            views.addView(R.id.widget_list, row)
        }
        views.setOnClickPendingIntent(R.id.widget_root, link(context, "gakoken://search", id, 0))
    }

    private fun query(context: Context, limit: Int): List<Recent> {
        val out = mutableListOf<Recent>()
        val base = MediaStore.Files.getContentUri("external")
        val projection = arrayOf(
            MediaStore.Files.FileColumns._ID,
            MediaStore.Files.FileColumns.DATA,
            MediaStore.Files.FileColumns.DISPLAY_NAME,
            MediaStore.Files.FileColumns.DATE_MODIFIED,
            MediaStore.Files.FileColumns.SIZE,
            MediaStore.Files.FileColumns.MIME_TYPE,
        )
        val selection = "${MediaStore.Files.FileColumns.MIME_TYPE} IS NOT NULL AND ${MediaStore.Files.FileColumns.SIZE} > 0"
        try {
            val cursor = if (Build.VERSION.SDK_INT >= 26) {
                val args = Bundle().apply {
                    putString(android.content.ContentResolver.QUERY_ARG_SQL_SELECTION, selection)
                    putStringArray(android.content.ContentResolver.QUERY_ARG_SORT_COLUMNS, arrayOf(MediaStore.Files.FileColumns.DATE_MODIFIED))
                    putInt(android.content.ContentResolver.QUERY_ARG_SORT_DIRECTION, android.content.ContentResolver.QUERY_SORT_DIRECTION_DESCENDING)
                    putInt(android.content.ContentResolver.QUERY_ARG_LIMIT, 80)
                }
                context.contentResolver.query(base, projection, args, null)
            } else {
                context.contentResolver.query(base, projection, selection, null, "${MediaStore.Files.FileColumns.DATE_MODIFIED} DESC")
            }
            cursor?.use { c ->
                while (c.moveToNext() && out.size < limit) {
                    val path = c.getString(1) ?: continue
                    // Ocultos (nombres con punto) y la papelera (.gakoken-trash) no van.
                    if (path.split('/').any { it.startsWith(".") }) continue
                    if (!File(path).isFile) continue
                    val name = c.getString(2) ?: File(path).name
                    out.add(
                        Recent(
                            path = path,
                            name = name,
                            modified = c.getLong(3) * 1000L,
                            size = c.getLong(4),
                            uri = ContentUris.withAppendedId(base, c.getLong(0)),
                            mime = c.getString(5),
                        ),
                    )
                }
            }
        } catch (_: Exception) {
            // Sin indice de medios: el widget muestra su estado vacio.
        }
        return out
    }

    private fun thumbnail(context: Context, r: Recent, px: Int): Bitmap? {
        val mime = r.mime ?: return null
        val media = mime.startsWith("image/") || mime.startsWith("video/") || mime == "application/pdf"
        if (!media || Build.VERSION.SDK_INT < 29) return null
        return try {
            context.contentResolver.loadThumbnail(r.uri, Size(px * 2, px * 2), null)
        } catch (_: Exception) {
            null
        }
    }

    /** Miniatura cuadrada con esquinas redondeadas. */
    private fun rounded(src: Bitmap, px: Int): Bitmap {
        val out = Bitmap.createBitmap(px, px, Bitmap.Config.ARGB_8888)
        val c = Canvas(out)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
        val r = px * 0.22f
        val clip = Path().apply { addRoundRect(RectF(0f, 0f, px.toFloat(), px.toFloat()), r, r, Path.Direction.CW) }
        c.clipPath(clip)
        val side = min(src.width, src.height)
        val sx = (src.width - side) / 2
        val sy = (src.height - side) / 2
        c.drawBitmap(src, android.graphics.Rect(sx, sy, sx + side, sy + side), android.graphics.Rect(0, 0, px, px), paint)
        return out
    }
}
