import 'package:flutter/material.dart';
import 'package:wonderjoys/size_config.dart';

const String appName = "WonderJoyS";

const kPrimaryColor = Color(0xFF1B98F5);
const kPrimaryLightColor = Color(0xFF5DA3FA);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1B98F5), Color(0xFF5DA3FA)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

const kAnimationDuration = Duration(milliseconds: 200);

const double screenPadding = 10;

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Inserisci la tua email";
const String kInvalidEmailError = "Perfavore Inserisci un'email valida";
const String kPassNullError = "Per favore inserisci LA TUA password";
const String kShortPassError = "La password è troppo corta";
const String kMatchPassError = "Le password non corrispondono";
const String kNamelNullError = "Per favore inserisci il tuo nome";
const String kPhoneNumberNullError = "Per favore immetti il tuo numero di telefono";
const String kAddressNullError = "Per favore inserisci il tuo indirizzo";
const String FIELD_REQUIRED_MSG = "Questo campo è obbligatorio";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}
