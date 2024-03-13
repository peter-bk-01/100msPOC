import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_hundred_ms/bloc/room/room_overview_bloc.dart';
import 'package:video_hundred_ms/bloc/room/room_overview_event.dart';
import 'package:video_hundred_ms/bloc/room/room_overview_state.dart';
import 'package:video_hundred_ms/home_page.dart';
import 'package:video_hundred_ms/views/video_widget.dart';

class Room extends StatefulWidget {
  final String meetingUrl;
  final String userName;
  final bool isVideoOff;
  final bool isAudioOff;
  final bool isScreenshareActive;
  final String? roomCode;
  static Route route(
      String url, String name, bool v, bool a, bool ss, String? roomCode) {
    return MaterialPageRoute<void>(
        builder: (_) => Room(
              url,
              name,
              v,
              a,
              ss,
              roomCode: roomCode,
            ));
  }

  const Room(this.meetingUrl, this.userName, this.isVideoOff, this.isAudioOff,
      this.isScreenshareActive,
      {super.key, this.roomCode});

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  HMSSDK hmssdk = HMSSDK();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoomOverviewBloc(
        widget.isVideoOff,
        widget.isAudioOff,
        widget.userName,
        widget.meetingUrl,
        widget.isScreenshareActive,
        widget.roomCode,
        hmssdk,
      )..add(
          const RoomOverviewSubscriptionRequested(),
        ),
      lazy: false,
      child: RoomWidget(widget.meetingUrl, widget.userName),
    );
  }

  // @override
  // void dispose() {
  //   context.read<RoomOverviewBloc>().close();
  //   super.dispose();
  // }
}

class RoomWidget extends StatelessWidget {
  final String meetingUrl;
  final String userName;

  const RoomWidget(this.meetingUrl, this.userName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YO Stream"),
      ),
      bottomSheet: TextField(
        controller: context.read<RoomOverviewBloc>().chatTextController,
        onSubmitted: (v) {
          context
              .read<RoomOverviewBloc>()
              .add(RoomOverviewSendMessage(message: v));
        },
      ),
      body: Column(
        children: [
          BlocBuilder<RoomOverviewBloc, RoomOverviewState>(
            builder: (context, state) {
              return Row(
                children: [
                  const Icon(Icons.remove_red_eye),
                  Text("${state.peerTrackNodes.length}")
                ],
              );
            },
          ),
          BlocConsumer<RoomOverviewBloc, RoomOverviewState>(
            listener: (ctx, state) {
              if (state.leaveMeeting) {
                Navigator.of(context).pushReplacement(HomePage.route());
              }
              // if (state.peerLeft != null) {
              //   ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
              //       content: Text('${state.peerLeft?.name} has left')));
              // }
              if (state.status == RoomOverviewStatus.failure) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text("Failed ${state.status}")));
              }

              if (state.peerJoined != null) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text("JOINED ${state.peerJoined}")));
              }
            },
            builder: (ctx, state) {
              return const Expanded(
                flex: 3,
                child: SizedBox(child: VideoWidget()),
              );
            },
          ),
          BlocBuilder<RoomOverviewBloc, RoomOverviewState>(
            builder: (context, state) {
              return Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  height: 150,
                  width: 400,
                  child: ListView.builder(
                      itemCount: state.hmsMessage?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Text(
                          '${state.hmsMessage?[index]?.sender?.name}: ${state.hmsMessage?[index]?.message ?? ""}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.redAccent),
                        );
                      }),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<RoomOverviewBloc, RoomOverviewState>(
        builder: (ctx, state) {
          return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black,
              selectedItemColor: Colors.grey,
              unselectedItemColor: Colors.grey,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(state.isAudioMute ? Icons.mic_off : Icons.mic),
                  label: 'Mic',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                      state.isVideoMute ? Icons.videocam_off : Icons.videocam),
                  label: 'Camera',
                ),
                //For screenshare in iOS follow the steps here : https://www.100ms.live/docs/flutter/v2/features/Screen-Share
                if (Platform.isAndroid)
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.screen_share,
                        color: (state.isScreenShareActive)
                            ? Colors.green
                            : Colors.grey,
                      ),
                      label: "ScreenShare"),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.cancel),
                  label: 'Leave Meeting',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Messages',
                ),
              ],

              //New
              onTap: (index) => _onItemTapped(index, context, state: state));
        },
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context,
      {RoomOverviewState? state}) {
    switch (index) {
      case 0:
        context
            .read<RoomOverviewBloc>()
            .add(const RoomOverviewLocalPeerAudioToggled());
        break;
      case 1:
        context
            .read<RoomOverviewBloc>()
            .add(const RoomOverviewLocalPeerVideoToggled());
        break;
      case 2:
        context
            .read<RoomOverviewBloc>()
            .add(const RoomOverviewLocalPeerScreenshareToggled());
        break;
      case 3:
        context
            .read<RoomOverviewBloc>()
            .add(const RoomOverviewLeaveRequested());
    }
  }
}

// Container(
//                   color: Colors.red.withOpacity(0.2),
//                   height: MediaQuery.of(context).size.height * 0.4,
//                   child: ListView.builder(
//                       itemCount: state.message?.length ?? 0,
//                       itemBuilder: (c, i) {
//                         return Text(
//                           '${state.message?[i]?.sender?.name ?? ""}: ${state.message?[i]?.message ?? ""} ',
//                           style: const TextStyle(
//                               fontSize: 24, fontWeight: FontWeight.w400),
//                         );
//                       }),
//                 ),
