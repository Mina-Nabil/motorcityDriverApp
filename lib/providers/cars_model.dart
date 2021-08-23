import 'dart:convert';
import 'dart:io';
import 'package:motorcity/models/PDICheckItem.dart';
import 'package:motorcity/models/PDISubmitItem.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:motorcity/models/car.dart';
import 'package:motorcity/models/http_exception.dart';
import 'package:motorcity/models/location.dart';
import 'package:motorcity/models/truckrequest.dart';
import 'package:http/http.dart' as http;
import "package:shared_preferences/shared_preferences.dart";

class CarsModel with ChangeNotifier {
  static final String _mgKey = 'mg';
  static final String _pgKey = 'pg';
  static final String _selectedKey = 'selected';

  static String mgServerIP;
  static String peugeotServerIP;

  static String mgServer;
  //static final String peugeotServer  = "http://192.168.1.202/motorcity/api/";
  static String peugeotServer;
  static String selectedURL;

  static String userID;

  final String _pendingURL = 'pending';
  final String _inventoryURL = 'inventory';
  final String _locationURL = 'locations';
  final String _requestsURL = 'requests';
  final String _loginURL = 'driverLogin';
  final String _moveURL = "submit/move";
  final String _acceptTruckRequestURL = "request/accept";
  final String _completeTruckRequestURL = "request/complete";
  final String _cancelTruckRequestURL = "request/cancel";
  final String _getPdiCheckItems = 'pdi/checks';
  final String _getPdiCheckTitles = 'pdi/titles';
  final String _submitPdi = 'submit/pdi';

  Map<String, String> _requestHeaders = {
    'Accept': 'application/json',
  };

  List<Car> _pendingCars = [];
  List<Car> _inventoryCars = [];
  List<Location> _locations = [];
  List<TruckRequest> _requests = [];
  List<PDICheckItem> _pdi_items = [];
  List<PDICheckTitle> _pdi_titles = [];

  bool _isAuthenticated = false;
  static bool _isSales = false;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  Future<bool> isSales() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isSales");
  }

  List<Car> get pendingCars {
    return [..._pendingCars];
  }

  List<Car> get inventoryCars {
    return [..._inventoryCars];
  }

  List<Location> get locations {
    return [..._locations];
  }

  List<TruckRequest> get requests {
    return [..._requests];
  }

  List<PDICheckItem> get pdiItems {
    return [..._pdi_items];
  }

  List<PDICheckTitle> get pdiTitles {
    return [..._pdi_titles];
  }

