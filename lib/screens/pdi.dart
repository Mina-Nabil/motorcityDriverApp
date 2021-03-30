import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:motorcity/models/PDICheckItem.dart';
import 'package:motorcity/models/PDISubmitItem.dart';
import 'package:motorcity/models/car.dart';
import 'package:motorcity/providers/cars_model.dart';
import 'package:provider/provider.dart';

class PDIScreen extends StatefulWidget {
  final Car car;
  PDIScreen(this.car);

  @override
  _PDIScreenState createState() => _PDIScreenState();
}

class _PDIScreenState extends State<PDIScreen> {
  Map<String, bool> checkboxes;
  Map<String, TextEditingController> comments;
  List<PDICheckItem> pdiItems = [];

  GlobalKey<FormState> _pdiformkey;

  bool isSales = false;
  bool submitting = false;

  @override
  void initState() {
    super.initState();

    checkboxes = new Map<String, bool>();
    comments = new Map<String, TextEditingController>();

    Future.delayed(Duration.zero).then((_) async {
      await Provider.of<CarsModel>(context, listen: false).loadPDIChecks();
      setState(() {
        pdiItems = Provider.of<CarsModel>(context, listen: false).pdiItems;
        pdiItems.forEach((element) {
          checkboxes[element.id] = false;
          comments[element.id] = new TextEditingController();
        });
      });
      isSales = await Provider.of<CarsModel>(context).isSales();
    });
    _pdiformkey = new LabeledGlobalKey<FormState>("____PDI____");
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _pdiformkey,
        child: Container(
            key: new PageStorageKey("PDI"),
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(
                child: Column(
              children: [
                Text(
                  "Submit New PDI Check",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Divider(),
                ...pdiItems.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        activeColor: Colors.blue[700],
                        title: Text(
                          e.arbcText,
                          style: TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(e.text),
                        value: checkboxes[e.id] ?? false,
                        onChanged: (selected) {
                          setState(() {
                            checkboxes[e.id] = selected;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          readOnly: (checkboxes[e.id] ?? false),
                          controller: comments[e.id],
                          decoration: InputDecoration(hintText: !(checkboxes[e.id] ?? false) ? "Write a comment if unchecked" : "Checked"),
                          validator: (value) {
                            if (!(checkboxes[e.id] ?? false) && value.length == 0) return "Please leave a comment if unchecked";
                            return null;
                          },
                        ),
                      )
                    ],
                  );
                }).toList(),
                RaisedButton(
                  color: Colors.blue,
                  child: Text("Submit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  onPressed: (isSales || !submitting) ? submitForm : null,
                )
              ],
            ))));
  }

  submitForm() async {
    if (_pdiformkey.currentState.validate()) {
      setState(() {
        submitting = true;
      });
      int success = 1;
      List<PDISubmitItem> items = new List<PDISubmitItem>();
      checkboxes.forEach((key, value) {
        if (value) {
          items.add(new PDISubmitItem(key, true, null));
        } else {
          items.add(new PDISubmitItem(key, false, comments[key].value.text));
          success = 0;
        }
      });

      bool res = await Provider.of<CarsModel>(context).submitPDI(widget.car.id, success, items);
      if (res) {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: Text("PDI Submitted!"),
        ));
        resetForm();
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: Text("Submission Failed please try again"),
        ));
      }
      setState(() {
        submitting = false;
      });
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: Text("Invalid Submission, please check all fields"),
      ));
    }
  }

  resetForm() {
    pdiItems.forEach((element) {
      checkboxes[element.id] = false;
      comments[element.id] = new TextEditingController();
    });
  }
}
