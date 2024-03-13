import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

abstract class RoomOverviewEvent extends Equatable {
  const RoomOverviewEvent();

  @override
  List<Object> get props => [];
}

class RoomOverviewInit extends RoomOverviewEvent {
  const RoomOverviewInit();
}

class RoomOverviewSubscriptionRequested extends RoomOverviewEvent {
  const RoomOverviewSubscriptionRequested();
}

class RoomOverviewLocalPeerVideoToggled extends RoomOverviewEvent {
  const RoomOverviewLocalPeerVideoToggled();
}

class RoomOverviewLocalPeerScreenshareToggled extends RoomOverviewEvent {
  const RoomOverviewLocalPeerScreenshareToggled();
}

class RoomOverviewLocalPeerAudioToggled extends RoomOverviewEvent {
  const RoomOverviewLocalPeerAudioToggled();
}

class RoomOverviewLeaveRequested extends RoomOverviewEvent {
  const RoomOverviewLeaveRequested();
}

class RoomOverviewSetOffScreen extends RoomOverviewEvent {
  final int index;
  final bool setOffScreen;
  const RoomOverviewSetOffScreen(this.setOffScreen, this.index);
}

class RoomOverviewOnJoinSuccess extends RoomOverviewEvent {
  final HMSRoom hmsRoom;
  const RoomOverviewOnJoinSuccess(this.hmsRoom);
}

class RoomOverviewOnPeerLeave extends RoomOverviewEvent {
  final HMSPeer hmsPeer;
  final HMSVideoTrack hmsVideoTrack;
  const RoomOverviewOnPeerLeave(this.hmsVideoTrack, this.hmsPeer);
}

class RoomOverviewOnPeerJoin extends RoomOverviewEvent {
  final HMSPeer hmsPeer;
  final HMSVideoTrack? hmsVideoTrack;
  final HMSAudioTrack? hmsAudioTrack;
  const RoomOverviewOnPeerJoin({
    required this.hmsPeer,
    this.hmsAudioTrack,
    this.hmsVideoTrack,
  });
}

class RoomOverviewRoomOverviewOnMessageReceived extends RoomOverviewEvent {
  final HMSMessage message;

  const RoomOverviewRoomOverviewOnMessageReceived({required this.message});
}

class RoomOverviewSendMessage extends RoomOverviewEvent {
  final String message;

  const RoomOverviewSendMessage({required this.message});
}

class RoomOverViewOnPeerUpdate extends RoomOverviewEvent {
  final HMSPeer peer;

  const RoomOverViewOnPeerUpdate({required this.peer});
}
