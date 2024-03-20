import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_hundred_ms/bloc/room/p_track_node.dart';

abstract class RoomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {}

class RoomFailure extends RoomState {
  final String message;

  RoomFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class RoomPeerJoined extends RoomState {
  final HMSPeer peer;

  RoomPeerJoined({required this.peer});

  @override
  List<Object?> get props => [peer];
}

class RoomPeerLeft extends RoomState {
  final HMSPeer peer;

  RoomPeerLeft({required this.peer});

  @override
  List<Object?> get props => [peer];
}

class RoomControllerState extends RoomState {
  final bool? isAudioMute;
  final bool? isVideoMute;

  RoomControllerState({
    this.isAudioMute = false,
    this.isVideoMute = false,
  });

  @override
  List<Object?> get props => [isAudioMute, isVideoMute];
}

class RoomMessageReceived extends RoomState {
  final List<HMSMessage?>? hmsMessage;

  RoomMessageReceived({required this.hmsMessage});

  @override
  List<Object?> get props => [hmsMessage];
}

class RoomLeaveMeeting extends RoomState {
  final bool leaveMeeting;

  RoomLeaveMeeting({required this.leaveMeeting});

  @override
  List<Object?> get props => [leaveMeeting];
}


/// This state is used to update the peer track nodes in the room
class RoomPeerTrackNodeUpdated extends RoomState {
  final List<PTrackNode> peerTrackNodes;

  RoomPeerTrackNodeUpdated({required this.peerTrackNodes});

  @override
  List<Object?> get props => [peerTrackNodes];
}
