import 'dart:io';

import 'package:flutter/cupertino.dart';

class ChosenImage extends ChangeNotifier {

   File?  _chosenImage;

  File get chosenImage => File(_chosenImage!.path.toString());
  set setChosenImage(File img) {
   _chosenImage = img;
   notifyListeners();
   }
  }

