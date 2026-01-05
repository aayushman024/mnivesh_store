import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:mnivesh_store/ViewModels/app_card_view_model.dart';
import '../Widgets/bottomNavBar.dart';
import '../Widgets/homeAppBar.dart';
import '../../Models/appModel.dart';
import '../../Providers/app_provider.dart';
import '../../Services/permission_helper.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  // 0 = Installed (Default), 1 = Updates, 2 = Store
  int _currentIndex = 0;

  // Local state to track app status for filtering
  final Map<String, bool> _installedStatus = {};
  final Map<String, bool> _updateStatus = {};
  bool _isStatusChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _askPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final appsValue = ref.read(appsProvider);
      if (appsValue.hasValue) {
        _checkAppsStatus(appsValue.value!);
      }
    }
  }

  Future<void> _askPermissions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await PermissionHelper.requestAll();
  }

  Future<void> _checkAppsStatus(List<AppModel> apps) async {
    Map<String, bool> newInstalled = {};
    Map<String, bool> newUpdates = {};

    for (var app in apps) {
      bool installed = await InstalledApps.isAppInstalled(app.packageName) ?? false;
      bool updateNeeded = false;

      if (installed) {
        AppInfo? info = await InstalledApps.getAppInfo(app.packageName);
        if (info != null && info.versionName != app.version) {
          updateNeeded = true;
        }
      }

      newInstalled[app.packageName] = installed;
      newUpdates[app.packageName] = updateNeeded;
    }

    if (mounted) {
      setState(() {
        _installedStatus.clear();
        _updateStatus.clear();
        _installedStatus.addAll(newInstalled);
        _updateStatus.addAll(newUpdates);
        _isStatusChecking = false;
      });
    }
  }

  List<AppModel> _getFilteredApps(List<AppModel> allApps) {
    if (_isStatusChecking) return [];

    return allApps.where((app) {
      final isInstalled = _installedStatus[app.packageName] ?? false;
      final isUpdate = _updateStatus[app.packageName] ?? false;

      switch (_currentIndex) {
        case 0: // Installed Apps
          return isInstalled;
        case 1: // Updates Available
          return isInstalled && isUpdate;
        case 2: // Store (Not Installed)
          return !isInstalled;
        default:
          return false;
      }
    }).toList();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appsAsyncValue = ref.watch(appsProvider);

    ref.listen<AsyncValue<List<AppModel>>>(appsProvider, (prev, next) {
      next.whenData((apps) {
        if (_installedStatus.isEmpty || _installedStatus.length != apps.length) {
          _checkAppsStatus(apps);
        }
      });
    });

    // Calculate update count safely
    final int updateCount = _updateStatus.values.where((needsUpdate) => needsUpdate).length;

    return Scaffold(
      extendBody: false, // Changed to false
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isStatusChecking = true;
          });
          final newApps = await ref.refresh(appsProvider.future);
          await _checkAppsStatus(newApps);
        },
        edgeOffset: kToolbarHeight + 20,
        color: Colors.white,
        backgroundColor: const Color(0xFF7C4DFF),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const HomeSliverAppBar(userName: "Aayushman Ranjan"),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), // Normal padding all around
              sliver: appsAsyncValue.when(
                data: (apps) {
                  if (_isStatusChecking && _installedStatus.isEmpty) {
                    _checkAppsStatus(apps);
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final filteredApps = _getFilteredApps(apps);

                  if (filteredApps.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated icon with gradient background
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      _getEmptyIconColor().withOpacity(0.2),
                                      _getEmptyIconColor().withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.3, 0.6, 1.0],
                                  ),
                                ),
                                child: Icon(
                                  _getEmptyIcon(),
                                  size: 80,
                                  color: _getEmptyIconColor(),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Main message
                              Text(
                                _getEmptyMessage(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              // Subtitle
                              Text(
                                _getEmptySubtitle(),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => AppInfoCardContainer(
                          key: ValueKey(filteredApps[index].packageName),
                          app: filteredApps[index]
                      ),
                      childCount: filteredApps.length,
                    ),
                  );
                },
                error: (err, stack) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "Error: $err",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        updateCount: updateCount,
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_currentIndex) {
      case 0: return "No apps installed yet";
      case 1: return "Everything's up to date";
      case 2: return "No apps in store";
      default: return "No apps found";
    }
  }

  String _getEmptySubtitle() {
    switch (_currentIndex) {
      case 0: return "Install apps from the store to get started";
      case 1: return "All your apps are running the latest versions";
      case 2: return "Check back later for new apps";
      default: return "";
    }
  }

  IconData _getEmptyIcon() {
    switch (_currentIndex) {
      case 0: return Icons.inventory_2_outlined;
      case 1: return Icons.verified_outlined;
      case 2: return Icons.store_outlined;
      default: return Icons.error_outline;
    }
  }

  Color _getEmptyIconColor() {
    switch (_currentIndex) {
      case 0:
        return const Color(0xFF7C4DFF).withOpacity(0.6);
      case 1:
        return const Color(0xFF4CAF50).withOpacity(0.6);
      case 2:
        return const Color(0xFF2196F3).withOpacity(0.6);
      default:
        return Colors.grey;
    }
  }
}