import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_hundred_ms/bloc/room/p_track_node.dart';
import 'package:video_hundred_ms/bloc/room/room_event.dart';
import 'package:video_hundred_ms/bloc/room/room_state.dart';
import 'package:video_hundred_ms/observers/room_listener.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  late RoomListener roomListener;
  RoomBloc() : super(RoomInitial()) {
    roomListener = RoomListener(this);
    on<RoomInit>((event, emit) => _init(event, emit));
    on<RoomSubscriptionRequested>(
        (event, emit) => _onSubscription(event, emit));
    on<RoomOnPeerJoin>((event, emit) => _onPeerJoin(event, emit));
    on<RoomOnPeerUpdate>((event, emit) => _onPeerUpdate(event, emit));
    on<RoomLocalPeerAudioToggled>((event, emit) => _onLocalMute(event, emit));
    on<RoomLocalPeerVideoToggled>((event, emit) => _onLocalVideoToggled(event, emit));
    on<RoomSendMessage>((event, emit) => _onSendMessage(event, emit));
    on<RoomOnMessageReceived>((event, emit) => _onMessageReceived(event, emit));
  }

  void _init(RoomInit event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    hmsSdk.destroy();
    await hmsSdk.build(); // ensure to await while invoking the `build` method
    hmsSdk.addUpdateListener(listener: roomListener);
    await getToken(event.isBroadCaster);
    emit(RoomLoaded());
    add(RoomSubscriptionRequested());
  }

  Future<void> getToken(bool isBroadCaster) async {
    var res = await hmsSdk.getAuthTokenByRoomCode(
        roomCode: isBroadCaster ? roomCodeForBroadCaster : roomCodeForListener,
        userId: "${DateTime.now().millisecondsSinceEpoch}");
    log(res);
    HMSConfig config = HMSConfig(
        authToken: res,
        userName: isBroadCaster ? broadcasterName : listenerName);
    hmsSdk.join(config: config);
  }

  void _onSubscription(
      RoomSubscriptionRequested event, Emitter<RoomState> emit) async {
    await emit.forEach<List<PTrackNode>>(
      roomListener.getTracks(),
      onData: (tracks) {
        return RoomPeerTrackNodeUpdated(peerTrackNodes: tracks);
      },
      onError: (_, __) => RoomFailure(message: "Error"),
    );
  }

  Future<void> _onPeerJoin(
      RoomOnPeerJoin event, Emitter<RoomState> emit) async {
    await roomListener.addPeer(event.hmsVideoTrack, event.hmsPeer);
    // emit(RoomPeerJoined(peer: event.hmsPeer));
  }

  Future<void> _onPeerUpdate(
      RoomOnPeerUpdate event, Emitter<RoomState> emit) async {
    if (event.update == HMSPeerUpdate.peerJoined) {
      emit(RoomPeerJoined(peer: event.peer));
    }
    if (event.update == HMSPeerUpdate.peerLeft) {
      emit(RoomPeerLeft(peer: event.peer));
    }
  }

  void _onLocalMute(
      RoomLocalPeerAudioToggled event, Emitter<RoomState> emit) async {
    await hmsSdk.toggleMicMuteState();
    var value = await hmsSdk.isAudioMute();
    log(value.toString());
    emit(RoomControllerState(isAudioMute: value));
  }
  void _onLocalVideoToggled(
      RoomLocalPeerVideoToggled event, Emitter<RoomState> emit) async {
    await hmsSdk.toggleCameraMuteState();
    var value = await hmsSdk.isVideoMute();
    log(value.toString());
    emit(RoomControllerState(isVideoMute: value));
  }

  Future<void> _onSendMessage(
      RoomSendMessage event, Emitter<RoomState> emit) async {
    await hmsSdk.sendBroadcastMessage(
        message: event.message,
        type: "chat",
        hmsActionResultListener: roomListener);

    chatListController.animateTo(
        chatListController.position.maxScrollExtent + 40,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
    chatTextController.clear();
  }

  void _onMessageReceived(
      RoomOnMessageReceived event, Emitter<RoomState> emit) {
    message.add(event.message);
    List<HMSMessage> updatedMessageList = List.from(message);

    emit(RoomMessageReceived(hmsMessage: updatedMessageList));
    chatListController.animateTo(
        chatListController.position.maxScrollExtent + 40,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

  HMSSDK hmsSdk = HMSSDK();
  String roomCodeForBroadCaster = "twj-tzbr-jqj";
  String roomCodeForListener = "jpk-acvg-hak";
  String broadcasterName = "User 1";
  String listenerName = "Listener 1";
  TextEditingController chatTextController = TextEditingController();
  ScrollController chatListController = ScrollController();

  List<HMSMessage> message = [];

  @override
  Future<void> close() async {
    await hmsSdk.leave();

    hmsSdk.destroy();
    hmsSdk.removeUpdateListener(listener: roomListener);

    return super.close();
  }
}
