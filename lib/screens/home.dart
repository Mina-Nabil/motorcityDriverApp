import 'dart:async';

import 'package:background_location/background_location.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:motorcity/screens/trucks.dart';
import 'package:motorcity/widgets/PendingCarsList.dart';
import '../providers/cars_model.dart';
import 'package:provider/provider.dart';
import './search.dart';
import 'package:fab_menu/fab_menu.dart';
import "package:shared_preferences/shared_preferences.dart";
import "./settings.dart";

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static Future<Null> _refreshPage(context) async {
    try {
      await Provider.of<CarsModel>(context).loadCars(force: true);

      await Provider.of<CarsModel>(context).loadTruckRequests(force: true);
      await Provider.of<CarsModel>(context).loadInventory(force: true);
      await Provider.of<CarsModel>(context).loadLocations(force: true);
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds: 500), content: Text(e.toString())));
    }
    return;
  }

  int _currentPage = 0;

  final List<Widget> _pages = [PendingCarsList(), TrucksPage(), SearchCars()];

  List<MenuData> menuDataList;
  PageController _controller = PageController(initialPage: 0);

  void selectPage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void changeNavItem(index) {
    setState(() {
      _currentPage = index;
      _controller.animateToPage(index, curve: Curves.fastOutSlowIn, duration: Duration(milliseconds: 400));
    });
  }

  void trackUser() async {
    final prefs = await SharedPreferences.getInstance();
    var userID = prefs.get("userID");
    FirebaseDatabase fbdb = FirebaseDatabase.instance;
    DatabaseReference dbrLat = fbdb.reference().child('locations').reference().child('$userID').reference().child('lat');

    DatabaseReference dbrLng = fbdb.reference().child('locations').reference().child('$userID').reference().child('lng');

    await BackgroundLocation.startLocationService(distanceFilter: 20);

    BackgroundLocation.getPermissions(
      onGranted: () async {
        // Start location service here or do something else

        BackgroundLocation.getLocationUpdates((location) async {
          //  print("${location.latitude}  , ${location.longitude}"  );
          if (location != null) {
            dbrLat.set(location.latitude);
            dbrLng.set(location.longitude);
          } else {
            // print("Tele3 null");
          }
          await Future.delayed(Duration(seconds: 5));
        });
      },
      onDenied: () {
        // Show a message asking the user to reconsider or do something else
      },
    );
  }

  void initState() {
    super.initState();
    trackUser();
    menuDataList = [
      new MenuData(Icons.settings, (context, menuData) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return SettingsPage();
          },
        ));
      }, labelText: 'Settings'),
      new MenuData(Icons.directions_car, (context, menuData) async {
        Provider.of<CarsModel>(context).setSelectedServerPeugeot();
        _refreshPage(context);
        Scaffold.of(context).showSnackBar(new SnackBar(duration: Duration(milliseconds: 300), content: new Text('Peugeot Server Selected!')));
      }, labelText: 'Peugeot'),
      new MenuData(Icons.directions_car, (context, menuData) async {
        Provider.of<CarsModel>(context).setSelectedServerMG();
        _refreshPage(context);
        Scaffold.of(context).showSnackBar(new SnackBar(duration: Duration(milliseconds: 300), content: new Text('MG Server Selected!')));
      }, labelText: 'MG'),
      new MenuData(Icons.lock_outline, (context, menuData) {
        Provider.of<CarsModel>(context).logout();
        Navigator.pushReplacementNamed(context, '/login');
      }, labelText: 'logout')
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new FabMenu(
        menus: menuDataList,
        maskColor: Colors.black,
      ),
      floatingActionButtonLocation: fabMenuLocation,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "MotorCity",
            style: TextStyle(fontSize: 25),
          )),
      body: PageView(
        children: _pages,
        controller: _controller,
        onPageChanged: selectPage,
      ),
      bottomNavigationBar: BottomNavigationBar(onTap: changeNavItem, currentIndex: _currentPage, items: [
        BottomNavigationBarItem(icon: new Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Truck Req.'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Cars'),
      ]),
    );
  }
}
