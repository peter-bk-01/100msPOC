import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_hundred_ms/bloc/room/peer_track_node.dart';

enum RoomOverviewStatus { initial, loading, success, failure }

class RoomOverviewState extends Equatable {
  final RoomOverviewStatus status;
  final List<PeerTrackNode> peerTrackNodes;
  final bool isVideoMute;
  final bool isAudioMute;
  final bool leaveMeeting;
  final bool isScreenShareActive;
  final List<HMSMessage?>? hmsMessage;
  final HMSPeer? peerLeft;
  final HMSPeer? peerJoined;
  const RoomOverviewState(
      {this.status = RoomOverviewStatus.initial,
      this.peerTrackNodes = const [],
      this.isVideoMute = false,
      this.isAudioMute = false,
      this.leaveMeeting = false,
      this.hmsMessage,
      this.peerLeft,
      this.peerJoined,
      this.isScreenShareActive = false});

  @override
  List<Object?> get props => [
        status,
        peerTrackNodes,
        isAudioMute,
        isVideoMute,
        leaveMeeting,
        isScreenShareActive,
        hmsMessage,
        peerLeft,
      ];

  RoomOverviewState copyWith(
      {RoomOverviewStatus? status,
      List<PeerTrackNode>? peerTrackNodes,
      bool? isVideoMute,
      bool? isAudioMute,
      bool? leaveMeeting,
      bool? isScreenShareActive,
      HMSPeer? peerLeft,
      HMSPeer? peerJoined,
      List<HMSMessage?>? hmsMessage}) {
    return RoomOverviewState(
        status: status ?? this.status,
        peerTrackNodes: peerTrackNodes ?? this.peerTrackNodes,
        isVideoMute: isVideoMute ?? this.isVideoMute,
        isAudioMute: isAudioMute ?? this.isAudioMute,
        leaveMeeting: leaveMeeting ?? this.leaveMeeting,
        hmsMessage: hmsMessage ?? this.hmsMessage,
        peerLeft: peerLeft ?? this.peerLeft,
        peerJoined: peerJoined ?? this.peerJoined,
        isScreenShareActive: isScreenShareActive ?? this.isScreenShareActive);
  }
}