/////////////////////////////////BackEnd Functions////////////////////////////////

  Future<void> loadCars({bool force = false, ignoreEmpty = false}) async {
    if ((_inventoryCars.length > 0 || !ignoreEmpty) && !force) {
      notifyListeners();
      return;
    }
    try {
      if (selectedURL == null) await initServers();

      if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null) await initHeaders();
      _pendingCars = [];
      String apiURL = selectedURL + _pendingURL;
      final response = await http.get(apiURL, headers: _requestHeaders).timeout(Duration(seconds: 2));
      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(cleanResponse(response.body));

        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey("headers") && decodedJson['headers'] == false) {
          this.logout();
          return;
        }

        Iterable l = decodedJson;
        l.where((car) {
          return (car['Car']['INVT_ID'] != null);
        }).forEach((car) {
          Car tmpCar = Car.fromJson(car['Car']);
          var tmpDate = car['Salesdata']['SALS_ET_DATE'];
          tmpCar.setDate(tmpDate);

          _pendingCars.add(tmpCar);
        });

        notifyListeners();
      }
    } catch (e) {
      // print("Exception catched: " + e.toString());
      notifyListeners();
      throw HttpException('Can\'t connect to the server!');
    }
    return;
  }

  Future<void> loadInventory({bool force = false}) async {
    if (_inventoryCars.length > 0 && !force) {
      notifyListeners();
      return;
    }
    try {
      if (selectedURL == null) await initServers();
      if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null) await initHeaders();
      _inventoryCars = [];
      String apiURL = selectedURL + _inventoryURL;
      final response = await http.get(apiURL, headers: _requestHeaders).timeout(Duration(seconds: 2));
      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(cleanResponse(response.body));

        //Check if User is Authorized
        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey("headers") && decodedJson['headers'] == false) {
          this.logout();
          return;
        }

        Iterable l = decodedJson;

        this._inventoryCars = l.map((carJson) {
          Car car = Car.fromJson(carJson);
          return car;
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      // print("Exception catched: " + e.toString());
      _inventoryCars = [];
      notifyListeners();
      throw HttpException('Can\'t connect to the server!');
    }
  }

  Future<void> loadLocations({bool force = false}) async {
    if (_locations.length > 0 && !force) {
      notifyListeners();
      return;
    }

    try {
      if (selectedURL == null) await initServers();
      if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null) await initHeaders();
      _locations = [];

      String apiURL = selectedURL + _locationURL;

      final response = await http.get(apiURL, headers: _requestHeaders).timeout(Duration(seconds: 2));
      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(cleanResponse(response.body));

        //Check if User is Authorized
        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey("headers") && decodedJson['headers'] == false) {
          this.logout();
          return false;
        }

        Iterable l = decodedJson;

        this._locations = l.map((locJson) {
          Location loc = Location(id: int.parse(locJson['LOCT_ID']), name: locJson['LOCT_NAME']);
          return loc;
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      // print("Exception catched: " + e.toString());
      notifyListeners();
      throw HttpException('Can\'t connect to the server!');
    }
  }

  Future<void> loadTruckRequests({bool force = false}) async {
    if (_requests.length > 0 && !force) {
      notifyListeners();
      return true;
    }
    try {
      if (selectedURL == null) await initServers();
      if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null) await initHeaders();
      _requests = [];
      notifyListeners();
      String apiURL = mgServer + _requestsURL;
      final response = await http.post(apiURL, headers: _requestHeaders, body: {"DriverID": userID}).timeout(Duration(seconds: 2));
      if (response.statusCode == 200) {
        print(response.body);
        final dynamic cleanRequests = cleanResponse(response.body);
        //Check if User is Authorized
        if (cleanRequests is Map<String, dynamic> && cleanRequests.containsKey("headers") && cleanRequests['headers'] == false) {
          this.logout();
          return false;
        }
        final Iterable decoded = json.decode(cleanRequests);

        decoded.forEach((tmp) => _requests.add(TruckRequest.fromJson(tmp)));
        notifyListeners();
      }
    } catch (e) {
      print("Exception catched: " + e.toString());
      notifyListeners();
      throw HttpException('Can\'t connect to the server!');
    }
    return true;
  }

  Future<bool> moveCar({driverID, startLoct, endLoct, carID, km, date, comment}) async {
    try {
      final response = await http.post(selectedURL + _moveURL,
          body: {"DriverID": driverID, "startLocation": startLoct, "endLocation": endLoct, "InventoryID": carID, "KMs": km, "Date": date, "Comment": comment},
          headers: _requestHeaders);
      if (response.statusCode == 200) {
        final dynamic decodedJson = jsonDecode(cleanResponse(response.body));

        //Check if User is Authorized
        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey("headers") && decodedJson['headers'] == false) {
          this.logout();
          return false;
        }
        String result = decodedJson['result'];
        if (result.compareTo("Failed") == 0) {
          return false;
        } else {
          this.loadCars(force: true);
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> login({String user, String password}) async {
    try {
      final response = await http.post(selectedURL + _loginURL, body: {"DRVRName": user, "DRVRPass": password});
      if (response.statusCode == 200) {
        final loginBody = jsonDecode(response.body);
        print(loginBody["id"]);
        var id = loginBody['id'];
        var token = loginBody['token'];
        var type = loginBody['type'];
        if (type == "driver")
          _isSales = false;
        else
          _isSales = true;
        if (id != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          await prefs.setString("userID", id);
          await prefs.setString("userName", user);
          await prefs.setString("token", token);
          await prefs.setString("userType", type);
          await prefs.setBool("isSales", _isSales);
          await prefs.setString("date", DateTime.now().millisecondsSinceEpoch.toString());

          await initHeaders();

          prefs.setString(_selectedKey, selectedURL);
          userID = id;
          _isAuthenticated = true;

          return true;
        } else
          return false;
      } else {
        print(response.statusCode.toString());
        return false;
      }
    } catch (e) {
      print("Exception: " + e.toString());
      return false;
    }
  }

  Car getCarById(String id) {
    return _inventoryCars.singleWhere((car) => car.id == id);
  }

  Future<bool> acceptTruckRequest(reqId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String drvrID = prefs.get("userID");
      if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null) await initHeaders();
      final bodyArr = {"DriverID": drvrID, "RequestID": reqId};
      final response = await http.post(mgServer + _acceptTruckRequestURL, headers: _requestHeaders, body: bodyArr).timeout(Duration(seconds: 2));

      if (response.statusCode == 200) {
        final serverResponse = json.decode(cleanResponse(response.body));
        if (serverResponse['response'] == true) {
          await this.loadTruckRequests(force: true);
          return true;
        } else
          return false;
      } else
        return false;
    } catch (e) {
      throw HttpException("Can't connect to server");
    }
  }

  Future<bool> completeTruckRequest(reqId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String drvrID = prefs.get("userID");
      if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null) await initHeaders();
      final bodyArr = {"DriverID": drvrID, "RequestID": reqId};
      final response = await http.post(mgServer + _completeTruckRequestURL, headers: _requestHeaders, body: bodyArr).timeout(Duration(seconds: 2));

      if (response.statusCode == 200) {
        final serverResponse = json.decode(cleanResponse(response.body));
        if (serverResponse['response'] == true) {
          // FlutterBackgroundLocation.stopLocationService();
          await this.loadTruckRequests(force: true);
          return true;
        } else
          return false;
      } else
        return false;
    } catch (e) {
      throw HttpException("Can't connect to server");
    }
  }

  Future<bool> cancelTruckRequest(reqId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String drvrID = prefs.get("userID");
      if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null) await initHeaders();
      final bodyArr = {"DriverID": drvrID, "RequestID": reqId};
      final response = await http.post(mgServer + _cancelTruckRequestURL, headers: _requestHeaders, body: bodyArr).timeout(Duration(seconds: 2));

      if (response.statusCode == 200) {
        final serverResponse = json.decode(cleanResponse(response.body));
        if (serverResponse['response'] == true) {
          // FlutterBackgroundLocation.stopLocationService();
          await this.loadTruckRequests(force: true);
          return true;
        } else
          return false;
      } else
        return false;
    } catch (e) {
      throw HttpException("Can't connect to server");
    }
  }

