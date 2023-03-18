import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_app/image_stream.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Home Intruder Alarm System",
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const HomeApp(title: "Home Intruder Alert System"),
    );
  }
}

class HomeApp extends StatelessWidget {
  const HomeApp({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text(title)),
        ),
        body: BlocProvider(
          create: (context) => MqttBloc(
            server: 'mqtt.flespi.io',
            clientIdentifier:
                '',
            port: 1883,
          ),
          child: ImageWidget(),
        ));
  }
}

class ImageWidget extends StatelessWidget {
  ImageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<MqttBloc>(context);
    return BlocBuilder<MqttBloc, AppState>(
      builder: (context, state) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ColorChangingButton(
              active: state.active,
              onPressed: () => bloc.add(Active(state.active)),
            ),
            Text(
              "On/Off",
              style: TextStyle(fontSize: 35),
            ),
            Text("Alarm activated:",
                style: TextStyle(fontSize: 25, color: Colors.lightBlueAccent)),
            Text(state.images.length.toString()),
            Expanded(
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(15),
                  itemCount: state.images.length,
                  itemBuilder: _buildImageTile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(context, index) {
    final bloc = BlocProvider.of<MqttBloc>(context);
    final image = bloc.state.images[index];
    return Image.memory(image);
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
            backgroundColor: active ? Colors.green : Colors.red,
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
