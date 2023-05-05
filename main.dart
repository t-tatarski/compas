import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;

// icon author <a href="https://www.flaticon.com/free-icons/pointer" title="pointer icons">Pointer icons created by Paul J. - Flaticon</a>

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
const MyApp({Key? key}) : super(key: key);

@override
State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermissions = false;

@override
void initState(){
  super.initState();
  _fetchPermissionStatus();
}

  void _fetchPermissionStatus() {
  Permission.locationWhenInUse.status.then((status) {
    if(mounted) {
      setState(() {
        _hasPermissions = (status == PermissionStatus.granted);
      });
    }
  });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            if (_hasPermissions) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          }
      ),
    )

    );
  }
  Widget _buildCompass(){
  return StreamBuilder<CompassEvent>(
    stream: FlutterCompass.events,
    builder: (context,snapshot){
      if(snapshot.hasError){
        return Text('error reading ${snapshot.error}');
      }
      if(snapshot.connectionState == ConnectionState.waiting){
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      double? direction = snapshot.data!.heading;
      if(direction==null){
        return const Center(
          child: Text('device does not have required sensors'),
        );
      }
      return Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Transform.rotate(
            angle: direction *(math.pi / 180) * -1,
              child: Image.asset('images/compass.png')),
          color: Colors.white,
        ),
      );
    },
  );
}

  Widget  _buildPermissionSheet(){
    return Center(
      child: ElevatedButton(
        child: const Text('Request permission'),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }
}
