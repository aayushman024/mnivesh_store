import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnivesh_store/Themes/AppTheme.dart';
import 'Views/Screens/HomePage.dart';
import 'Services/download_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize download service
  await FlutterDownloader.initialize(
      debug: true,
      ignoreSsl: true
  );

  DownloadService.init();

  runApp(const ProviderScope(child: mNiveshStore()));
}

class mNiveshStore extends StatelessWidget {
  const mNiveshStore({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}