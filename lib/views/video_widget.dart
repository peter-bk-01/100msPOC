import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_hundred_ms/bloc/room/room_overview_bloc.dart';
import 'package:video_hundred_ms/bloc/room/room_overview_state.dart';
import 'package:video_hundred_ms/views/video_view.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({super.key});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomOverviewBloc, RoomOverviewState>(
      builder: (ctx, state) => SizedBox(
        child: (state.peerTrackNodes[0].peer!.isLocal
                    ? !state.isVideoMute
                    : !state.peerTrackNodes[0].isMute!) &&
                !(state.peerTrackNodes[0].isOffScreen)
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 400.0,
                          width: 400.0,
                          child:
                              VideoView(state.peerTrackNodes[0].hmsVideoTrack!),
                        ),
                        Text(
                          state.peerTrackNodes[0].peer!.name,
                        ),
                        Text(
                            "${state.peerTrackNodes[0].peer?.networkQuality?.quality ?? ""}")
                      ],
                    ),
                  ),
                ],
              )
            : Container(
                height: 500.0,
                width: 400.0,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 36,
                        child: Text(
                          state.peerTrackNodes[0].peer!.name[0],
                          style: const TextStyle(
                              fontSize: 36, color: Colors.white),
                        )),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      state.peerTrackNodes[0].peer!.name,
                    )
                  ],
                )),
      ),
    );
  }
}

// FocusDetector(
        
//         child: 
// onFocusGained: () {
//           if (state.leaveMeeting && !mounted) {
//             return;
//           }
//           context
//               .read<RoomOverviewBloc>()
//               .add(RoomOverviewSetOffScreen(false, 0));
//         },
//         onFocusLost: () {
//           if (state.leaveMeeting && !mounted) {
//             return;
//           }
//           context
//               .read<RoomOverviewBloc>()
//               .add(RoomOverviewSetOffScreen(true, 0));
//         },