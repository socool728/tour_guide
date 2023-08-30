import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tour_guide/helpers/helpers.dart';

import '../models/stop.dart';

class PermissionUtils {
  static Future<PermissionStatus> checkStorageWritePermission() async {
    String path = "";
    var permission = Permission.storage;

    if (GetPlatform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 30) {
        path = "/storage/emulated/0";
        permission = Permission.manageExternalStorage;
      } else {
        path = (await getExternalStorageDirectory())!.path;
      }
    } else {
      path = (await getApplicationDocumentsDirectory()).path;
    }
    var status = await permission.request();
    return status;
  }

  static Future<String> saveFile(String filePath, File file) async {
    String defaultPath = "";

    if (GetPlatform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 30) {
        defaultPath = "/storage/emulated/0";
      } else {
        defaultPath = (await getExternalStorageDirectory())!.path;
      }
    } else {
      defaultPath = (await getApplicationDocumentsDirectory()).path;
    }

    var saveDirectory = await Directory("$defaultPath/$filePath/");
    bool directoryExists = await saveDirectory.exists();
    if (!directoryExists) {
      await saveDirectory.create(recursive: true);
    }

    String response = "";
    File fileDef = File(saveDirectory.path);
    await fileDef.create(recursive: true);
    Uint8List bytes = await file.readAsBytes();
    await fileDef.writeAsBytes(bytes).then((value) {
      response = "success";
    }).catchError((error) {
      response = error.toString();
    });

    return response;
  }

  static Future<String> createPathDirectory(String path) async {
    String defaultPath = "";

    if (GetPlatform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 30) {
        defaultPath = "/storage/emulated/0";
      } else {
        defaultPath = (await getExternalStorageDirectory())!.path;
      }
    } else {
      defaultPath = (await getApplicationDocumentsDirectory()).path;
    }

    var saveDirectory = await Directory("$defaultPath/$path/");
    bool directoryExists = await saveDirectory.exists();
    if (!directoryExists) {
      await saveDirectory.create(recursive: true).catchError((error) {
        print(error);
      });
    }
    print(saveDirectory.path);

    return saveDirectory.path;
  }

  static Future<bool> _checkIfPathDirectoryExists(String path) async {
    String defaultPath = "";

    if (GetPlatform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 30) {
        defaultPath = "/storage/emulated/0";
      } else {
        defaultPath = (await getExternalStorageDirectory())!.path;
      }
    } else {
      defaultPath = (await getApplicationDocumentsDirectory()).path;
    }

    var saveDirectory = await Directory("$defaultPath/$path/");
    return await saveDirectory.exists();
  }

  static Future<bool> checkIfTourExists(String tourId) async {
    bool permissionAllowed = (await checkStorageWritePermission()).isGranted;
    if (permissionAllowed){
      return (await _checkIfPathDirectoryExists(".$appName/tours/$tourId/"));
    }
    return false;
  }

  static Future<bool> deleteDirectory(String path) async {
    var exactDirPath = await createPathDirectory(path);
    var directory = Directory(exactDirPath);
    directory.deleteSync(recursive: true);
    return (await directory.exists());
  }
}