/////////////////////////PDI Functions//////////////////////////////////////////

  Future<void> loadPDIChecks({bool force = true}) async {
    if ((_pdi_items.length > 0) && !force) {
      notifyListeners();
      return;
    }

    try {
      if (selectedURL == null) await initServers();

      if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null) await initHeaders();

      _pdi_items = [];
      _pdi_titles = [];

      String itemsApiURL = selectedURL + _getPdiCheckItems;
      String titlesApiURL = selectedURL + _getPdiCheckTitles;

      final itemsResponse = await http.get(itemsApiURL, headers: _requestHeaders).timeout(Duration(seconds: 2));
      if (itemsResponse.statusCode == 200) {
        final dynamic decodedJson = json.decode(cleanResponse(itemsResponse.body));

        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey("headers") && decodedJson['headers'] == false) {
          this.logout();
          return;
        }
        Iterable l = decodedJson;

        l.forEach((checkaya) => _pdi_items.add(PDICheckItem.fromJSON(checkaya)));
      }

      final titlesResponse = await http.get(titlesApiURL, headers: _requestHeaders).timeout(Duration(seconds: 2));
      if (titlesResponse.statusCode == 200) {
        final dynamic decodedJson = json.decode(cleanResponse(titlesResponse.body));

        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey("headers") && decodedJson['headers'] == false) {
          this.logout();
          return;
        }
        Iterable l = decodedJson;

        l.forEach((titleaya) => _pdi_titles.add(PDICheckTitle.fromJSON(titleaya)));
        notifyListeners();
      }
    } catch (e) {
      print("Exception catched: " + e.toString());
      notifyListeners();
      throw HttpException('Can\'t connect to the server!');
    }
    return;
  }

  Future<bool> submitPDI(String carID, int success, List<PDISubmitItem> pdiItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userID = prefs.get("userID");
      if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null) await initHeaders();


      final bodyArr = {"userID": userID, "inventoryID": carID, "success": success.toString(), "items": jsonEncode(pdiItems) };
      final response = await http.post(selectedURL + _submitPdi, headers: _requestHeaders, body: bodyArr).timeout(Duration(seconds: 2));

      if (response.statusCode == 200) {
        final serverResponse = json.decode(cleanResponse(response.body));
        if (serverResponse['result'] == "Success") {
          return true;
        } else
          return false;
      } else
        return false;
    } catch (e) {
      throw HttpException("Can't connect to server");
    }
  }

