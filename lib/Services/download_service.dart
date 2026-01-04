import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

// Top-Level Callback (Must be outside class)
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

class DownloadService {
  static const String _portName = 'downloader_send_port';
  static final ReceivePort _port = ReceivePort();

  // Registry to hold callbacks for running tasks
  static final Map<String, Function(int, int)> _callbacks = {};

  // Initialize the global listener ONCE
  static void init() {
    // 1. Clean up old port if it exists (fixes hot restart issues)
    IsolateNameServer.removePortNameMapping(_portName);

    // 2. Register new port
    IsolateNameServer.registerPortWithName(_port.sendPort, _portName);

    // 3. Listen to all events
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];

      // Route the event to the specific callback for this Task ID
      if (_callbacks.containsKey(id)) {
        _callbacks[id]!(progress, status);
      }
    });

    // 4. Register the background callback
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static Future<String?> downloadApk({
    required String url,
    required String fileName,
    required String packageName,
    required Function(int, DownloadTaskStatus) onProgress,
  }) async {
    // Permissions
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) await Permission.notification.request();
      var storage = await Permission.storage.status;
      if (!storage.isGranted) await Permission.storage.request();
      if (await Permission.requestInstallPackages.isDenied) await Permission.requestInstallPackages.request();
    }

    // Directory
    final directory = await getExternalStorageDirectory();
    if (directory == null) return null;
    final savePath = directory.path;
    final filePath = '$savePath/$fileName';

    // Cleanup
    final file = File(filePath);
    if (await file.exists()) await file.delete();

    try {
      // Enqueue
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: false,
      );

      if (taskId != null) {
        // REGISTER THE CALLBACK HERE
        _callbacks[taskId] = (prog, statInt) {
          final statusEnum = DownloadTaskStatus.values[statInt];
          onProgress(prog, statusEnum);

          // Cleanup callback if done
          if (statusEnum == DownloadTaskStatus.complete || statusEnum == DownloadTaskStatus.failed) {
            _callbacks.remove(taskId);
          }
        };
      }

      return taskId;
    } catch (e) {
      print("Download Error: $e");
      return null;
    }
  }

  static Future<String?> getDownloadedFilePath(String taskId) async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks == null) return null;
    try {
      final task = tasks.firstWhere((t) => t.taskId == taskId);
      if (task.status == DownloadTaskStatus.complete) {
        return '${task.savedDir}/${task.filename}';
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<void> deleteApk(String fileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) await file.delete();
    }
  }

  static Future<void> cancelDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
    _callbacks.remove(taskId);
  }

  static Future<bool> installApk(String filePath) async {
    final result = await OpenFilex.open(filePath);
    return result.type == ResultType.done;
  }
}