import 'dart:async';
import 'dart:typed_data';

class IntruderImageStream{
  static StreamController<Uint8List> _controller = StreamController();

  static Stream<Uint8List> getStream() {
    return _controller.stream;
  }

  static addImage(Uint8List image) {
    _controller.sink.add(image);
  }
}