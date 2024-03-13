import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_hundred_ms/observers/preview_observer.dart';

part 'preview_state.dart';

class PreviewCubit extends Cubit<PreviewState> {
  HMSSDK hmsSdk = HMSSDK();
  String name;
  String url;
  String? authToken;

  PreviewCubit(this.name, this.url, {this.authToken})
      : super(const PreviewState(isMicOff: false, isVideoOff: false)) {
    PreviewObserver(this);
  }

  void toggleVideo() {
    hmsSdk.toggleCameraMuteState();
    // hmsSdk.switchVideo(isOn: !state.isVideoOff);

    emit(state.copyWith(isVideoOff: !state.isVideoOff));
  }

  void toggleAudio() {
    hmsSdk.toggleMicMuteState();
    emit(state.copyWith(isMicOff: !state.isMicOff));
  }

  void updateTracks(List<HMSVideoTrack> localTracks) {
    emit(state.copyWith(tracks: localTracks));
  }

}
