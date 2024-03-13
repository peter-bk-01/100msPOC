import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_hundred_ms/views/room_page.dart';

class HomePage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameTextController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("100ms Demo App"),
          actions: const [],
        ),
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: NetworkImage("https://picsum.photos/200/500"),
            fit: BoxFit.cover,
          )),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    bool res = await getPermissions();
                    if (res && context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (c) => const RoomPage(
                            isBroadCaster: false,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Join as Viewer")),
              ElevatedButton(
                  onPressed: () async {
                    bool res = await getPermissions();
                    if (res && context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (c) => const RoomPage(
                            isBroadCaster: true,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Join as Broadcaster")),
            ],
          )),
        ),
      ),
    );
  }

  Future<bool> getPermissions() async {
    if (Platform.isIOS) return true;
    await Permission.bluetoothConnect.request();
    await Permission.microphone.request();
    await Permission.camera.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }

    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }

    while ((await Permission.bluetoothConnect.isDenied)) {
      await Permission.bluetoothConnect.request();
    }
    return true;
  }
}
