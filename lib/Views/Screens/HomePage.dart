import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnivesh_store/ViewModels/app_card_view_model.dart';
import 'package:mnivesh_store/Views/Widgets/appCard.dart';
import '../Widgets/homeAppBar.dart';
import '../../Providers/app_provider.dart';
import '../../Services/permission_helper.dart';

class HomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}
class _HomePageState extends ConsumerState<HomePage> {

  @override
  void initState() {
    super.initState();
    // 2. Trigger permissions when page loads
    _askPermissions();
  }

  Future<void> _askPermissions() async {
    // Small delay to let UI build first
    await Future.delayed(const Duration(milliseconds: 500));
    await PermissionHelper.requestAll();
  }

  @override
  Widget build(BuildContext context) {
    final appsAsyncValue = ref.watch(appsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          return await ref.refresh(appsProvider.future);
        },
        edgeOffset: kToolbarHeight + 20,
        color: Colors.white,
        backgroundColor: const Color(0xFF7C4DFF),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const HomeSliverAppBar(userName: "Aayushman Ranjan"),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: appsAsyncValue.when(
                data: (apps) {
                  if (apps.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text("No apps found.")),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => AppInfoCardContainer(app: apps[index]),
                      childCount: apps.length,
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
    );
  }
}