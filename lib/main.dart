import 'package:backgroundcolorapp/libraries/convert_mediaQuery.dart';
import 'package:backgroundcolorapp/models/stream_socket.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSocket streamSocket = StreamSocket();
  IO.Socket socket;

  @override
  void initState() {
    super.initState();
    connectAndListen();
    streamSocket.getResponse.listen((newColor) {
      //print(newColor);
      setState(() {
        bgColor = newColor;
      });
    });
  }

  void connectAndListen() {
    socket = IO.io('https://background-color-app.herokuapp.com',
        IO.OptionBuilder().setTransports(['websocket']).build());

    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });

    //When an event recieved from server, data is added to the stream
    socket.on('new color', (data) {
      //print(data);
      streamSocket.addResponse(data);
    });
    socket.onDisconnect((_) => print('disconnect'));
  }

  void emitColor(color) {
    socket.emit("color change", color);
  }

  List<String> colors = [
    'white',
    'blue',
    'red',
    'dark red',
    'yellow',
    'purple'
  ];
  String bgColor = 'white';

  List<BoxShadow> customShadow = [
    BoxShadow(
        color: Colors.white.withOpacity(0.5),
        spreadRadius: -5,
        offset: Offset(-5, -5),
        blurRadius: 30),
    BoxShadow(
        color: Colors.blue[900].withOpacity(0.2),
        spreadRadius: 2,
        offset: Offset(7, 7),
        blurRadius: 20)
  ];

  Widget textField(BuildContext context, String title, double width) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical:
              ConvertToMediaQuery().convertHeightToMediaQuery(10, context)),
      width: ConvertToMediaQuery().convertWidthToMediaQuery(width, context),
      decoration: BoxDecoration(
        boxShadow: customShadow,
      ),
      child: TextField(
        onChanged: (value) {
          for (var color in colors) {
            if (value == color) {
              emitColor(color);
            }
          }
        },
        decoration: InputDecoration(
          hintText: title,
          border: new OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Color selectedColor() {
    if (bgColor == colors[0]) {
      return Colors.white;
    } else if (bgColor == colors[1]) {
      return Colors.blue;
    } else if (bgColor == colors[2]) {
      return Colors.red;
    } else if (bgColor == colors[3]) {
      return Colors.red[900];
    } else if (bgColor == colors[4]) {
      return Colors.yellow;
    } else {
      return Colors.purple;
    }
  }

  @override
  void dispose() {
    streamSocket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: selectedColor(),
        child: Center(
          child: textField(context, "enter color", 250),
        ),
      ),
    );
  }
}
