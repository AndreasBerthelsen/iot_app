import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'image_stream.dart';


Future<void> subscribe(MqttConnection con) async{
  if(await con.connect()){
    con.subscribe("Picture");
  }
}
Future<void> unsubscribe(MqttConnection con) async{
  if(await con.connect()){
    con.unsubscribe("Picture");
  }
}

class MqttConnection {
  final int _port;
  final String _token;
  final MqttServerClient _client = MqttServerClient("mqtt.flespi.io","");
  String lastMessage ="";

  MqttConnection(this._port, this._token);

  Future<bool> connect() async {
    _client.port = _port;
    _client.logging(on: true);
    _client.keepAlivePeriod = 30;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('myClient')
        .withWillTopic('willtopic')
        .withWillMessage('My client disconnected')
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs(_token, "")
        .startClean();

    _client.connectionMessage = connMess;

    try {
      await _client.connect();
      return true;
    } catch (e) {
      print('Connection failed - $e');
      _client.disconnect();
      return false;
    }
  }

void disconnect(){
    _client.disconnect();
}

  void callback()
  {
    print("-- YOU GOT A MESSAGE NOTIFICATION --");
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      print("HERE!!!!!!!!!!!!!!!!!!!!");
      print(c);
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print("HERE------------------------------------------");
      final payload = base64Decode(pt);
      IntruderImageStream.addImage(payload);
      // lastMessage = payload;
      // print("-- YOU GOT A MESSAGE: " + lastMessage + " --");
    });
  }
void subscribe(String topic){
    _client.subscribe(topic, MqttQos.atLeastOnce);
}

void unsubscribe(String topic){
 _client.unsubscribe(topic);
}
}