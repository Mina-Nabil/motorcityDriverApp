import 'package:motorcity/models/truckrequest.dart';

import 'package:flutter/material.dart';
import 'package:motorcity/providers/cars_model.dart';
import 'package:motorcity/screens/request_info.dart';
import 'package:provider/provider.dart';

class RequestItem extends StatefulWidget {
  final TruckRequest req;

  RequestItem(this.req);

  @override
  _RequestItemState createState() => _RequestItemState();
}

class _RequestItemState extends State<RequestItem> {
  bool isSales = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      isSales = await Provider.of<CarsModel>(context).isSales();
      setState(() {
        isSales = isSales;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double textFont = ((MediaQuery.of(context).size.height) > 800) ? 20 : 12;
    print(MediaQuery.of(context).size.height);
    return Card(
        margin: const EdgeInsets.all(5),
        color: (widget.req.status == '1') ? Colors.green[100] : Colors.white,
        child: FlatButton(
            onPressed: !(isSales)
                ? () => {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return RequestInfo(
                            context: context,
                            req: widget.req,
                          );
                        },
                      ))
                    }
                : null,
            child: Container(
              width: double.infinity,
              height: (MediaQuery.of(context).size.height > 800) ? 260 : MediaQuery.of(context).size.height / 2.5,
              padding: const EdgeInsets.all(5),
              child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Image.asset((widget.req.status == '1') ? "assets/new.png" : "assets/in-progress.png"),
                ),
                Flexible(
                  flex: 8,
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                              fit: FlexFit.loose,
                              flex: 6,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 15),
                                child: Text('Request #${widget.req.id}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              )),
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 4,
                            child: Container(
                              alignment: Alignment.topRight,
                              child: Text(
                                'since ${widget.req.reqDate}',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 12, color: Colors.black87, fontStyle: FontStyle.italic),
                              ),
                            ),
                          )
                        ],
                      ),
                      Flexible(
                          fit: FlexFit.loose,
                          flex: 5,
                          child: Container(
                              padding: EdgeInsets.only(top: 5, left: 15),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    fit: FlexFit.loose,
                                    flex: 3,
                                    child: Text(
                                      'From',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: textFont),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Flexible(
                                      fit: FlexFit.loose,
                                      flex: 7,
                                      child: Text('${widget.req.from}', style: TextStyle(fontSize: textFont), textAlign: TextAlign.center))
                                ],
                              ))),
                      Flexible(
                          fit: FlexFit.loose,
                          flex: 5,
                          child: Container(
                            padding: EdgeInsets.only(left: 15, top: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  fit: FlexFit.loose,
                                  flex: 3,
                                  child: Text(
                                    'To',
                                    style: TextStyle(fontSize: textFont, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Flexible(
                                    fit: FlexFit.loose,
                                    flex: 7,
                                    child: Text(
                                      ' ${widget.req.to}',
                                      style: TextStyle(fontSize: textFont),
                                      textAlign: TextAlign.end,
                                    ))
                              ],
                            ),
                          )),
                      Flexible(
                          fit: FlexFit.loose,
                          flex: 5,
                          child: Container(
                            padding: EdgeInsets.only(left: 15, top: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  fit: FlexFit.loose,
                                  flex: 3,
                                  child: Text(
                                    'Driver',
                                    style: TextStyle(fontSize: textFont, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Flexible(
                                    fit: FlexFit.loose,
                                    flex: 7,
                                    child: Text(
                                      ' ${widget.req.driverName}',
                                      style: TextStyle(fontSize: textFont),
                                      textAlign: TextAlign.end,
                                    ))
                              ],
                            ),
                          )),
                      Flexible(
                          fit: FlexFit.loose,
                          flex: 5,
                          child: Container(
                              padding: EdgeInsets.only(left: 15, top: 5),
                              child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                Flexible(
                                    fit: FlexFit.loose,
                                    flex: 3,
                                    child: Text(
                                      "Model",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: textFont),
                                    )),
                                Flexible(
                                    fit: FlexFit.loose,
                                    flex: 7,
                                    child: Text(
                                      '${widget.req.model}',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(fontSize: textFont),
                                    ))
                              ]))),
                      Flexible(
                          fit: FlexFit.loose,
                          flex: 5,
                          child: Container(
                              padding: EdgeInsets.only(left: 15, top: 5),
                              child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                Flexible(
                                    fit: FlexFit.loose,
                                    flex: 3,
                                    child: Text(
                                      "Chassis",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: textFont),
                                    )),
                                Flexible(
                                    fit: FlexFit.loose,
                                    flex: 7,
                                    child: Text(
                                      '${widget.req.chassis}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: textFont),
                                    ))
                              ]))),
                      Flexible(
                          fit: FlexFit.loose,
                          flex: 8,
                          child: Container(
                            padding: EdgeInsets.only(left: 15, top: 5),
                            child: Text(
                              '${widget.req.comment}',
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: textFont),
                            ),
                          ))
                    ],
                  ),
                ),
              ]),
            )));
  }
}
