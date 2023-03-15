
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_app/image_stream.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtthelper.dart';
import 'dart:typed_data';

var mqtt = MqttConnection(1883,
    "frFALK2MS8awiSXcQRAVaLEFoXIUQFBTX6kwGa6m96GfNuir9Gc8hEDtr9d5FFNq");
void main() {
  runApp(BlocProvider(create: (context) => ImageBloc() ,child: HomeApp()));
}

class HomeApp extends StatelessWidget {
   HomeApp({Key? key}) : super(key: key);
  
  
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ImageBloc>(context);
    bloc.add(ClickEvent());
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar:
            AppBar(title: Center(child: Text("Home Intruder Alarm System"))),
        body: StreamBuilder(
          stream: bloc.stream,
          builder:(context, snapshot) {
            if (snapshot.hasData == false) return CircularProgressIndicator();
            final state = snapshot.data!;
            return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ColorChangingButton(active: state.active, onPressed: () => bloc.add(ClickEvent()),),
                Text(
                  "On/Off",
                  style: TextStyle(fontSize: 35),
                ),
                Text("Alarm activated:",
                    style:
                        TextStyle(fontSize: 25, color: Colors.lightBlueAccent)),
                Text(state.images.length.toString()),
                Expanded(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(15),
                    itemCount: state.images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Image.memory(state.images[index]);
                      // return Image.asset(
                      //   pictureList[index],
                      //   fit: BoxFit.fill,
                      // );
                    },
                  ),
                ),
              ],
            ),
          );
          },
        ),
      ),
    );
  }
}

class ColorChangingButton extends StatelessWidget {

  final VoidCallback onPressed;
  final bool active;
  ColorChangingButton({required this.onPressed, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(35),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            fixedSize: (Size(175, 175)),
            backgroundColor: active ? Colors.green :  Colors.red,
            shape: CircleBorder()),
        child: Icon(
          Icons.power_settings_new,
          size: 115,
          color: active ? Colors.white : Colors.black54,
        ),
      ),
    );
  }
}
