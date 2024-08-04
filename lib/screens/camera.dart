import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_mobile_app/main.dart';
import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() {
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            Permission.camera.request();
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  Future<void> printImage(XFile img) async {
    try {
      File file = File(img.path);

      // Print the image
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
        final pdf = pw.Document();
        final image = pw.MemoryImage(file.readAsBytesSync());

        pdf.addPage(pw.Page(build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        }));
        return pdf.save();
      });
    } catch (e) {
      ("Error printing image: $e").log();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Camera Mobile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: controller.value.isInitialized
          ? Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              height: 100,
                              child: AspectRatio(
                                aspectRatio: 1 / controller.value.aspectRatio,
                                child: CameraPreview(controller),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: context.screenWidth,
                    height: 65,
                    color: Colors.black.withOpacity(0.5),
                    child: GestureDetector(
                      onTap: () {
                        controller.takePicture().then((img) {
                          printImage(img);
                        });
                      },
                      child: Container(
                        height: 55,
                        width: 55,
                        decoration:
                            BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: Container(
                          height: 42,
                          width: 42,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ).center,
                      ).center,
                    ),
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.black,
              child: GestureDetector(
                onTap: () {
                  Permission.camera.request().then((status) {
                    if (status == PermissionStatus.granted) {
                      initCamera();
                    }
                  });
                },
                child: const Text(
                  "Allow Camera Access",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ).center,
              ),
            ),
    );
  }
}
