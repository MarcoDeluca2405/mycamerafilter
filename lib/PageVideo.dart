import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PageVideo extends StatefulWidget {
  final List<File> video;
  final int indexVideo;

  const PageVideo({Key? key, required this.video, required this.indexVideo})
      : super(key: key);

  @override
  State<PageVideo> createState() => _PageVideoState();
}

class _PageVideoState extends State<PageVideo> {
  late PageController _pageController;
  bool _isPlaying = false;
  double _sliderValue = 0.0;
  late Duration _videoDuration;
  bool _isVideoInitialized = false;
  late VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.indexVideo);
    _videoPlayerController =
        VideoPlayerController.file(widget.video[widget.indexVideo]);
    _videoDuration = Duration(seconds: 0);
    _initializeVideoController(widget.indexVideo);
  }

  void _initializeVideoController(int index) async {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(widget.video[index]);
    await _videoPlayerController!.initialize();
    _videoDuration = _videoPlayerController!.value.duration;

    /*
    _videoPlayerController?.initialize().then((_) {
      setState(() {
        _isVideoInitialized = true;
        _sliderValue = 0.0;
        _videoDuration = _videoPlayerController!.value.duration;
        _startVideoProgressTimer();
      });
*/
    _videoPlayerController?.addListener(() {
      if (_videoPlayerController!.value.position >=
          _videoPlayerController!.value.duration) {
        print("Video finito");
        setState(() {
          _isPlaying = false;
        });
      }
      if (mounted) {
        setState(() {
          _sliderValue =
              _videoPlayerController!.value.position.inSeconds.toDouble();
        });
      }
    });
    setState(() {
      _isVideoInitialized = true;
    });
    if (_isPlaying) {
      _videoPlayerController!.play();
    }
  }

  void _startVideoProgressTimer() {
    if (_isPlaying && _isVideoInitialized) {
      _videoPlayerController?.play();
    } else {
      _videoPlayerController?.pause();
    }
    _videoPlayerController?.addListener(() {
      if (mounted) {
        setState(() {
          _sliderValue =
              _videoPlayerController!.value.position.inSeconds.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoPlayerController?.dispose();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: PageView.builder(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              controller: _pageController,
              itemCount: widget.video.length,
              onPageChanged: (index) {
                _initializeVideoController(index);
                setState(() {
                  _sliderValue = 0;
                  _isPlaying = false;
                });
              },
              itemBuilder: (context, index) {
                return Center(
                  child: _isVideoInitialized
                      ? Center(
                          child: AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          ),
                        )
                      : const Center(
                          child: SpinKitWaveSpinner(
                            color: Colors.red,
                            trackColor: Colors.blueGrey,
                            waveColor: Colors.blue,
                          ),
                        ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.blueGrey[50],
              child: Column(
                children: [
                  IconButton.outlined(
                    onPressed: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                        _startVideoProgressTimer();
                      });
                    },
                    icon: _isPlaying
                        ? const Icon(Icons.pause_circle)
                        : const Icon(Icons.play_arrow_rounded),
                  ),
                  Slider(
                    value: _sliderValue,
                    onChanged: (value) {
                      _videoPlayerController!
                          .seekTo(Duration(seconds: value.round()));
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                    min: 0.0,
                    label: _sliderValue.round().toString(),
                    max: _videoDuration.inSeconds.toDouble(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
