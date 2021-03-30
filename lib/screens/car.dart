import 'package:flutter/material.dart';
import 'package:motorcity/models/car.dart';
import 'package:motorcity/screens/move.dart';
import 'package:motorcity/screens/pdi.dart';

class CarScreen extends StatefulWidget {
  final Car car;
  CarScreen(this.car);

  @override
  _CarScreenState createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  List<Widget> _pages;
  int _currentPage = 0;
  PageController _controller = PageController(initialPage: 0);

  void changeNavItem(index) {
    setState(() {
      _currentPage = index;
      _controller.animateToPage(index, curve: Curves.fastOutSlowIn, duration: Duration(milliseconds: 400));
    });
  }


  void selectPage(int index) {
    setState(() {
      _currentPage = index;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pages = [MovePage(widget.car), PDIScreen(widget.car)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Car Page",
        style: TextStyle(fontSize: 25),
      )),
      body: PageView(
        children: _pages,
        controller: _controller,
        onPageChanged: selectPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: changeNavItem,
        currentIndex: _currentPage,
        
        items: [
          BottomNavigationBarItem(label: "Move Car", icon: Icon(Icons.car_repair)),
          BottomNavigationBarItem(label: "PDI", icon: Icon(Icons.check_rounded)),
        ],
      ),
    );
  }
}
