import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../Models/appModel.dart';
import '../Services/api_service.dart';

// The ApiService instance
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final refreshTriggerProvider = StateProvider<int>((ref) => 0);

// The ViewModel/Controller
class AppsNotifier extends AsyncNotifier<List<AppModel>> {
  @override
  FutureOr<List<AppModel>> build() async {
    // Automatically fetches data when the provider is first watched
    return _fetchApps();
  }

  Future<List<AppModel>> _fetchApps() async {
    final apiService = ref.read(apiServiceProvider);
    return await apiService.fetchApps();
  }

  // Method to refresh manually if needed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchApps());
  }
}

// The exposed provider
final appsProvider = AsyncNotifierProvider<AppsNotifier, List<AppModel>>(() {
  return AppsNotifier();
});