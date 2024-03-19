import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
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
              // state.peerTrackNodes.isNotEmpty
              //     ?
              //     : const SizedBox(),

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
                                      ? VideoView(e.hmsVideoTrack!)
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

              // THis is only fir listeners
              SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _listenerOnlyList(state.peerTrackNodes).length,
                    itemBuilder: (ctx, index) {
                      return state.peerTrackNodes[index].hmsAudioTrack == null
                          ? CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.green,
                              child: Text(
                                state.peerTrackNodes[index].peer!.name[0]
                                    .toUpperCase(),
                                maxLines: 5,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            )
                          : const SizedBox();
                    },
                  )),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  List<PTrackNode> _getVideoOfBroadcaster(List<PTrackNode> peerTrackNodes) {
    var newList =
        peerTrackNodes.where((e) => e.peer?.videoTrack != null).toList();
    log("${newList.length}lorem ipsum dolor sit amet 44444447732382bhibsdisd94394594504545niwefa df################################################");
    return newList;
  }

  List<PTrackNode> _listenerOnlyList(List<PTrackNode> peerTrackNodes) {
    var newList =
        peerTrackNodes.where((e) => e.peer?.audioTrack == null).toList();
    return newList;
  }

  int getNotNullVideoTrackIndex(List<PTrackNode> peerTrackNodes) {
    var index = peerTrackNodes.indexWhere((e) => e.hmsVideoTrack != null);
    return index >= 0 ? index : -1;
  }

  HMSVideoTrack getPTrackNode(List<PTrackNode> peerTrackNodes) {
    return peerTrackNodes[getNotNullVideoTrackIndex(peerTrackNodes)]
        .hmsVideoTrack!;
  }
}
