package at.mathiaslampert.finanzuebersicht

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

// FragmentActivity wird für den Fingerabdruck-Dialog (local_auth) benötigt.
class MainActivity : FlutterFragmentActivity() {
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pendingPick: MethodChannel.Result? = null

    // Ordner für das automatische Backup (Storage Access Framework). Die App
    // bekommt nur Zugriff auf diesen einen Ordner, ohne Speicher-Berechtigung.
    private val pickFolder = registerForActivityResult(ActivityResultContracts.OpenDocumentTree()) { uri ->
        val result = pendingPick ?: return@registerForActivityResult
        pendingPick = null
        if (uri == null) {
            result.success(null)
            return@registerForActivityResult
        }
        try {
            contentResolver.takePersistableUriPermission(uri, ACCESS)
            result.success(mapOf("uri" to uri.toString(), "name" to folderName(uri)))
        } catch (e: Exception) {
            result.error("pick", e.message, null)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Kein Vorschaubild der App in der Übersicht der zuletzt genutzten Apps.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            setRecentsScreenshotEnabled(false)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(::onFolderCall)
    }

    private fun onFolderCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pick" -> {
                if (pendingPick != null) return result.error("busy", null, null)
                pendingPick = result
                try {
                    pickFolder.launch(null)
                } catch (e: Exception) {
                    pendingPick = null
                    result.error("pick", e.message, null)
                }
            }
            "release" -> {
                runCatching { contentResolver.releasePersistableUriPermission(tree(call), ACCESS) }
                result.success(null)
            }
            "canWrite", "list", "write", "delete" -> background(result) { folderOperation(call) }
            else -> result.notImplemented()
        }
    }

    private fun folderOperation(call: MethodCall): Any? {
        val tree = tree(call)
        return when (call.method) {
            "canWrite" -> contentResolver.persistedUriPermissions.any { it.uri == tree && it.isWritePermission } &&
                runCatching { files(tree) }.isSuccess
            "list" -> files(tree).keys.toList()
            "write" -> {
                val name = call.argument<String>("name")!!
                val bytes = call.argument<ByteArray>("bytes")!!
                val target = files(tree)[name]
                    ?: DocumentsContract.createDocument(contentResolver, folder(tree), "application/octet-stream", name)
                    ?: throw IllegalStateException("could not create $name")
                // "wt" überschreibt eine bestehende Datei vollständig.
                contentResolver.openOutputStream(target, "wt")!!.use { it.write(bytes) }
                null
            }
            "delete" -> {
                files(tree)[call.argument<String>("name")!!]?.let { DocumentsContract.deleteDocument(contentResolver, it) }
                null
            }
            else -> throw IllegalArgumentException(call.method)
        }
    }

    private fun tree(call: MethodCall): Uri = Uri.parse(call.argument<String>("uri")!!)

    private fun folder(tree: Uri): Uri =
        DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))

    /** Files directly in the folder, by display name. */
    private fun files(tree: Uri): Map<String, Uri> {
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
        val columns = arrayOf(Document.COLUMN_DOCUMENT_ID, Document.COLUMN_DISPLAY_NAME, Document.COLUMN_MIME_TYPE)
        val result = mutableMapOf<String, Uri>()
        val cursor = contentResolver.query(children, columns, null, null, null)
            ?: throw IllegalStateException("folder not readable")
        cursor.use {
            while (it.moveToNext()) {
                if (it.getString(2) == Document.MIME_TYPE_DIR) continue
                result[it.getString(1)] = DocumentsContract.buildDocumentUriUsingTree(tree, it.getString(0))
            }
        }
        return result
    }

    private fun folderName(tree: Uri): String? = runCatching {
        contentResolver.query(folder(tree), arrayOf(Document.COLUMN_DISPLAY_NAME), null, null, null)?.use {
            if (it.moveToFirst()) it.getString(0) else null
        }
    }.getOrNull()

    private fun background(result: MethodChannel.Result, task: () -> Any?) {
        io.execute {
            try {
                val value = task()
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error("io", e.message, null) }
            }
        }
    }

    private companion object {
        const val CHANNEL = "at.mathiaslampert.finanzuebersicht/folder"
        const val ACCESS = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
    }
}
