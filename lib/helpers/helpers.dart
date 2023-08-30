import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:tour_guide/helpers/permissions_utils.dart';
import 'package:tour_guide/models/stop.dart';
import 'package:tour_guide/models/tour.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

String googleAPIKey = "AIzaSyB1OIdg_VcZaFTuwSsNF5SQGUtmd6Tc9tU";

var dbInstance = FirebaseFirestore.instance;
CollectionReference toursRef = dbInstance.collection("tours");
CollectionReference stopsRef = dbInstance.collection("stops");
String placeholder_url = "https://phito.be/wp-content/uploads/2020/01/placeholder.png";
String userPlaceHolder = "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png";
String appName = "A4 Malta";
var appVersion = "1.0.0";

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}


Future<void> launchUrl(String url) async {
  url = !url.startsWith("http") ? ("http://" + url) : url;
  if (await canLaunch(url)) {
    launch(
      url,
      forceSafariVC: true,
      enableJavaScript: true,
      forceWebView: GetPlatform.isAndroid,
    );
  } else {
    throw 'Could not launch $url';
  }
}

SharedPreferences? _sharedInstance;
Future<SharedPreferences> getSharedPreferenceInstance () async {
  if (_sharedInstance != null){
    return _sharedInstance!;
  }
  _sharedInstance = await SharedPreferences.getInstance();
  return _sharedInstance!;
}

Future<void> addTour(Tour tour) async {
  var instance = await getSharedPreferenceInstance();
  var oldTours = await getAllTours();
  oldTours.add(tour);
  var stringList = oldTours.map((e) => jsonEncode(e.toMap())).toList();
  instance.setStringList("tours_list", stringList);
}
Future<Tour> getTour(String tour_id) async {
  var allTours = await getAllTours();
  return allTours.where((element) => element.id == tour_id).toList().first;
}

Future<void> _removeTour(String tour_id) async {
  var allTours = await getAllTours();
  allTours.removeWhere((element) => element.id == tour_id);
  var instance = await getSharedPreferenceInstance();
  var stringList = allTours.map((e) => jsonEncode(e.toMap())).toList();
  await instance.setStringList("tours_list", stringList);
}

Future<void> _removeTourStops(String tour_id) async {
  var allStops = await getAllStops();
  allStops.removeWhere((element) => element.tour_id == tour_id);
  var instance = await getSharedPreferenceInstance();
  var stringList = allStops.map((e) => jsonEncode(e.toMap())).toList();
  await instance.setStringList("stops_list", stringList);
}



Future <List<Tour>> getAllTours () async {
  var instance = await getSharedPreferenceInstance();
  var stringList = await instance.getStringList("tours_list") ?? [];
  return stringList.map((e) => Tour.fromMap(jsonDecode(e) as Map<String, dynamic>)).toList();
}

Future<void> addStop(Stop stop) async {
  var instance = await getSharedPreferenceInstance();
  var oldStops = await getAllStops();
  oldStops.add(stop);
  var stringList = oldStops.map((e) => jsonEncode(e.toMap())).toList();
  instance.setStringList("stops_list", stringList);
}
Future<Stop> getStop(String stop_id) async {
  var allStops = await getAllStops();
  return allStops.where((element) => element.id == stop_id).toList().first;
}
Future <List<Stop>> getAllStops () async {
  var instance = await getSharedPreferenceInstance();
  var stringList = await instance.getStringList("stops_list") ?? [];
  return stringList.map((e) => Stop.fromMap(jsonDecode(e) as Map<String, dynamic>)).toList();
}

Future<void> deleteTourData(String tour_id) async {
  var exists = await PermissionUtils.deleteDirectory(".$appName/tours/$tour_id/");
  print(exists);
  var stops = await getAllStops();
  Future.forEach(stops, (Stop element) async {
    await PermissionUtils.deleteDirectory(".$appName/stops/${element.id}");
  });
  await _removeTour(tour_id);
  await _removeTourStops(tour_id);
}


Future<bool> isFirstOpen() async {
  var prefs = await SharedPreferences.getInstance();
  return (await prefs.getBool("firstOpen") ?? true);
}

Future<void> updateFirstOpen() async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.setBool("firstOpen", false);
}