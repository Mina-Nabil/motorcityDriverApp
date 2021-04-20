import 'package:firebase_core/firebase_core.dart';

import './models/notification_handler.dart';
import 'package:motorcity/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:motorcity/providers/cars_model.dart';
import 'package:motorcity/screens/home.dart';
import 'package:location_permissions/location_permissions.dart';

Future<void> main() async {
  runApp(ChangeNotifierProvider(
    create: (context) => CarsModel(),
    child: MotorCityApp(),
  ));
  PermissionStatus permission = await LocationPermissions().requestPermissions();

  if (permission != PermissionStatus.granted) {
    ///error
  }
}

class MotorCityApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MotorCityAppState();
  }
}

class _MotorCityAppState extends State<MotorCityApp> {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    super.initState();
    new FirebaseNotifications().setUpFirebase(this.context);
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
              initialRoute: '/',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'NotoSerif',
                primaryColor: Color.fromRGBO(0, 46, 72, 1),
                accentColor: Color.fromRGBO(0, 46, 72, 0.5),
              ),
              routes: {'/login': (context) => LoginPage(), '/home': (context) => HomePage()},
              home: LandingPage());
        }
        return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Provider.of<CarsModel>(context).checkIfAuthenticated().then((success) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ));
  }
}
