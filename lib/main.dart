import 'package:camera_mobile_app/screens/camera.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

  late List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Camera Mobile",
      home: CameraScreen(),
    );
  }
}
