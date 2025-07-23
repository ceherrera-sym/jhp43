import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

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
  List<Map<String, String>> canales = [];
  late VideoPlayerController _controller;
  bool cargando = true;
  bool mostrarMenu = false;

  final driveFileId = '1dY7UWmKIY3AOgQErGP2-J-o0MOlQ1RHe';

  @override
  void initState() {
    super.initState();
    cargarCanales().then((data) {
      setState(() {
        canales = data;
      });
      if (canales.isNotEmpty) {
        iniciarVideo(canales[0]["url"]!);
      }
    });
  }

  Future<List<Map<String, String>>> cargarCanales() async {
    final url = 'https://drive.google.com/uc?export=download&id=$driveFileId';
    final response = await http.get(Uri.parse(url));
    print("Cargando canales desde: $url");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map(
            (e) => {
              "nombre": e["nombre"].toString(),
              "url": e["url"].toString(),
            },
          )
          .toList();
    } else {
      throw Exception("No se pudo cargar el archivo de canales");
    }
  }

  void iniciarVideo(String url) {
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {
          cargando = false;
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  void cambiarCanal(String url) {
    setState(() {
      cargando = true;
    });
    _controller.pause();
    _controller.dispose();
    iniciarVideo(url);
  }

  void toggleMenu() {
    setState(() {
      mostrarMenu = !mostrarMenu;
    });
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          toggleMenu();
        }
      },
      child: GestureDetector(
        onTap: toggleMenu,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Row(
            children: [
              if (mostrarMenu)
                Container(
                  width: 250,
                  color: Colors.grey[900],
                  child: ListView(
                    children:
                        canales
                            .map(
                              (canal) => ListTile(
                                title: Text(
                                  canal["nombre"]!,
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () => cambiarCanal(canal["url"]!),
                              ),
                            )
                            .toList(),
                  ),
                ),
              Expanded(
                child: Center(
                  child:
                      cargando
                          ? CircularProgressIndicator(color: Colors.white)
                          : AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
