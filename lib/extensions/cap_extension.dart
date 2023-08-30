import 'package:get/get.dart';

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';

  String get allInCaps => this.toUpperCase();

  String get capitalizeFirstofEach => this.split(" ").map((str) => str.capitalize).join(" ");

  String get removeToken {
    if (this.contains("&token")) {
      int index = this.indexOf("&token");
      return this.replaceAll(this.substring(index, this.length), "");
    } else {
      return this;
    }
  }

  String get toCode {
    switch (this) {
      case "English":
        return "en";
      case "French":
        return "fr";
      case "Arabic":
        return "ar";
      case "Italian":
        return "it";
      case "Russian":
        return "ru";
      default:
        return "ur";
    }
  }
  String get toLanguage {
    switch (this) {
      case "en":
        return "English";
      case "fr":
        return "French";
      case "ar":
        return "Arabic";
      case "it":
        return "Italian";
      case "ru":
        return "Russian";
      default:
        return "Urdu";
    }
  }
}
