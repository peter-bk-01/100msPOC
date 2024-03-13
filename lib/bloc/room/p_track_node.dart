import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class PTrackNode extends Equatable {
  final HMSVideoTrack? hmsVideoTrack;
  final bool? isMute;
  final HMSPeer? peer;
  final bool isOffScreen;
  final HMSAudioTrack? hmsAudioTrack;

  const PTrackNode(
      this.hmsVideoTrack, this.isMute, this.peer, this.isOffScreen, this.hmsAudioTrack);

  @override
  List<Object?> get props => [hmsVideoTrack, isMute, peer, isOffScreen, hmsAudioTrack];

  PTrackNode copyWith({
    HMSVideoTrack? hmsVideoTrack,
    bool? isMute,
    HMSPeer? peer,
    bool? isOffScreen,
    HMSAudioTrack? hmsAudioTrack,
  }) {
    return PTrackNode(
      hmsVideoTrack ?? this.hmsVideoTrack,
      isMute ?? this.isMute,
      peer ?? this.peer,
      isOffScreen ?? this.isOffScreen,
      hmsAudioTrack ?? this.hmsAudioTrack,
    );
  }
}
