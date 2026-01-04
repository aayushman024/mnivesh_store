import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../Models/appModel.dart';
import '../services/api_service.dart';

// Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Trigger for refreshing UI from outside if needed
final refreshTriggerProvider = StateProvider<int>((ref) => 0);

// ViewModel for the List of Apps
class AppsListNotifier extends AsyncNotifier<List<AppModel>> {
  @override
  FutureOr<List<AppModel>> build() async {
    return _fetchApps();
  }

  Future<List<AppModel>> _fetchApps() async {
    final apiService = ref.read(apiServiceProvider);
    return await apiService.fetchApps();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchApps());
  }
}

final appsProvider = AsyncNotifierProvider<AppsListNotifier, List<AppModel>>(() {
  return AppsListNotifier();
});