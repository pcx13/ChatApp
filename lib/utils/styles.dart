import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class Styles {
  //colors
  static MaterialColor primary = Colors.blue;
  static Color primaryColor = Colors.blue;
  static Color richTextColor = Colors.blue[200]!;
  static Color appBarColor =
      HSLColor.fromColor(Colors.blueGrey[900]!).withLightness(0.15).toColor();
  static Color bodyColor =
      HSLColor.fromColor(Colors.blueGrey[900]!).withLightness(0.11).toColor();
  static Color fillColor = Colors.grey[850]!;
  static Color textColor = Colors.white;
  static Color hintColor = Colors.grey;
  static Color snackBarColor = Colors.red[400]!;
  static Color progressColor = Colors.green[700]!;
  static Color black38Color = Colors.black38;
  static Color black87Color = Colors.black87;
  static Color newMsgColor = Colors.teal;
  static Color selectColor = Colors.white70;

  //icons
  static IconData eyeOnIcon = Icons.visibility_rounded;
  static IconData eyeOffIcon = Icons.visibility_off_rounded;
  static IconData chatIcon = FluentIcons.chat_add_48_filled;
  static IconData searchIcon = FluentIcons.search_32_regular;
  static IconData popUpIcon = Icons.more_vert;
  static IconData sendIcon = FluentIcons.send_28_filled;
  static IconData profileIcon = Icons.person;
  static IconData checkIcon = Icons.check;
  static IconData editIcon = Icons.edit_sharp;
  static IconData clearIcon = Icons.clear;
  static IconData backIcon = Icons.arrow_back;
  static IconData galleryIcon = Icons.image_outlined;
  static IconData infoIcon = Icons.info_outline_rounded;
  static IconData emojiIcon = Icons.emoji_emotions_sharp;
  static IconData binIcon = Icons.delete;
  static IconData copyIcon = Icons.copy_rounded;
  static IconData downloadIcon = Icons.download_rounded;
}
