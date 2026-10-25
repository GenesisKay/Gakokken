package com.gakoken.gakoken

import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.media.MediaMetadataRetriever
import android.media.ThumbnailUtils
import android.os.Build
import android.os.Environment
import android.os.FileObserver
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.os.StatFs
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.util.Size
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest
import java.util.concurrent.Executors

/// Lo propio de Android que Gakoken necesita y Flutter no trae: abrir un
/// archivo con el selector de apps del sistema, miniaturas de imágenes, videos
/// y PDF con caché en disco, las memorias conectadas (interna, tarjeta SD,
/// USB) y avisos de cambios en las carpetas abiertas.
class MainActivity : FlutterActivity() {
    private val background = Executors.newFixedThreadPool(3)
    private val main = Handler(Looper.getMainLooper())
    private val thumbsDir by lazy { File(cacheDir, "thumbs").apply { mkdirs() } }

    /// Carpetas vigiladas y adónde mandar sus cambios.
    private val observers = mutableMapOf<String, FileObserver>()
    private var changes: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gakoken/system")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openWith" -> result.success(
                        openWith(call.argument<String>("path")!!, call.argument<String>("title")!!),
                    )
                    "thumbnail" -> {
                        val path = call.argument<String>("path")!!
                        val kind = call.argument<String>("kind")!!
                        val size = call.argument<Int>("size")!!
                        background.execute {
                            val thumb = try { thumbnail(path, kind, size) } catch (e: Exception) { null }
                            main.post { result.success(thumb) }
                        }
                    }
                    "storageVolumes" -> result.success(storageVolumes())
                    "watch" -> {
                        watch(call.argument<List<String>>("paths")!!)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "gakoken/changes")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    changes = events
                }

                override fun onCancel(arguments: Any?) {
                    changes = null
                }
            })
        background.execute { trimThumbs() }
    }

    override fun onDestroy() {
        watch(emptyList())
        super.onDestroy()
    }

    /// Vigila exactamente `paths`: suelta las que ya no están y empieza las
    /// nuevas. Cada cambio llega a Dart como la ruta completa de lo que cambió.
    private fun watch(paths: List<String>) {
        (observers.keys - paths.toSet()).forEach { observers.remove(it)?.stopWatching() }
        val mask = FileObserver.CREATE or FileObserver.DELETE or FileObserver.MOVED_FROM or
            FileObserver.MOVED_TO or FileObserver.CLOSE_WRITE or FileObserver.DELETE_SELF or
            FileObserver.MOVE_SELF
        for (dir in paths) {
            if (observers.containsKey(dir)) continue
            val observer = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                object : FileObserver(File(dir), mask) {
                    override fun onEvent(event: Int, name: String?) = changed(dir, name)
                }
            } else {
                @Suppress("DEPRECATION")
                object : FileObserver(dir, mask) {
                    override fun onEvent(event: Int, name: String?) = changed(dir, name)
                }
            }
            observer.startWatching()
            observers[dir] = observer
        }
    }

    private fun changed(dir: String, name: String?) {
        val path = if (name.isNullOrEmpty()) dir else File(dir, name).path
        main.post { changes?.success(path) }
    }

    /// Muestra siempre el selector "Abrir con". Devuelve opened, noApp o missing.
    private fun openWith(path: String, title: String): String {
        val file = File(path)
        if (!file.exists()) return "missing"
        val extension = file.extension.lowercase()
        val mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension) ?: "*/*"
        val uri = FileProvider.getUriForFile(this, "$packageName.files", file)
        val view = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mime)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        if (packageManager.queryIntentActivities(view, 0).isEmpty()) return "noApp"
        return try {
            startActivity(Intent.createChooser(view, title))
            "opened"
        } catch (e: ActivityNotFoundException) {
            "noApp"
        }
    }

    /// Memorias montadas: ruta, nombre que da Android, tipo (internal, sd o
    /// usb) y espacio total y libre en bytes.
    private fun storageVolumes(): List<Map<String, Any>> {
        val manager = getSystemService(StorageManager::class.java)
        return manager.storageVolumes.mapNotNull { volume ->
            if (volume.state != Environment.MEDIA_MOUNTED) return@mapNotNull null
            val dir = volumeDirectory(volume) ?: return@mapNotNull null
            val stat = try { StatFs(dir.path) } catch (e: Exception) { return@mapNotNull null }
            val kind = when {
                volume.isPrimary || !volume.isRemovable -> "internal"
                isUsb(volume) -> "usb"
                else -> "sd"
            }
            mapOf(
                "path" to dir.path,
                "label" to volume.getDescription(this),
                "kind" to kind,
                "total" to stat.totalBytes,
                "free" to stat.availableBytes,
            )
        }
    }

    private fun volumeDirectory(volume: StorageVolume): File? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            volume.directory
        } else {
            // Antes de Android 11 la ruta solo se obtiene por reflexión.
            try {
                volume.javaClass.getMethod("getPathFile").invoke(volume) as File
            } catch (e: Exception) {
                null
            }
        }

    /// Android no dice en público si una memoria es USB; se pregunta a su
    /// disco por reflexión y, si no se puede, se mira si el nombre dice USB.
    private fun isUsb(volume: StorageVolume): Boolean {
        try {
            val manager = getSystemService(StorageManager::class.java)
            val volumes = manager.javaClass.getMethod("getVolumes").invoke(manager) as List<*>
            val uuid = volume.uuid
            for (info in volumes) {
                if (info == null) continue
                val fsUuid = info.javaClass.getMethod("getFsUuid").invoke(info) as String?
                if (fsUuid != uuid) continue
                val disk = info.javaClass.getMethod("getDisk").invoke(info) ?: continue
                return disk.javaClass.getMethod("isUsb").invoke(disk) as Boolean
            }
        } catch (e: Exception) {
            // Sigue con el nombre.
        }
        return volume.getDescription(this).contains("USB", ignoreCase = true)
    }

    /// Miniatura de `size` px de ancho en el caché de la app: imagen, cuadro
    /// de un video o primera página de un PDF. La llave incluye la fecha de
    /// modificación: si el archivo cambia, se vuelve a hacer. null si no se pudo.
    private fun thumbnail(path: String, kind: String, size: Int): String? {
        val file = File(path)
        if (!file.exists()) return null
        val key = MessageDigest.getInstance("SHA-1")
            .digest("$path|${file.lastModified()}|$size".toByteArray())
            .joinToString("") { "%02x".format(it) }
        val out = File(thumbsDir, "$key.jpg")
        if (out.exists()) {
            // La fecha marca el último uso, para borrar primero lo que no se ve.
            out.setLastModified(System.currentTimeMillis())
            return out.path
        }
        val bitmap = when (kind) {
            "image" -> imageThumbnail(file, size)
            "video" -> videoThumbnail(file, size)
            "pdf" -> pdfThumbnail(file, size)
            else -> null
        } ?: return null
        out.outputStream().use { bitmap.compress(Bitmap.CompressFormat.JPEG, 85, it) }
        bitmap.recycle()
        return out.path
    }

    private fun imageThumbnail(file: File, size: Int): Bitmap? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return ThumbnailUtils.createImageThumbnail(file, Size(size, size), null)
        }
        // Lee solo las medidas y decodifica reducido a lo más cercano.
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(file.path, bounds)
        var sample = 1
        while (bounds.outWidth / (sample * 2) >= size && bounds.outHeight / (sample * 2) >= size) {
            sample *= 2
        }
        return BitmapFactory.decodeFile(file.path, BitmapFactory.Options().apply { inSampleSize = sample })
    }

    private fun videoThumbnail(file: File, size: Int): Bitmap? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return ThumbnailUtils.createVideoThumbnail(file, Size(size, size), null)
        }
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(file.path)
            val frame = retriever.frameAtTime ?: return null
            val height = (size.toFloat() * frame.height / frame.width).toInt().coerceAtLeast(1)
            Bitmap.createScaledBitmap(frame, size, height, true).also {
                if (it != frame) frame.recycle()
            }
        } finally {
            retriever.release()
        }
    }

    private fun pdfThumbnail(file: File, size: Int): Bitmap? {
        ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY).use { fd ->
            PdfRenderer(fd).use { renderer ->
                if (renderer.pageCount == 0) return null
                renderer.openPage(0).use { page ->
                    val height = (size.toFloat() * page.height / page.width).toInt().coerceAtLeast(1)
                    val bitmap = Bitmap.createBitmap(size, height, Bitmap.Config.ARGB_8888)
                    bitmap.eraseColor(Color.WHITE)
                    page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    return bitmap
                }
            }
        }
    }

    /// El caché de miniaturas no pasa de 150 MB: al abrir la app se borran
    /// las menos usadas hasta dejar 100 MB.
    private fun trimThumbs() {
        val files = thumbsDir.listFiles() ?: return
        var total = files.sumOf { it.length() }
        if (total <= 150L * 1024 * 1024) return
        for (old in files.sortedBy { it.lastModified() }) {
            if (total <= 100L * 1024 * 1024) break
            total -= old.length()
            old.delete()
        }
    }
}
