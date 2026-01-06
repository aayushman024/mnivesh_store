import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnivesh_store/Themes/AppTheme.dart';
import 'Services/notification_service.dart';
import 'Views/Screens/HomePage.dart';
import 'Services/download_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // 2. Initialize Notifications
  await NotificationService.init();

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

      scaffoldMessengerKey: NotificationService.messengerKey,

      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}