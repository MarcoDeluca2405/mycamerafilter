import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mycamerafilter/PageVideo.dart';
import 'package:mycamerafilter/auth.dart';
import 'package:mycamerafilter/pageCamera.dart';
import 'package:mycamerafilter/pageImage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:loader_overlay/loader_overlay.dart';

import 'dart:typed_data';

enum SampleItem { itemOne, itemTwo, itemThree }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SampleItem? selectedMenu;

  List<File> images = [];
  List<File> listVideo = [];
  List<File> listImage = [];

  late Timer _timer;
  int _start = 3;

  bool isLogout = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            Auth().singOut();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  aSingOut() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: LoaderOverlay(
          useDefaultLoading: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: SpinKitFadingCube(
                  color: Colors.blueAccent,
                  size: 90,
                ),
              ),
              Text(
                "Logout in : $_start",
                style: const TextStyle(fontSize: 20),
              )
            ],
          )),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    requestPermissions(); // Richiedi i permessi quando il widget viene inizializzato
    loadImages(); // Carica le immagini quando il widget viene inizializzato
    _start = 3;

    isLogout = false;
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadImages();
    // Aggiungi qui la logica da eseguire quando il widget viene aggiornato.
  }

  Future<void> loadImages() async {
    final directory = await getExternalStorageDirectory();
    final imageDirectory =
        Directory("${directory!.path}/DCIM/MyCamera/${Auth().getEmail()}");
    listImage = [];
    listVideo = [];

    if (imageDirectory.existsSync()) {
      final imageFiles = imageDirectory.listSync();
      images = imageFiles
          .where((element) => element is File)
          .map((file) => file as File)
          .toList();
      images.forEach((element) => {
            if (element.path.split(".").last == "png")
              {listImage.add(element)}
            else
              {listVideo.add(element)}
          });
      print(listImage.length);
      setState(() {});
    }
  }

  Future<void> deleteImage(File image) async {
    image.delete();
  }

  @override
  Widget build(BuildContext context) {
    Random random = new Random();

    int randomColorShade = random.nextInt(9).clamp(1, 9);

    String newColorString = randomColorShade.toString() + "00";
    int newIntColor = int.parse(newColorString);

    print(newIntColor);

    List color = [
      Colors.red[newIntColor],
      Colors.blue[newIntColor],
      Colors.yellow[newIntColor],
      Colors.green[newIntColor],
      Colors.amber[newIntColor]
    ];

    String? name = Auth().getEmail();

    String inizialName = name!.toUpperCase().toString().substring(0, 2);

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            CircleAvatar(
              backgroundColor: color[random.nextInt(color.length)],
              child: Text(inizialName),
            ),
            PopupMenuButton<SampleItem>(
              offset: Offset(0, 50),
              initialValue: selectedMenu,
              onSelected: (SampleItem item) async {
                if (item == SampleItem.itemOne) {
                  setState(() {
                    isLogout = true;
                  });
                  startTimer();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: SampleItem.itemOne,
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ))
              ],
            )
          ],
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Camera"),
          bottom: isLogout
              ? null
              : const TabBar(
                  tabs: [
                      Tab(
                        icon: Icon(Icons.photo_library_rounded),
                      ),
                      Tab(
                        icon: Icon(Icons.video_camera_front_rounded),
                      ),
                    ],
                  overlayColor:
                      MaterialStatePropertyAll(Color.fromARGB(0, 60, 102, 194)),
                  indicator: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.red, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.elliptical(60, 50),
                          bottomRight: Radius.elliptical(30, 50)),
                      border: Border.symmetric(
                          vertical: BorderSide(
                              width: 1, color: Color.fromARGB(255, 0, 0, 0)),
                          horizontal:
                              BorderSide(width: 1, color: Colors.black))),
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab),
        ),
        backgroundColor: Colors.grey[300],
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLogout
              ? aSingOut()
              : TabBarView(
                  children: [
                    GridView.builder(
                      itemCount: listImage.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              childAspectRatio: 0.5),
                      itemBuilder: (context, index) {
                        return InkResponse(
                          splashColor: Colors.red,
                          radius: 70,
                          onTap: () {
                            Future.delayed(Duration(milliseconds: 500), () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => pageImage(
                                            images: listImage,
                                            indexImage: index,
                                            updateImages: loadImages,
                                            email: name,
                                          )));
                            });
                          },
                          onLongPress: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SizedBox(
                                    height: 100,
                                    child: Center(
                                      child: InkResponse(
                                        onTap: () {
                                          deleteImage(listImage[index]);
                                          loadImages();
                                          Navigator.pop(context);

                                          AnimatedSnackBar.rectangle(
                                                  "Success", "Eliminato",
                                                  type: AnimatedSnackBarType
                                                      .success,
                                                  duration: const Duration(
                                                      seconds: 4),
                                                  animationDuration: Duration(
                                                      milliseconds: 500),
                                                  animationCurve: Curves.easeIn,
                                                  mobileSnackBarPosition:
                                                      MobileSnackBarPosition
                                                          .top,
                                                  brightness: Brightness.dark)
                                              .show(context);
                                        },
                                        child: Container(
                                          width: 1000,
                                          height: 30,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[50]),
                                          child: Text(
                                            "Elimina",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 20,
                                                fontFamily:
                                                    GoogleFonts.robotoFlex()
                                                        .fontFamily),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Image.file(
                            listImage[index],
                            filterQuality: FilterQuality.high,
                          ),
                        );
                      },
                    ),
                    GridView.builder(
                      itemCount: listVideo.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              childAspectRatio: 0.5),
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: VideoThumbnail.thumbnailData(
                              video: listVideo[index].path,
                              quality: 100,
                              imageFormat: ImageFormat.JPEG),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return InkResponse(
                                splashColor: Colors.red,
                                radius: 70,
                                onTap: () {
                                  Future.delayed(Duration(milliseconds: 500),
                                      () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PageVideo(
                                                video: listVideo,
                                                indexVideo: index)));
                                  });
                                },
                                onLongPress: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return SizedBox(
                                          height: 100,
                                          child: Center(
                                            child: InkResponse(
                                              onTap: () {
                                                deleteImage(listVideo[index]);
                                                loadImages();
                                                Navigator.pop(context);

                                                AnimatedSnackBar.rectangle(
                                                        "Success", "Eliminato",
                                                        type:
                                                            AnimatedSnackBarType
                                                                .success,
                                                        duration:
                                                            const Duration(
                                                                seconds: 4),
                                                        animationDuration:
                                                            Duration(
                                                                milliseconds:
                                                                    500),
                                                        animationCurve:
                                                            Curves.easeIn,
                                                        mobileSnackBarPosition:
                                                            MobileSnackBarPosition
                                                                .top,
                                                        brightness:
                                                            Brightness.dark)
                                                    .show(context);
                                              },
                                              child: Container(
                                                width: 1000,
                                                height: 30,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[50]),
                                                child: Text(
                                                  "Elimina",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 20,
                                                      fontFamily: GoogleFonts
                                                              .robotoFlex()
                                                          .fontFamily),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Stack(
                                  children: [
                                    Image.memory(snapshot.data as Uint8List),
                                    const Center(
                                        child: Icon(
                                      Icons.play_circle_fill,
                                      size: 50,
                                      color: Colors.white,
                                    ))
                                  ],
                                ),
                              );
                            } else {
                              return const SpinKitWaveSpinner(
                                  color: Colors.red,
                                  trackColor: Colors.blueGrey,
                                  waveColor: Colors.blue);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("sono stato premuto");

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => pageCamera(
                          updateImages: loadImages,
                          email: name,
                        ))));
          },
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.mediaLibrary,
  ].request();

  if (statuses[Permission.mediaLibrary] == PermissionStatus.granted) {
    print("Il permesso di storage è stato concesso.");
  } else {
    print("Il permesso di storage non è stato concesso.");
  }
}
