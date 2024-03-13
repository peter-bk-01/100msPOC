import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_hundred_ms/bloc/room/peer_track_node.dart';
import 'package:video_hundred_ms/bloc/room/room_overview_event.dart';
import 'package:video_hundred_ms/bloc/room/room_overview_state.dart';
import 'package:video_hundred_ms/observers/room_observer.dart';

class RoomOverviewBloc extends Bloc<RoomOverviewEvent, RoomOverviewState> {
  final bool isVideoMute;
  final bool isAudioMute;
  final bool isScreenShareActive;
  final HMSSDK hmsSdk;
  String name;
  String url;
  String? roomCode;
  late RoomObserver roomObserver;

  RoomOverviewBloc(this.isVideoMute, this.isAudioMute, this.name, this.url,
      this.isScreenShareActive, this.roomCode, this.hmsSdk)
      : super(RoomOverviewState(
            isAudioMute: isAudioMute,
            isVideoMute: isVideoMute,
            isScreenShareActive: isScreenShareActive)) {
    roomObserver = RoomObserver(this);
    _init();
    on<RoomOverviewSubscriptionRequested>(_onSubscription);
    on<RoomOverviewLocalPeerAudioToggled>(_onLocalAudioToggled);
    on<RoomOverviewLocalPeerVideoToggled>(_onLocalVideoToggled);
    on<RoomOverviewLocalPeerScreenshareToggled>(_onScreenShareToggled);
    on<RoomOverviewOnJoinSuccess>(_onJoinSuccess);
    on<RoomOverviewOnPeerLeave>(_onPeerLeave);
    on<RoomOverviewOnPeerJoin>(_onPeerJoin);
    on<RoomOverviewLeaveRequested>(_leaveRequested);
    on<RoomOverviewSetOffScreen>(_setOffScreen);
    on<RoomOverviewRoomOverviewOnMessageReceived>(_onMessageReceived);
    on<RoomOverviewSendMessage>(_sendBroadcastMessage);
  }

  List<HMSMessage> messageList = [];
  TextEditingController chatTextController = TextEditingController();

  _init() async {
    hmsSdk.destroy();
    await hmsSdk.build();
    hmsSdk.addUpdateListener(listener: roomObserver);
    await getToken();
  }

  Future<void> getToken() async {
    var res = await hmsSdk.getAuthTokenByRoomCode(
        roomCode: roomCode ?? "",
        userId: "${DateTime.now().millisecondsSinceEpoch}");
    log(res);
    HMSConfig config = HMSConfig(authToken: res, userName: name);
    hmsSdk.join(config: config);
  }

  Future<void> _onSubscription(RoomOverviewSubscriptionRequested event,
      Emitter<RoomOverviewState> emit) async {
    await Future.delayed(const Duration(seconds: 1));
    messageList.clear();
    await emit.forEach<List<PeerTrackNode>>(
      roomObserver.getTracks(),
      onData: (tracks) {
        return state.copyWith(
            status: RoomOverviewStatus.success, peerTrackNodes: tracks);
      },
      onError: (_, __) => state.copyWith(
        status: RoomOverviewStatus.failure,
      ),
    );
  }

  Future<void> _onLocalVideoToggled(RoomOverviewLocalPeerVideoToggled event,
      Emitter<RoomOverviewState> emit) async {
    hmsSdk.switchVideo(isOn: !state.isVideoMute);
    emit(state.copyWith(isVideoMute: !state.isVideoMute));
  }

  void _onScreenShareToggled(RoomOverviewLocalPeerScreenshareToggled event,
      Emitter<RoomOverviewState> emit) async {
    if (!state.isScreenShareActive) {
      hmsSdk.startScreenShare();
    } else {
      hmsSdk.stopScreenShare();
    }
    emit(state.copyWith(isScreenShareActive: !state.isScreenShareActive));
  }

  Future<void> _onLocalAudioToggled(RoomOverviewLocalPeerAudioToggled event,
      Emitter<RoomOverviewState> emit) async {
    hmsSdk.switchAudio(isOn: !state.isAudioMute);
    emit(state.copyWith(isAudioMute: !state.isAudioMute));
  }

  Future<void> _onJoinSuccess(
      RoomOverviewOnJoinSuccess event, Emitter<RoomOverviewState> emit) async {
    if (state.isAudioMute) {
      hmsSdk.switchAudio(isOn: state.isAudioMute);
    }

    if (state.isVideoMute) {
      hmsSdk.switchVideo(isOn: state.isVideoMute);
    }
  }

  Future<void> _onPeerLeave(
      RoomOverviewOnPeerLeave event, Emitter<RoomOverviewState> emit) async {
    await roomObserver.deletePeer(event.hmsPeer.peerId);
    emit(state.copyWith(peerLeft: event.hmsPeer));
    state.copyWith(peerLeft: null);
  }

  Future<void> _onPeerJoin(
      RoomOverviewOnPeerJoin event, Emitter<RoomOverviewState> emit) async {
    await roomObserver.addPeer(event.hmsVideoTrack!, event.hmsPeer,
        hmsAudioTrack: event.hmsAudioTrack);
  }

  Future<void> _leaveRequested(
      RoomOverviewLeaveRequested event, Emitter<RoomOverviewState> emit) async {
    await roomObserver.leaveMeeting();
    emit(state.copyWith(leaveMeeting: true));
  }

  Future<void> _setOffScreen(
      RoomOverviewSetOffScreen event, Emitter<RoomOverviewState> emit) async {
    await roomObserver.setOffScreen(event.index, event.setOffScreen);
  }

  void _onMessageReceived(RoomOverviewRoomOverviewOnMessageReceived event,
      Emitter<RoomOverviewState> emit) {
    messageList.add(event.message);
    List<HMSMessage> updatedMessageList = List.from(messageList);

    emit(state.copyWith(hmsMessage: updatedMessageList));
  }

  void _sendBroadcastMessage(
      RoomOverviewSendMessage event, Emitter<RoomOverviewState> emit) async {
    ///[message]: Message to be sent
    ///[type]: Message type(More about this at the end)
    ///[hmsActionResultListener]: instance of class implementing HMSActionResultListener
    //Here this is an instance of class that implements HMSActionResultListener, that is, Meeting
    await hmsSdk.sendBroadcastMessage(
        message: event.message,
        type: "chat",
        hmsActionResultListener: roomObserver);
    chatTextController.clear();
  }

  @override
  Future<void> close() async {
    await hmsSdk.leave();
    hmsSdk.removeUpdateListener(listener: roomObserver);
    hmsSdk.destroy();

    return super.close();
  }
}
