import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object> get props => [];
}

class RoomInit extends RoomEvent {
  final bool isBroadCaster;

  const RoomInit({required this.isBroadCaster});
}

class RoomSubscriptionRequested extends RoomEvent {}

class RoomLocalPeerVideoToggled extends RoomEvent {
  final bool isVideoOn;
  const RoomLocalPeerVideoToggled({required this.isVideoOn});
}

class RoomLocalPeerScreenshareToggled extends RoomEvent {
  const RoomLocalPeerScreenshareToggled();
}

class RoomLocalPeerAudioToggled extends RoomEvent {
  final bool isMute;

  const RoomLocalPeerAudioToggled({required this.isMute});
}

class RoomLeaveRequested extends RoomEvent {
  const RoomLeaveRequested();
}

// class RoomSetOffScreen extends RoomEvent {
//   final int index;
//   final bool setOffScreen;
//   const RoomSetOffScreen(this.setOffScreen, this.index);
// }

class RoomOnJoinSuccess extends RoomEvent {
  final HMSRoom hmsRoom;
  const RoomOnJoinSuccess(this.hmsRoom);
}

class RoomOnPeerLeave extends RoomEvent {
  final HMSPeer hmsPeer;
  final HMSVideoTrack hmsVideoTrack;
  const RoomOnPeerLeave(this.hmsVideoTrack, this.hmsPeer);
}

class RoomOnPeerJoin extends RoomEvent {
  final HMSPeer hmsPeer;
  final HMSVideoTrack? hmsVideoTrack;
  final HMSAudioTrack? hmsAudioTrack;
  const RoomOnPeerJoin({
    required this.hmsPeer,
    this.hmsAudioTrack,
    this.hmsVideoTrack,
  });
}

class RoomOnMessageReceived extends RoomEvent {
  final HMSMessage message;

  const RoomOnMessageReceived({required this.message});
}

class RoomSendMessage extends RoomEvent {
  final String message;

  const RoomSendMessage({required this.message});
}

class RoomOnPeerUpdate extends RoomEvent {
  final HMSPeer peer;
  final HMSPeerUpdate update;

  const RoomOnPeerUpdate({required this.peer, required this.update});
}
