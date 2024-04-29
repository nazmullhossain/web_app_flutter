import 'package:flutter/material.dart';
import 'package:web_ksa/responsiveness.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// String viewID = "LHHtiU9Skq4?si=wgczHaroc7X2OGzC";
String viewID = "LHHtiU9Skq4";

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  final _controller = YoutubePlayerController.fromVideoId(
    videoId: viewID,
    params: const YoutubePlayerParams(
      mute: false,
      showControls: true,
      enableCaption: false,
      showVideoAnnotations: false,
      showFullscreenButton: true,
    ),
  );


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.screenWidth >= Responsive.maxMobileWidth ? 700.h : 500.h,
      width: MediaQuery.of(context).size.width,
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: 21/9,
      ),
    );
  }
}
