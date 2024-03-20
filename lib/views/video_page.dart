import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_hundred_ms/bloc/room/p_track_node.dart';
import 'package:video_hundred_ms/bloc/room/room_bloc.dart';
import 'package:video_hundred_ms/bloc/room/room_state.dart';
import 'package:video_hundred_ms/views/video_view.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key, required this.isBroadCaster});

  final bool isBroadCaster;

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomBloc, RoomState>(
      buildWhen: (previous, current) => current is RoomPeerTrackNodeUpdated,
      builder: (ctx, state) {
        if (state is RoomPeerTrackNodeUpdated &&
            state.peerTrackNodes.isNotEmpty) {
          return Column(
            children: [
              Column(
                children: [
                  ...state.peerTrackNodes.map(
                    (e) => e.hmsVideoTrack != null
                        ? Stack(
                            children: [
                              SizedBox(
                                  height: 400.0,
                                  width: 400.0,
                                  child: e.hmsVideoTrack != null
                                      ? e.hmsVideoTrack!.isMute

                                          /// When Video Camera is Off
                                          ? CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.blue,
                                              child: Text(
                                                e.peer!.name
                                                    .substring(0, 2)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : VideoView(e
                                              .hmsVideoTrack!) // When Video is on
                                      : const SizedBox()),
                              Positioned(
                                top: 20,
                                child: Text(
                                  "User==>${e.peer!.name}",
                                ),
                              ),
                              Text(
                                  "Network Quality: ${e.peer?.networkQuality?.quality ?? ""}")
                            ],
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
              const Text(
                "Listeners",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              // THis is only fir listeners
              SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _listenerOnlyList(state.peerTrackNodes).length,
                      itemBuilder: (ctx, index) {
                        return CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.green,
                          child: Text(
                            _listenerOnlyList(state.peerTrackNodes)[index]
                                .peer!
                                .name
                                .substring(0, 2)
                                .toUpperCase(),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        );
                      },
                    ),
                  )),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  List<PTrackNode> _listenerOnlyList(List<PTrackNode> peerTrackNodes) {
    var newList = peerTrackNodes.where((e) => e.hmsVideoTrack == null).toList();
    return newList;
  }
}
