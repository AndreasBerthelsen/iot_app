import 'dart:async';
import 'dart:typed_data';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'mqtthelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


enum Status {
  connecting,
  connected,
  listening,
  disconnecting,
  disconnected,
}

class AppState {
  final Status status;
  final bool active;
  final List<Uint8List> images;
  final int maxLength;

  AppState({
    required this.status,
    required this.active,
    required this.images,
    required this.maxLength,
  });

  factory AppState.initial({int maxLength = 50}) {
    return AppState(
      active: false,
      status: Status.disconnected,
      images: [],
      maxLength: maxLength,
    );
  }

  copyWith({Status? status, bool? activated, Uint8List? image}) {
    return AppState(
        status: status ?? this.status,
        active: activated ?? this.active,
        images:
        image == null ? images : [image, ...images.take(maxLength)],
        maxLength: maxLength);
  }
}

@immutable
abstract class AppEvent{}

class Active extends AppEvent{
  final bool active;
  Active(this.active);
}

class Connected extends AppEvent {}

class Disconnected extends AppEvent {}

class Subscribed extends AppEvent {
  final String topic;

  Subscribed(this.topic);
}

class Pong extends AppEvent {}

class ImageTheif extends AppEvent {
  final Uint8List image;

  ImageTheif(this.image);
}


class MqttBloc extends Bloc<AppEvent, AppState> {
  late MqttSubscriber _subscriber;

  StreamSubscription<MqttUpdates>? _updatesSubscription;

  MqttBloc(
      {required String server, required String clientIdentifier, int? port})
      : super(AppState.initial()) {
    final client = MqttServerClient(server, clientIdentifier);
    if (port != null) {
      client.port = port;
    }

    _subscriber =
        MqttSubscriber(client: client, topic: 'Picture', onEvent: add);

    on<Active>((event, emit) {
      if (event.active) {
        emit(state.copyWith(
            status: Status.connecting, activated: event.active));
        _subscriber.connect();
      } else {
        emit(state.copyWith(
            status: Status.disconnecting, activated: event.active));
        _subscriber.disconnect();
      }
    });

    on<Connected>((event, emit) {
      emit(state.copyWith(status: Status.connected));
    });

    on<Disconnected>((event, emit) async {
      emit(state.copyWith(status: Status.disconnected));
      await _updatesSubscription?.cancel();
      _updatesSubscription = null;
    });

    on<Subscribed>((event, emit) {
      emit(state.copyWith(status: Status.listening));
    });

    on<Pong>(
          (event, emit) => print(event.toString()),
    );

    on<ImageTheif>((event, emit) {
      emit(state.copyWith(image: event.image));
    });
  }

  @override
  close() async {
    _subscriber.disconnect();
    super.close();
  }
}