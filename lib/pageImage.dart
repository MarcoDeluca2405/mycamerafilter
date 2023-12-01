import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:colorfilter_generator/addons.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class pageImage extends StatefulWidget {
  final List<File> images;
  final int indexImage;
  final Function() updateImages;
  final String email;

  const pageImage(
      {Key? key,
      required this.images,
      required this.indexImage,
      required this.updateImages,
      required this.email})
      : super(key: key);

  @override
  State<pageImage> createState() => _pageImageState();
}

class _pageImageState extends State<pageImage> {
  late PageController _pageController;
  double _bringht = 0;
  double _contrast = 0;
  double _saturation = 1;
  double _red = 0;
  double _green = 0;
  double _blue = 0;
  bool _switchColors = false;
  bool _menu = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.indexImage);
    _bringht = 0;
    _contrast = 0;
    _saturation = 1;
    _menu = false;
    _red = 0;
    _green = 0;
    _blue = 0;
    _switchColors = false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        body: PageView.builder(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          controller: _pageController,
          onPageChanged: (value) {
            setState(() {
              _bringht = 0;
              _contrast = 0;
              _saturation = 0;
              _menu = false;
              _red = 0;
              _green = 0;
              _blue = 0;
              _switchColors = false;
            });
          },
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return Center(
              child: GestureDetector(
                onDoubleTap: () {
                  Navigator.pop(context);
                },
                child: Stack(children: [
                  Container(
                      alignment: Alignment.center,
                      height: _menu ? 530 : null,
                      child: _menu
                          ? ColorFiltered(
                              colorFilter: _colorFilterGenerator(),
                              child: Image.file(widget.images[index]))
                          : Image.file(widget.images[index])),
                  _menu
                      ? Positioned(
                          top: 0,
                          right: 0,
                          width: 100,
                          child: ElevatedButton(
                              onPressed: () async {
                                _showSnackBoxLoading();
                                Future.delayed(
                                    const Duration(milliseconds: 1000),
                                    () => {
                                          _saveFilteredImage(
                                                  widget.images[index])
                                              .whenComplete(() => {
                                                    widget.updateImages(),
                                                    _showSnackBox()
                                                  })
                                        });
                              },
                              child: const Text("Save")),
                        )
                      : Container(),
                  !_menu
                      ? Positioned(
                          bottom: 20,
                          right: 10,
                          child: IconButton.outlined(
                              onPressed: () {
                                setState(() {
                                  _menu = true;
                                });
                              },
                              style: const ButtonStyle(
                                  splashFactory: InkSplash.splashFactory,
                                  overlayColor:
                                      MaterialStatePropertyAll(Colors.blue),
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.grey)),
                              icon: const Icon(Icons.menu)))
                      : Container()
                ]),
              ),
            );
          },
        ),
        bottomSheet: _menu == true
            ? Container(
                height: 190,
                width: double.infinity,
                color: Colors.grey[150],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 30,
                              child: Switch(
                                  inactiveThumbColor: Colors.blue,
                                  activeColor: Colors.grey,
                                  inactiveTrackColor: Colors.black54,
                                  activeTrackColor: Colors.purple[100],
                                  thumbIcon: _switchColors
                                      ? const MaterialStatePropertyAll(
                                          Icon(Icons.invert_colors_on))
                                      : const MaterialStatePropertyAll(Icon(
                                          Icons.palette_sharp,
                                          color: Colors.black,
                                        )),
                                  value: _switchColors,
                                  onChanged: (value) {
                                    setState(() {
                                      _switchColors = !_switchColors;
                                    });
                                  }),
                            ),
                            Container(
                              width: 30, // Larghezza desiderata
                              height: 30, // Altezza desiderata
                              child: IconButton.outlined(
                                onPressed: () {
                                  setState(() {
                                    _menu = false;
                                  });
                                },
                                splashColor: Colors.red,
                                highlightColor: Colors.blue,
                                color: Colors.black,
                                icon: const Icon(
                                  Icons.close,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        )),

                    //Bringht
                    SfSlider(
                        min: _switchColors ? -100 : -1,
                        max: _switchColors ? 100 : 1,
                        inactiveColor:
                            _switchColors ? Colors.red[300] : Colors.amber[100],
                        activeColor: _switchColors ? Colors.red : Colors.amber,
                        showTicks: true,
                        enableTooltip: true,
                        thumbIcon: _switchColors
                            ? Icon(
                                Icons.format_color_fill_sharp,
                                color: Colors.black,
                                size: 20,
                              )
                            : Icon(
                                Icons.wb_sunny_sharp,
                                color: Colors.black45,
                                size: 20,
                              ),
                        value: _switchColors ? _red : _bringht,
                        onChanged: _switchColors
                            ? (value) {
                                setState(() {
                                  _red = value;
                                });
                              }
                            : (value) {
                                setState(() {
                                  _bringht = value;
                                });
                              }),

                    //Contrast
                    SfSlider(
                        min: _switchColors ? -100 : -1,
                        max: _switchColors ? 100 : 1,
                        inactiveColor: _switchColors
                            ? Colors.green[300]
                            : Colors.grey[100],
                        activeColor: _switchColors ? Colors.green : Colors.grey,
                        showTicks: true,
                        enableTooltip: true,
                        thumbIcon: _switchColors
                            ? Icon(Icons.format_color_fill_sharp,
                                color: Colors.black, size: 20)
                            : Icon(
                                Icons.contrast_rounded,
                                color: Colors.black45,
                                size: 20,
                              ),
                        value: _switchColors ? _green : _contrast,
                        onChanged: _switchColors
                            ? (value) {
                                setState(() {
                                  _green = value;
                                });
                              }
                            : (value) {
                                setState(() {
                                  _contrast = value;
                                });
                              }),

                    //Saturation

                    SfSlider(
                        min: _switchColors ? -100 : 0,
                        max: _switchColors ? 100 : 1,
                        inactiveColor:
                            _switchColors ? Colors.blue[400] : Colors.red,
                        activeColor: _switchColors ? Colors.blue : Colors.black,
                        showTicks: true,
                        enableTooltip: true,
                        thumbIcon: _switchColors
                            ? Icon(
                                Icons.format_color_fill_sharp,
                                color: Colors.black,
                                size: 20,
                              )
                            : Icon(
                                Icons.colorize_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                        value: _switchColors ? _blue : _saturation,
                        onChanged: _switchColors
                            ? (value) {
                                setState(() {
                                  _blue = value;
                                });
                              }
                            : (value) {
                                setState(() {
                                  _saturation = value;
                                });
                              }),
                  ]),
                ),
              )
            : null);
  }

  _showSnackBoxLoading() {
    AnimatedSnackBar.rectangle("Info", "Caricamento in corso...",
            type: AnimatedSnackBarType.info,
            duration: const Duration(seconds: 4),
            animationDuration: Duration(milliseconds: 500),
            animationCurve: Curves.easeIn,
            mobileSnackBarPosition: MobileSnackBarPosition.top,
            brightness: Brightness.dark)
        .show(context);
  }

  Future<void> _showSnackBox() async {
    AnimatedSnackBar.rectangle("Success", "Salvato Correttamente",
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 4),
            animationDuration: Duration(milliseconds: 500),
            animationCurve: Curves.easeIn,
            mobileSnackBarPosition: MobileSnackBarPosition.top,
            brightness: Brightness.dark)
        .show(context);
  }

  ColorFilter _colorFilterGenerator() {
    ColorFilterGenerator myFilter =
        ColorFilterGenerator(name: "CustomFilter", filters: [
      ColorFilterAddons.brightness(_bringht),
      ColorFilterAddons.contrast(_contrast),
      ColorFilterAddons.saturation((_saturation + 0.5) / 2 - 1),
      ColorFilterAddons.rgbScale(
          (_red + 100) / 100, (_green + 100) / 100, (_blue + 100) / 100)
    ]);
    return ColorFilter.matrix(myFilter.matrix);
  }

  Future<void> _saveFilteredImage(File originalImage) async {
    List<int> bytes = await originalImage.readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;

    print(_saturation);

    img.Image filteredImage = img.adjustColor(image,
        brightness: _bringht + 1, saturation: _saturation, amount: 1);

    filteredImage = img.contrast(image, contrast: (_contrast + 1) * 100);

    filteredImage =
        img.colorOffset(image, red: _red, green: _green, blue: _blue);

    final externalStorageDirectory = await getExternalStorageDirectory();
    final destinationDirectory = Directory(
        '${externalStorageDirectory?.path}/DCIM/MyCamera/${widget.email}');
    final imageName = image.hashCode;
    final destinationPath = '${destinationDirectory.path}/$imageName.png';

    File(destinationPath).writeAsBytesSync(img.encodePng(filteredImage));
  }
}
