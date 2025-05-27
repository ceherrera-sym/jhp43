import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación horizontal (landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  // Ocultar barra de navegación y status bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV4.3 Guanajuato',
      debugShowCheckedModeBanner: false,
      home: TV43Player(),
    );
  }
}

class TV43Player extends StatefulWidget {
  @override
  _TV43PlayerState createState() => _TV43PlayerState();
}

class _TV43PlayerState extends State<TV43Player> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(
        'https://5f1af61612fb5.streamlock.net/tv43gto/smil:tv43gto.smil/chunklist_w778415729_b3128000_sleng.m3u8',
      )
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true); // Repetir video si se corta
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child:
            _controller.value.isInitialized
                ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
                : CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
// https://5f1af61612fb5.streamlock.net/tv43gto/smil:tv43gto.smil/playlist.m3u8


//  "1080p" to "https://5f1af61612fb5.streamlock.net/tv43gto/smil:tv43gto.smil/chunklist_w778415729_b5192000_sleng.m3u8",
//  "720p" to "https://5f1af61612fb5.streamlock.net/tv43gto/smil:tv43gto.smil/chunklist_w778415729_b3128000_sleng.m3u8",
//  "480p" to "https://5f1af61612fb5.streamlock.net/tv43gto/smil:tv43gto.smil/chunklist_w778415729_b1596000_sleng.m3u8",
//  "360p" to "https://5f1af61612fb5.streamlock.net/tv43gto/smil:tv43gto.smil/chunklist_w778415729_b864000_sleng.m3u8",
//  "288p" to "https://5f1af61612fb5.streamlock.net/tv43gto/smil:tv43gto.smil/chunklist_w778415729_b448000_sleng.m3u8",

