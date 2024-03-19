import 'dart:developer';

import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:rxdart/subjects.dart';
import 'package:video_hundred_ms/bloc/room/p_track_node.dart';
import 'package:video_hundred_ms/bloc/room/room_bloc.dart';
import 'package:video_hundred_ms/bloc/room/room_event.dart';

class RoomListener implements HMSUpdateListener, HMSActionResultListener {
  RoomBloc roomBloc;

  RoomListener(this.roomBloc);

  final _peerNodeStreamController =
      BehaviorSubject<List<PTrackNode>>.seeded(const []);

  Stream<List<PTrackNode>> getTracks() =>
      _peerNodeStreamController.asBroadcastStream();

  Future<void> addPeer(HMSVideoTrack? hmsVideoTrack, HMSPeer peer,
      {HMSAudioTrack? hmsAudioTrack}) async {
    final tracks = [..._peerNodeStreamController.value];
    log("${tracks.length} ${peer.name} 44444447732382bhibsdisd94394594504545niwefa df################################################");
    final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == peer.peerId);
    if (todoIndex >= 0) {
      print("onTrackUpdate ${peer.name} ${hmsVideoTrack?.isMute}");
      tracks[todoIndex] = PTrackNode(
          hmsVideoTrack, hmsVideoTrack?.isMute, peer, false, hmsAudioTrack);
    } else {
      tracks.add(PTrackNode(
          hmsVideoTrack, hmsVideoTrack?.isMute, peer, false, hmsAudioTrack));
    }

    _peerNodeStreamController.add(tracks);
  }

  Future<void> deletePeer(String id) async {
    final tracks = [..._peerNodeStreamController.value];
    final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == id);
    if (todoIndex >= 0) {
      tracks.removeAt(todoIndex);
    }
    _peerNodeStreamController.add(tracks);
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onException(
      {required HMSActionResultListenerMethod methodType,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {}

  @override
  void onHMSError({required HMSException error}) {}

  @override
  void onJoin({required HMSRoom room}) {
    for (var peer in room.peers ?? []) {
      addPeer(peer.videoTrack, peer, hmsAudioTrack: peer.audioTrack);
    }

    // roomBloc.add(RoomOnPeerJoin(hmsPeer: hmsPeer));
  }

  @override
  void onMessage({required HMSMessage message}) {
    roomBloc.add(RoomOnMessageReceived(message: message));
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (update == HMSPeerUpdate.peerJoined) {
      // addPeer(peer.videoTrack, peer, hmsAudioTrack: peer.audioTrack);

      roomBloc.add(RoomOnPeerUpdate(peer: peer, update: update));
    } else if (update == HMSPeerUpdate.peerLeft) {
      deletePeer(peer.peerId);
      roomBloc.add(RoomOnPeerUpdate(peer: peer, update: update));
    }
  }

  @override
  void onReconnected() {}

  @override
  void onReconnecting() {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onSuccess(
      {required HMSActionResultListenerMethod methodType,
      Map<String, dynamic>? arguments}) {
    if (methodType == HMSActionResultListenerMethod.sendBroadcastMessage) {
      var message = HMSMessage.fromMap(arguments!);
      roomBloc.add(RoomOnMessageReceived(message: message));
    }
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        roomBloc
            .add(RoomOnPeerUpdate(peer: peer, update: HMSPeerUpdate.peerLeft));
        deletePeer(peer.peerId);
      } else if (trackUpdate == HMSTrackUpdate.trackAdded ||
          trackUpdate == HMSTrackUpdate.trackMuted ||
          trackUpdate == HMSTrackUpdate.trackUnMuted) {
        roomBloc.add(RoomOnPeerJoin(
          hmsPeer: peer,
          hmsVideoTrack: track as HMSVideoTrack,
        ));
      }
    }
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}
}
