import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
// Imports
import '../../Models/appModel.dart';
import '../../Providers/app_provider.dart'; // Assuming refreshTriggerProvider is here
import '../../Services/download_service.dart';
import '../../Providers/download_state_provider.dart';
import '../Views/Widgets/appCard.dart';

class AppInfoCardContainer extends ConsumerStatefulWidget {
  final AppModel app;

  const AppInfoCardContainer({
    super.key,
    required this.app,
  });

  @override
  ConsumerState<AppInfoCardContainer> createState() => _AppInfoCardContainerState();
}

class _AppInfoCardContainerState extends ConsumerState<AppInfoCardContainer> with WidgetsBindingObserver {
  bool _isChecking = true;
  bool _isInstalled = false;
  bool _updateAvailable = false;
  String? _installedVersion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAppStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAppStatus();
    }
  }

  @override
  void didUpdateWidget(covariant AppInfoCardContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.app.version != widget.app.version ||
        oldWidget.app.packageName != widget.app.packageName) {
      _checkAppStatus();
    }
  }

  Future<void> _checkAppStatus() async {
    if (!mounted) return;

    bool? installed = await InstalledApps.isAppInstalled(widget.app.packageName);
    bool updateNeeded = false;
    String? currentVersion;

    if (installed == true) {
      AppInfo? appInfo = await InstalledApps.getAppInfo(widget.app.packageName);

      if (appInfo != null) {
        currentVersion = appInfo.versionName;
        if (currentVersion != widget.app.version) {
          updateNeeded = true;
        } else {
          // Cleanup APK if installed and version matches
          final fileName = '${widget.app.packageName}_${widget.app.version}.apk';
          await DownloadService.deleteApk(fileName);
        }
      }
    }

    if (mounted) {
      setState(() {
        _isInstalled = installed ?? false;
        _updateAvailable = updateNeeded;
        _installedVersion = currentVersion;
        _isChecking = false;
      });
    }
  }

  Future<void> _startDownload() async {
    final fileName = '${widget.app.packageName}_${widget.app.version}.apk';

    ref.read(downloadStateProvider.notifier).updateDownload(
      widget.app.packageName,
      const DownloadState(progress: 0, status: DownloadTaskStatus.enqueued),
    );

    final taskId = await DownloadService.downloadApk(
      url: widget.app.downloadUrl,
      fileName: fileName,
      packageName: widget.app.packageName,
      onProgress: (progress, status) {
        ref.read(downloadStateProvider.notifier).updateProgress(
          widget.app.packageName,
          progress,
          status,
        );

        if (status == DownloadTaskStatus.complete) {
          _handleDownloadComplete();
        }
      },
    );

    if (taskId != null) {
      ref.read(downloadStateProvider.notifier).updateDownload(
        widget.app.packageName,
        DownloadState(taskId: taskId, progress: 0, status: DownloadTaskStatus.running),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start download')),
        );
      }
      ref.read(downloadStateProvider.notifier).removeDownload(widget.app.packageName);
    }
  }

  Future<void> _handleDownloadComplete() async {
    final state = ref.read(downloadStateProvider)[widget.app.packageName];
    final taskId = state?.taskId;

    if (taskId != null) {
      final filePath = await DownloadService.getDownloadedFilePath(taskId);

      if (filePath != null) {
        ref.read(downloadStateProvider.notifier).setFilePath(
          widget.app.packageName,
          filePath,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download complete! Installing...')),
          );
        }

        await DownloadService.installApk(filePath);
        await Future.delayed(const Duration(seconds: 2));
        await _checkAppStatus();

        ref.read(downloadStateProvider.notifier).removeDownload(widget.app.packageName);
      }
    }
  }

  Future<void> _cancelDownload() async {
    final downloadState = ref.read(downloadStateProvider)[widget.app.packageName];
    if (downloadState?.taskId != null) {
      await DownloadService.cancelDownload(downloadState!.taskId!);
      ref.read(downloadStateProvider.notifier).removeDownload(widget.app.packageName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download cancelled')),
        );
      }
    }
  }

  Future<void> _uninstallApp() async {
    await InstalledApps.uninstallApp(widget.app.packageName);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for global refresh events
    ref.listen(refreshTriggerProvider, (previous, next) {
      _checkAppStatus();
    });

    final downloadState = ref.watch(downloadStateProvider)[widget.app.packageName];

    // Pass data and callbacks to the Pure UI Widget
    return AppInfoCardUI(
      app: widget.app,
      isChecking: _isChecking,
      isInstalled: _isInstalled,
      updateAvailable: _updateAvailable,
      installedVersion: _installedVersion,
      downloadState: downloadState,
      onDownload: _startDownload,
      onCancelDownload: _cancelDownload,
      onUninstall: _uninstallApp,
      onOpenApp: () => InstalledApps.startApp(widget.app.packageName),
    );
  }
}