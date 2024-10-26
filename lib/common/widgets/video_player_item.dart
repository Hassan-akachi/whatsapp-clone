import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';


class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({super.key, required this.videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}


class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late CachedVideoPlayerPlusController videoPlayerPlusController;
  bool isPlay =false;

  @override
  void initState() {
    super.initState();
    videoPlayerPlusController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.videoUrl),
      invalidateCacheIfOlderThan: const Duration(days: 69),
    )..initialize().then((value) async {
      videoPlayerPlusController.setVolume(1);
    }).catchError((error) {
      print("Error initializing video player: $error");
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          CachedVideoPlayerPlus(videoPlayerPlusController),
        Align(alignment:Alignment.center,
            child: IconButton(onPressed: (){
              if(isPlay == false){
                videoPlayerPlusController.pause();
              }else{
                videoPlayerPlusController.play();
              }
              setState(() {
                isPlay = !isPlay;
              });
            },
                icon:  Icon(isPlay? Icons.play_circle: Icons.pause_circle,size: 10,)))
        ],
      ),);
  }
  @override
  void dispose() {
    super.dispose();
    videoPlayerPlusController.dispose();
  }
}
