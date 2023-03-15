import 'dart:async';
import 'dart:typed_data';
import 'mqtthelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

var mqtt = MqttConnection(1883,
    "frFALK2MS8awiSXcQRAVaLEFoXIUQFBTX6kwGa6m96GfNuir9Gc8hEDtr9d5FFNq");
StreamSubscription<Uint8List>? _subscription;


@immutable
class AppState {
  final bool active;
  final List<Uint8List> images;

  AppState(this.active, this.images);
}

@immutable
abstract class AppEvent{}

class ClickEvent extends AppEvent{}

class IntruderImageStream{
  static StreamController<Uint8List> _controller = StreamController();

  static Stream<Uint8List> getStream() {
    return _controller.stream;
  }

  static addImage(Uint8List image) {
    _controller.sink.add(image);
  }
}

class ImageBloc extends Bloc<AppEvent, AppState>{

  ImageBloc() : super(AppState(false, [])){
  on<ClickEvent>((event, emit) {
    if (event is ClickEvent && state.active == false){
        subscribe(mqtt);
        emit(AppState(true, state.images));
        mqtt.listen((image) {
          emit(AppState(true, [...state.images.take(50), image]));
        });
    } else if (event is ClickEvent && state.active == true) {
      unsubscribe(mqtt);
      emit(AppState(false, state.images));
    }
  });
  }
}