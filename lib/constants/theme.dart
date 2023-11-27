import 'package:flutter/material.dart';
import 'package:gpt_app/constants/colors.dart';

final darkTheme =   ThemeData(
  scaffoldBackgroundColor: Color(0xff111111),
  primaryColor: kDefaultRedColor,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.red,
    accentColor: kDefaultRedColor,
    brightness: Brightness.light,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.red,
  ),
  toggleButtonsTheme: ToggleButtonsThemeData(
    color: Colors.red,
  ),
  appBarTheme: AppBarTheme(
    color: kDefaultBackgroundBlack
  )
);