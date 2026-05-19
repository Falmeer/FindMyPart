import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import '../constants/app_constants.dart';

/// Manages a single WebSocket subscription to a public Reverb channel.
/// Create one per screen, call [connect] in initState, [dispose] in dispose.
class ReverbPublicChannel {
  PusherChannelsClient? _client;
  PublicChannel? _channel;
  StreamSubscription? _connectionSub;
  StreamSubscription? _eventSub;

  void connect({
    required String channelName,
    required String eventName,
    required void Function(Map<String, dynamic> data) onEvent,
  }) {
    final options = PusherChannelsOptions.fromHost(
      scheme: 'ws',
      host: AppConstants.reverbHost,
      key: AppConstants.reverbKey,
      port: AppConstants.reverbPort,
    );

    _client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (_, __, refresh) {
        Future.delayed(const Duration(seconds: 5), refresh);
      },
    );

    _channel = _client!.publicChannel(channelName);

    _connectionSub = _client!.onConnectionEstablished.listen((_) {
      _channel!.subscribeIfNotUnsubscribed();
    });

    _eventSub = _channel!.bind(eventName).listen((event) {
      try {
        final data = jsonDecode(event.data as String) as Map<String, dynamic>;
        onEvent(data);
      } catch (_) {}
    });

    unawaited(_client!.connect());
  }

  void dispose() {
    _eventSub?.cancel();
    _connectionSub?.cancel();
    _channel?.unsubscribe();
    _client?.dispose();
  }
}
