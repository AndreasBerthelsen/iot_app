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
  mqtt.connect();
}

class HomeApp extends StatefulWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  List<Uint8List> pictureList = [];
  StreamSubscription<Uint8List>? _subscription;

  @override
  void initState() {
    // TODO: implement initState
    mqtt.callback();
    _subscription = IntruderImageStream.getStream().listen((event) {
      pictureList.add(event);
      setState(() {});
    });
    print("LOOK HERE MAN LOOK" + pictureList.length.toString());
    super.initState();
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
              ColorChangingButton(),
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

  ColorChangingButton();
}

class _ColorChangingButtonState extends State<ColorChangingButton> {
  Color _buttonColor = Colors.red; // initial button color is red
  Color _iconColor = Colors.black54;

   void _changeColor() {
    setState(() {
      if (_buttonColor == Colors.red) {
        _buttonColor = Colors.green;
        _iconColor = Colors.white;
        mqtt.subscribe("Picture");
      } else {
        _buttonColor = Colors.red;
        _iconColor = Colors.black54;
        mqtt.unsubscribe("Picture");
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
