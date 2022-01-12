import 'package:wonderjoys/constants.dart';
import 'package:wonderjoys/screens/forgot_password/components/forgot_password_form.dart';
import 'package:flutter/material.dart';
import '../../../size_config.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(screenPadding)),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                Text(
                  "Ha dimenticato la password",
                  style: headingStyle,
                ),
                Text(
                  "Inserisci la tua email e ti invieremo \nTi un link per tornare al tuo account",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.1),
                ForgotPasswordForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
