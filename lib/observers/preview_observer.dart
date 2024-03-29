import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_hundred_ms/bloc/preview/preview_cubit.dart';
import 'package:video_hundred_ms/services/RoomService.dart';

class PreviewObserver implements HMSPreviewListener {
  PreviewCubit previewCubit;

  List<HMSVideoTrack> localTracks = <HMSVideoTrack>[];

  PreviewObserver(this.previewCubit) {
    // previewCubit.hmsSdk.destroy();

    previewCubit.hmsSdk.addPreviewListener(listener: this);
    previewCubit.hmsSdk.build();
    if (previewCubit.authToken == null) {
      RoomService()
          .getToken(user: previewCubit.name, room: previewCubit.url)
          .then((token) {
        if (token == null) return;
        if (token[0] == null) return;

        HMSConfig config = HMSConfig(
          authToken: token[0]!,
          userName: previewCubit.name,
        );

        previewCubit.hmsSdk.preview(config: config);
      });
    } else {
      getToken();
      // previewCubit.hmsSdk
      //     .getAuthTokenByRoomCode(roomCode: "jpk-acvg-hak")
      //     .then((value) {

      // });
      //    HMSConfig config =
      //     HMSConfig(authToken: res, userName: 'John Appleseed');
      // previewCubit.hmsSdk.preview(config: config);
    }
  }

  Future<void> getToken() async {
    var res = await previewCubit.hmsSdk
        .getAuthTokenByRoomCode(roomCode: "jpk-acvg-hak", userId: "peter");
    log(res);
    HMSConfig config = HMSConfig(authToken: res, userName: 'John Appleseed');
    previewCubit.hmsSdk.preview(config: config);
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    // TODO: implement onPeerUpdate
  }

  @override
  void onPreview({required HMSRoom room, required List<HMSTrack> localTracks}) {
    List<HMSVideoTrack> videoTracks = [];
    for (var track in localTracks) {
      if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
        videoTracks.add(track as HMSVideoTrack);
      }
    }
    this.localTracks.clear();
    this.localTracks.addAll(videoTracks);
    previewCubit.updateTracks(this.localTracks);
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    // TODO: implement onRoomUpdate
  }

  @override
  void onHMSError({required HMSException error}) {
    if (kDebugMode) {
      print("OnError ${error.message}");
    }
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {
    // TODO: implement onAudioDeviceChanged
  }
}