/////////////////////////Model Management Functions/////////////////////////////
  Future<void> initServers() async {
    if (selectedURL == null) {
      final directory = await getApplicationDocumentsDirectory();
      final pgFile = new File("${directory.path}/pg_server.txt");
      final mgFile = new File("${directory.path}/mg_server.txt");
      mgServerIP = await mgFile.readAsString();
      peugeotServerIP = await pgFile.readAsString();

      final prefs = await SharedPreferences.getInstance();

      mgServer = "http://" + mgServerIP + "/motorcity/api/";
      peugeotServer = "http://" + peugeotServerIP + "/peugeot/api/";

      selectedURL = prefs.getString(_selectedKey) ?? peugeotServer;
    }
  }

  Future<void> initHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    this._requestHeaders.addAll({"token": prefs.get("token"), "userType": prefs.get("userType")});
  }

  void setServersIP(peugeotIP, mgIP) async {
    int selectedIP = 0; //1 => peageut & 2 => mg

    if (selectedURL == mgServer) selectedIP = 2;
    if (selectedURL == peugeotServer) selectedIP = 1;

    mgServerIP = mgIP;
    peugeotServerIP = peugeotIP;
    //Writing IPs to files
    final directory = await getApplicationDocumentsDirectory();
    final pgFile = new File("${directory.path}/pg_server.txt");
    final mgFile = new File("${directory.path}/mg_server.txt");
    pgFile.writeAsString(peugeotServerIP);
    mgFile.writeAsString(mgServerIP);

    final prefs = await SharedPreferences.getInstance();

    mgServer = "http://" + mgServerIP + "/motorcity/api/";
    peugeotServer = "http://" + peugeotServerIP + "/peugeot/api/";

    if (selectedIP == 1)
      selectedURL = peugeotServer;
    else if (selectedIP == 2) selectedURL = mgServer;

    prefs.setString(_mgKey, mgIP);
    prefs.setString(_pgKey, peugeotIP);
  }

  void setSelectedServerMG({bool refreshCars = false}) async {
    selectedURL = mgServer;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_selectedKey, selectedURL);
  }

  void setSelectedServerPeugeot({bool refreshCars = false}) async {
    selectedURL = peugeotServer;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_selectedKey, selectedURL);
  }

  void setUserID(String id) {
    _isAuthenticated = true;
    userID = id;
  }

  Future<bool> checkIfAuthenticated() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pgFile = new File("${directory.path}/pg_server.txt");
      final mgFile = new File("${directory.path}/mg_server.txt");
      mgServerIP = await mgFile.readAsString();
      peugeotServerIP = await pgFile.readAsString();

      if (mgServerIP == null && peugeotServerIP == null) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.get("userID");
      var date = prefs.get("date");
      if (date == null) {
        await logout();
        return false;
      }
      int lastLogin = int.parse(date);
      if (userID != null && lastLogin > DateTime.now().add(Duration(hours: 12)).millisecond) {
        this.setUserID(userID);
        _isAuthenticated = true;
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  String cleanResponse(json) {
    int shitIndex = json.indexOf("<script");
    String properResponse;
    if (shitIndex > 0)
      properResponse = json.substring(0, shitIndex);
    else
      properResponse = json;

    return properResponse;
  }
}
