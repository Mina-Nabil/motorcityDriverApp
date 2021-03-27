import 'package:flutter/material.dart';
import 'package:motorcity/widgets/request.dart';
import 'package:motorcity/providers/cars_model.dart';
import 'package:provider/provider.dart';

class TrucksPage extends StatefulWidget {
  @override
  _TrucksPageState createState() => _TrucksPageState();
}

class _TrucksPageState extends State<TrucksPage> {
  bool _isLoading = true;

  @override
  initState() {
    Future.delayed(Duration.zero).then((_) async {
      await Provider.of<CarsModel>(context).loadTruckRequests();
      _isLoading = false;
    });
    super.initState();
  }

  Future<Null> _refreshPage(context) async {
    await Provider.of<CarsModel>(context).loadTruckRequests(force: true);
    return;
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    return RefreshIndicator(
        onRefresh: () => _refreshPage(context),
        child: (_isLoading)
            ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: CircularProgressIndicator())
            : (Provider.of<CarsModel>(context).requests.length != 0)
                ? Container(
                    child: ListView(
                        children: Provider.of<CarsModel>(context)
                            .requests
                            .map((requestaya) {
                    return RequestItem(requestaya);
                  }).toList()))
                : SingleChildScrollView(
                    child: Container(
                    height: MediaQuery.of(context).size.height-80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex : 8,
                          child: Opacity(
                            opacity: 0.2,
                              child: Image.asset("assets/noRequests.png"),
                            ),
                        ),
                        Flexible(flex: 3,
                        child: Container(alignment: Alignment.topCenter,child: Opacity(opacity: 0.4, child: Text("...no requests...")),))
                      ],
                    ),
                  ),
                ));
  }
}
