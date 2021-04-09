import 'package:flutter/material.dart';
import 'package:motorcity/models/car.dart';
import 'package:motorcity/screens/car.dart';
import 'package:motorcity/screens/move.dart';

class CarItem extends StatelessWidget {
  Car car;

  CarItem(Car car) : this.car = car;

  int day;
  int month;
  int year;

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    day = int.parse(car.date.split('-')[0]);
    month = int.parse(car.date.split('-')[1]);
    year = int.parse(car.date.split('-')[2]);

    return Card(
        color:
            (DateTime(year, month, day).compareTo(DateTime(now.year, now.month, now.day)) <= 0) ? Colors.red[100] : Colors.white,
        child: FlatButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CarScreen(car)));
            },
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(5),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(flex: 1, fit: FlexFit.loose, child: Container(child: Image.asset(car.imageURL))), //BrandImage

                  Flexible(
                      flex: 3,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(
                          trailing: (car.pdiCode == "1")
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                )
                              : (car.pdiCode == "0")
                                  ? Icon(
                                      Icons.warning,
                                      color: Colors.yellow,
                                      size: 20,
                                    )
                                  : SizedBox(),
                          title: FittedBox(
                            child: Text(
                              car.chassis,
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 17),
                            ),
                          ),
                          subtitle: Text(
                            car.model + '-' + car.color + '/' + car.colorCode,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          title: Text(
                            car.location,
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 17),
                          ),
                          subtitle: Text("Date: " + car.date, style: TextStyle(fontSize: 16)),
                        )
                      ]))
                ]))));
  }
}
