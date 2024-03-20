# video_hundred_ms

A Flutter project for 100ms POC. You can find the References here

1. (https://www.100ms.live/docs/flutter/v2/quickstart/hls-quickstart)
2. (https://www.100ms.live/docs/flutter/v2/quickstart/quickstart)
3. (https://www.100ms.live/docs/flutter/v2/quickstart/audio-room-quickstart)
4. [Sample App HERE](https://github.com/100mslive/100ms-flutter/tree/main/sample%20apps/bloc)
5. [Join as broadcaster in web](https://peter-livestream-01.app.100ms.live/streaming/meeting/twj-tzbr-jqj)
6. [Join as Viewer in web](https://peter-livestream-01.app.100ms.live/streaming/meeting/jpk-acvg-hak)

## Main Files and its responsibility

### 1. Home Page
    - The initial screen where user are shown options to choose for joining the live session

### 2. Room Page
    -  Responsible for live sessions.
    - Chats
    - Mute/unMute & VideoCam on/off


### 3. Room bloc
    - Responsible for handling the ui state and Handling the HMS SDK.
    - initialiasation and Desposing of 100ms Sdk.
    - Managing states wrt the Events Fired.


### 4. Room Listener
    - The listener implementing the HMSListener from the SDK.
    - There are many overrides which handles the room activity.
    - Each function triggers new EVENTS to the Bloc.

### 5. Video Page
    - Responsible for handling the videos and showing the list of users.


### 6. Constants
    - Constants like url and room code.


## Seeding the Stream to handle the Tracks/Nodes of Users in a live session From Listener

``` dart
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
```

## PTrackNode

    - Responsible for showing the only necessary content in the UI.

## Sending Messages
When Sending we have to handle ourself to show it in the ui with the help of on success method in <b>listener.

``` dart
    @override
    void onSuccess(
        {required HMSActionResultListenerMethod methodType,
        Map<String, dynamic>? arguments}) {
        if (methodType == HMSActionResultListenerMethod.sendBroadcastMessage) {
        var message = HMSMessage.fromMap(arguments!);
        roomBloc.add(RoomOnMessageReceived(message: message));
        }
    }
```
Bloc:
``` dart
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
```
## Receiving message
<I>onMessage</I> is HMSUpdateListener method called when a new message is received

``` dart
  @override
  void onMessage({required HMSMessage message}) {
    roomBloc.add(RoomOnMessageReceived(message: message));
  }
```

### Listeners and its methods

``` dart
/// 100ms SDK provides callbacks to the client app about any change or update happening in the room after a user has joined by implementing HMSUpdateListener.
/// Implement this listener in a class where you want to perform UI Actions, update App State, etc. These updates can be used to render the video on the screen or to display other info regarding the room.
/// Depending on your use case, you'll need to implement specific methods of the Update Listener. The most common ones are onJoin, onPeerUpdate, onTrackUpdate & onHMSError.
abstract class HMSUpdateListener {

    void onJoin({required HMSRoom room});

    /// This will be called whenever there is an update on an existing peer
    /// or a new peer got added/existing peer is removed.
    ///
    /// This callback can be used to keep a track of all the peers in the room
    /// - Parameters:
    ///   - peer: the peer who joined/left or was updated
    ///   - update: the triggered update type. Should be used to perform different UI Actions
    void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update});

    /// This is called when there are updates on an existing track
    /// or a new track got added/existing track is removed
    ///
    /// This callback can be used to render the video on screen whenever a track gets added
    /// - Parameters:
    ///   - track: the track which was added, removed or updated
    ///   - trackUpdate: the triggered update type
    ///   - peer: the peer for which the track was added, removed or updated
    void onTrackUpdate(
        {required HMSTrack track,
        required HMSTrackUpdate trackUpdate,
        required HMSPeer peer});

    /// This will be called when there is an error in the system
    ///
    /// and SDK have already retried to fix the error
    /// - Parameter error: the error that occurred
    void onHMSError({required HMSException error});

    /// This is called when there is a change in any property of the Room
    ///
    /// - Parameters:
    ///   - room: the room which was joined
    ///   - update: the triggered update type. Should be used to perform different UI Actions
    void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update});

    /// This is called when there is a new broadcast message from any other peer in the room
    ///
    /// This can be used to implement chat in the room
    /// - Parameter message: the received broadcast message
    void onMessage({required HMSMessage message});

    /// This is called every 1 second with a list of active speakers
    ///
    /// ## A HMSSpeaker object contains -
    ///    - peerId: the peer identifier of HMSPeer who is speaking
    ///    - trackId: the track identifier of HMSTrack which is emitting audio
    ///    - audioLevel: a number within range 1-100 indicating the audio volume
    ///
    /// A peer who is not present in the list indicates that the peer is not speaking
    ///
    /// This can be used to highlight currently speaking peers in the room
    /// - Parameter speakers: the list of speakers
    void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers});

    /// When the network connection is lost & the SDK is trying to reconnect to the room
    void onReconnecting();

    /// When you are back in the room after the network connection was lost
    void onReconnected();

    /// This is called when someone asks for a change of role
    ///
    /// for example the admin can ask a peer to become a host from a guest.
    /// this triggers this call on the peer's app
    void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest});

    /// When someone requests for track change of your Audio, Video or an Auxiliary track like Screenshare, this event will be triggered
    /// - Parameter hmsTrackChangeRequest: request instance consisting of all the required info about track change
    void onChangeTrackStateRequest(
        {required HMSTrackChangeRequest hmsTrackChangeRequest});

    /// When someone kicks you out or when someone ends the room at that time it is triggered
    /// - Parameter hmsPeerRemovedFromPeer - it consists of info about who removed you and why.
    void onRemovedFromRoom(
        {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer});

    /// Whenever a new audio device is plugged in or audio output is changed we get the onAudioDeviceChanged update
    /// This callback is only fired on Android devices. On iOS, this callback will not be triggered.
    /// - Parameters:
    ///   - currentAudioDevice: Current audio output route
    ///   - availableAudioDevice: List of available audio output devices
    void onAudioDeviceChanged(
        {HMSAudioDevice? currentAudioDevice,
        List<HMSAudioDevice>? availableAudioDevice});

    /// Whenever a user joins a room [onSessionStoreAvailable] is fired to get an instance of [HMSSessionStore]
    /// which can be used to perform session metadata operations
    /// - Parameters:
    ///   - hmsSessionStore: An instance of HMSSessionStore which will be used to call session metadata methods
    void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore});
}


```