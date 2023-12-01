import 'package:camera_filters/camera_filters.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class pageCamera extends StatefulWidget {
  final Function() updateImages;
  final String email;
  const pageCamera(
      {super.key, required this.updateImages, required this.email});

  @override
  State<pageCamera> createState() => _PageCameraState();
}

class _PageCameraState extends State<pageCamera> {
  String email = "";

  @override
  void initState() {
    super.initState();
    email = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: CameraScreenPlugin(
          onDone: (value) async {
            saveImageToDirectory(value, email);
            widget.updateImages();
            print(value);
          },
          onVideoDone: (value) {
            saveVideoToDirectory(value, email);
            widget.updateImages();
          },
        ));
  }
}

Future<void> saveImageToDirectory(String image, String name) async {
  if (image != null) {
    final externalStorageDirectory = await getExternalStorageDirectory();
    if (externalStorageDirectory != null) {
      final destinationDirectory =
          Directory('${externalStorageDirectory.path}/DCIM/MyCamera/$name');
      if (!destinationDirectory.existsSync()) {
        destinationDirectory.createSync(recursive: true);
      }

      final imageFile = File(image);
      final imageName = image.hashCode;
      final destinationPath = '${destinationDirectory.path}/$imageName.png';

      await imageFile.copy(destinationPath);
      print("Immagine salvata in: $destinationPath");
    } else {
      print("Impossibile ottenere il percorso dell'archivio esterno.");
    }
  }
}

Future<void> saveVideoToDirectory(String video, String name) async {
  if (video != null) {
    final file = File(video);
    final FileName = file.uri.pathSegments.last;
    final extension = FileName.split(".").last;
    final externalStorageDirectory = await getExternalStorageDirectory();
    if (externalStorageDirectory != null) {
      final destinationDirectory =
          Directory('${externalStorageDirectory.path}/DCIM/MyCamera/$name');
      if (!destinationDirectory.existsSync()) {
        destinationDirectory.createSync(recursive: true);
      }

      if (extension == "mp4" || extension == "mov" || extension == "3gp") {
        final videoFile = File(video);
        final videoName = videoFile.hashCode;
        final destinationPath =
            '${destinationDirectory.path}/$videoName.$extension';
        await videoFile.copy(destinationPath);
        print("Video salvato");
      }
    } else {
      print("Impossibile ottenere il percorso dell'archivio esterno.");
    }
  }
}
