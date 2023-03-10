import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iot_app/image_stream.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtthelper.dart';
import 'dart:typed_data';

var mqtt = MqttConnection(1883,
    "frFALK2MS8awiSXcQRAVaLEFoXIUQFBTX6kwGa6m96GfNuir9Gc8hEDtr9d5FFNq");
void main() {
  runApp(HomeApp());
}

class HomeApp extends StatefulWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  List<Uint8List> pictureList = [];
  bool isTurned = true;
  StreamSubscription<Uint8List>? _subscription;

  toggleStream() {

    _subscription = IntruderImageStream.getStream().listen((event) {
      pictureList.add(event);
      setState(() {
        if(isTurned == true){
          subscribe(mqtt);
          mqtt.callback();
        }
        else{
          unsubscribe(mqtt);
          mqtt.callback();
        }

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar:
            AppBar(title: Center(child: Text("Home Intruder Alarm System"))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ColorChangingButton(start: () {isTurned = true;}, stop: () { isTurned = false; },),
              Text(
                "On/Off",
                style: TextStyle(fontSize: 35),
              ),
              Text("Alarm activated:",
                  style:
                      TextStyle(fontSize: 25, color: Colors.lightBlueAccent)),
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(15),
                  itemCount: pictureList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Image.memory(pictureList[index]);
                    // return Image.asset(
                    //   pictureList[index],
                    //   fit: BoxFit.fill,
                    // );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorChangingButton extends StatefulWidget {


  @override
  _ColorChangingButtonState createState() => _ColorChangingButtonState();

  VoidCallback start;
  VoidCallback stop;
  ColorChangingButton({required this.start, required this.stop});
}

class _ColorChangingButtonState extends State<ColorChangingButton> {
  Color _buttonColor = Colors.red; // initial button color is red
  Color _iconColor = Colors.black54;

   void _changeColor() {
    setState(() {
      if (_buttonColor == Colors.red) {
        _buttonColor = Colors.green;
        _iconColor = Colors.white;
      } else {
        _buttonColor = Colors.red;
        _iconColor = Colors.black54;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(35),
      child: ElevatedButton(
        onPressed: () {
          _changeColor();
         setState(() {

         });
        },
        style: ElevatedButton.styleFrom(
            fixedSize: (Size(175, 175)),
            backgroundColor: _buttonColor,
            shape: CircleBorder()),
        child: Icon(
          Icons.power_settings_new,
          size: 115,
          color: _iconColor,
        ),
      ),
    );
  }
}
