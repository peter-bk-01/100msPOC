import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_hundred_ms/bloc/room/room_bloc.dart';
import 'package:video_hundred_ms/bloc/room/room_event.dart';
import 'package:video_hundred_ms/bloc/room/room_state.dart';
import 'package:video_hundred_ms/views/video_page.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.isBroadCaster});

  final bool isBroadCaster;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RoomBloc()..add(RoomInit(isBroadCaster: widget.isBroadCaster)),
      child: RoomBuilderWidget(
        isBroadCaster: widget.isBroadCaster,
      ),
    );
  }
}

class RoomBuilderWidget extends StatelessWidget {
  const RoomBuilderWidget({super.key, required this.isBroadCaster});

  final bool isBroadCaster;

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF2ABFF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YO Stream"),
      ),
      floatingActionButton: BlocBuilder<RoomBloc, RoomState>(
        buildWhen: (previous, current) => current is RoomControllerState,
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: () {
              context.read<RoomBloc>().add(RoomLocalPeerAudioToggled(
                  isMute: state is RoomControllerState
                      ? state.isAudioMute!
                      : false));
            },
            child: Icon(
              state is RoomControllerState
                  ? state.isAudioMute!
                      ? Icons.mic_off
                      : Icons.mic
                  : Icons.mic,
            ),
          );
        },
      ),
      bottomSheet: TextField(
        controller: context.read<RoomBloc>().chatTextController,
        onSubmitted: (v) {
          context.read<RoomBloc>().add(RoomSendMessage(message: v));
        },
      ),
      body: BlocListener<RoomBloc, RoomState>(
        listenWhen: (previous, current) =>
            current is RoomPeerJoined || current is RoomPeerLeft,
        listener: (context, state) {
          // if (state is RoomPeerJoined) {
          //   _showSnackbar(context, "${state.peer.name} Joined");
          // }
          if (state is RoomPeerLeft) {
            _showSnackbar(context, "${state.peer.name} Left");
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: BlocBuilder<RoomBloc, RoomState>(
                buildWhen: (previous, current) =>
                    current is RoomPeerTrackNodeUpdated,
                builder: (context, state) {
                  return Row(
                    children: [
                      const Icon(Icons.remove_red_eye),
                      Text(state is RoomPeerTrackNodeUpdated
                          ? state.peerTrackNodes.length.toString()
                          : "Room not loaded"),
                    ],
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<RoomBloc, RoomState>(
                builder: (ctx, state) {
                  return state is RoomLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          child: VideoPage(
                          isBroadCaster: isBroadCaster,
                        ));
                },
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<RoomBloc, RoomState>(
                buildWhen: (previous, current) =>
                    current is RoomMessageReceived,
                builder: (context, state) {
                  return state is RoomMessageReceived
                      ? Container(
                          decoration:
                              const BoxDecoration(color: Colors.transparent),
                          height: 150,
                          width: 400,
                          child: ListView.builder(
                              controller:
                                  context.read<RoomBloc>().chatListController,
                              itemCount: state.hmsMessage?.length ?? 0,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${state.hmsMessage?[index]?.sender?.name == "kkkk" ? 's' : 'sq'}: ${state.hmsMessage?[index]?.message ?? ""}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.redAccent),
                                  ),
                                );
                              }),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
